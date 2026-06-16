#!/bin/bash
# link-characters.sh — 在 资料/ 目录下的 md 文件中为实体名称自动添加/更新/移除内部相对链接
#
# Usage:
#   ./script/link-characters.sh add    - 为纯文本名称添加链接（默认）
#   ./script/link-characters.sh update - 更新已存在的错误路径链接
#   ./script/link-characters.sh remove - 移除指向不存在文件的链接
#
# 原理：
# 1. 扫描 资料/ 目录下所有 .md 文件作为"注册表"（含人物、势力、地点等）
# 2. 在目标文件中，将纯文本名称替换为指向对应文件的相对链接
# 3. 跳过自引用、已有链接、代码块、行内代码
#
# 特征:
# - Perl 内核，可靠处理 UTF-8 中文
# - 逐文件并行处理
# - 自动去重同名文件（选修为最高或路径最深）
# - 子串保护（先处理长名称）

set -euo pipefail

# ─── 配置 ──────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DATA_DIR="$PROJECT_DIR/md/资料"

JOBS=$(nproc 2>/dev/null || echo 4)

# ─── 构建注册表 ────────────────────────────────────────────────────────────

# 使用 Perl 扫描所有 .md 文件，提取名称→路径映射
# 原因：bash/sed 在 Windows/Git Bash 下无法可靠处理 UTF-8 中文
# 文件名规则：
#   - README.md → 跳过
#   - 01.摘星阁.md → 名称为"摘星阁"（去除数字前缀）
#   - 齐休.md → 名称为"齐休"
# 输出格式: NAME|RELATIVE_PATH
# 同名条目只保留排序键最高的（修为最高）
build_registry() {
    local out="$1"

    perl -e '
        use File::Find;
        use Cwd qw(abs_path);
        use File::Spec;

        # 不使用 :std :utf8 层，因为 Git Bash 下的文件名已经是 UTF-8 字节
        # 使用 :utf8 层会导致二次编码（双字节→Latin-1→UTF-8 的二次编码）

        my $data_dir = $ARGV[0] or die "Usage: perl build_registry.pl DATA_DIR";
        my $data_dir_abs = abs_path($data_dir) or die "Cannot resolve: $data_dir";
        my @entries;

        binmode(STDOUT, ":raw");
        binmode(STDERR, ":raw");

        find(sub {
            return unless /\.md$/;
            # 注意: File::Find 会自动 chdir 到文件所在目录，所以 abs_path($_) 直接用 basename 解析
            my $fp_abs = abs_path($_) or return;
            my $rel = File::Spec->abs2rel($fp_abs, $data_dir_abs);
            my $base = substr($_, 0, -3);
            return if $base eq "README";

            # 提取名称：去除开头数字前缀
            (my $name = $base) =~ s/^[0-9]{1,4}\.//;

            # 提取排序键：父目录中的修为等级数字
            my @parts = split /\//, $fp_abs;
            my $pdir = $parts[-2];
            my $sk = "99";
            $sk = $1 if $pdir =~ /^([0-9]{2})/;

            push @entries, { name=>$name, path=>$rel, sort_key=>$sk };
        }, $data_dir);

        # 排序：按名称升序，同名的按排序键降序
        @entries = sort {
            $a->{name} cmp $b->{name} ||
            $b->{sort_key} cmp $a->{sort_key}
        } @entries;

        # 同名去重，保留第一条（排序键最高）
        my $prev = "";
        for my $e (@entries) {
            next if $e->{name} eq $prev;
            print "$e->{name}|$e->{path}\n";
            $prev = $e->{name};
        }
    ' "$DATA_DIR" > "$out"

    local n; n=$(wc -l < "$out")
    echo "[INFO] 注册表: $n 个条目" >&2
}

# ─── Perl 脚本生成 ────────────────────────────────────────────────────────

# ADD: 纯文本 → [name](path)
gen_add_script() {
    cat > "$1" << 'PERLEOF'
#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
use Encode qw(decode);
use File::Spec::Functions qw(rel2abs);
use File::Spec;
no warnings 'uninitialized';

# Git Bash 命令行参数是 UTF-8 字节，需要通过 @ARGV 显式解码
# 否则中文路径（如"资料/楚秦门"）会被当作 Latin-1 处理，导致编码混乱
@ARGV = map { decode('utf-8', $_) } @ARGV;

my ($reg_file, $target_file, $data_dir) = @ARGV;
if (!$data_dir) {
    $data_dir = $ENV{DATA_DIR};
    $data_dir = decode('utf-8', $data_dir) if $data_dir;
}
die "DATA_DIR not set" unless $data_dir;
my $data_dir_abs = rel2abs($data_dir);

# 读注册表
my @reg;
open(my $rf, '<:utf8', $reg_file) or die "registry: $!";
while (<$rf>) { chomp; my ($n,$p)=split /\|/,$_,2; push @reg,{name=>$n,path=>$p} if $n && $p }
close $rf;

# 按名称长度降序（长名称优先，防子串冲突）
@reg = sort { length($b->{name}) <=> length($a->{name}) } @reg;

# 读目标文件
open(my $tf, '<:utf8', $target_file) or die "target: $!";
my $content = do { local $/; <$tf> };
close $tf;

# 保护 1: ```代码块```（跨行用 /s flag）
my %cb; my $cbi=0;
$content =~ s/```.+?```/{"%%CB${cbi}%%".do{$cb{"%%CB${cbi}%%"}=$&;$cbi++;''}}/gse;

# 保护 2: `行内代码`
my %ic; my $ici=0;
$content =~ s/`([^`]*)`/{"%%IC${ici}%%".do{$ic{"%%IC${ici}%%"}=$&;$ici++;''}}/gse;

# 保护 3: 已有链接 [text](url)
my %lk; my $lki=0;
$content =~ s/\[([^\]]*)\]\(([^)]*)\)/{"%%LK${lki}%%".do{$lk{"%%LK${lki}%%"}=$&;$lki++;''}}/gse;

# 自引用检测 + 计算目标文件目录
my $target_abs = rel2abs($target_file);
(my $target_dir = $target_abs) =~ s:/[^/]*$::;
my %self_ref;
# 预计算所有条目的目标相对路径
my @reg2;
foreach my $e (@reg) {
    my $e_abs = rel2abs("$data_dir_abs/$e->{path}");
    $self_ref{$e->{name}} = 1 if $e_abs eq $target_abs;
    push @reg2, {
        name => $e->{name},
        rel  => File::Spec->abs2rel($e_abs, $target_dir),
    };
}

# 替换：名称 → [名称](相对路径)
my $changed = 0;
foreach my $e (@reg2) {
    next if $self_ref{$e->{name}};
    my $count = $content =~ s/\Q$e->{name}\E/[$e->{name}]($e->{rel})/g;
    $changed += $count;
}

# 恢复保护（逆序防止嵌套损坏）
foreach my $k (reverse sort keys %cb) { $content =~ s/\Q$k\E/$cb{$k}/g; }
foreach my $k (reverse sort keys %ic) { $content =~ s/\Q$k\E/$ic{$k}/g; }
foreach my $k (reverse sort keys %lk) { $content =~ s/\Q$k\E/$lk{$k}/g; }

print $content;
exit($changed ? 0 : 1);
PERLEOF
}

# UPDATE: 更新错误路径 [name](wrong) → [name](correct)
gen_update_script() {
    cat > "$1" << 'PERLEOF'
#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
use Encode qw(decode);
use File::Spec::Functions qw(rel2abs);
use File::Spec;
no warnings 'uninitialized';

@ARGV = map { decode('utf-8', $_) } @ARGV;

my ($reg_file, $target_file, $data_dir) = @ARGV;
if (!$data_dir) {
    $data_dir = $ENV{DATA_DIR};
    $data_dir = decode('utf-8', $data_dir) if $data_dir;
}
die "DATA_DIR not set" unless $data_dir;
my $data_dir_abs = rel2abs($data_dir);

# 读取注册表
my %correct;
open(my $rf, '<:utf8', $reg_file) or die "registry: $!";
while (<$rf>) { chomp; my ($n,$p)=split /\|/,$_,2; $correct{$n}=$p if $n && $p }
close $rf;

# 计算目标文件目录，用于路径转换
my $target_abs = rel2abs($target_file);
(my $target_dir = $target_abs) =~ s:/[^/]*$::;

# 预计算注册表条目相对于目标文件目录的路径
my %rel_path;
foreach my $name (keys %correct) {
    my $e_abs = rel2abs("$data_dir_abs/$correct{$name}");
    $rel_path{$name} = File::Spec->abs2rel($e_abs, $target_dir);
}

open(my $tf, '<:utf8', $target_file) or die "target: $!";
my $content = do { local $/; <$tf> };
close $tf;

my $fixed = 0;
$content =~ s/\[([^\]]+)\]\(([^)]*)\)/{
    my $name=$1; my $cur=$2;
    if (exists $rel_path{$name} && $rel_path{$name} ne $cur) {
        $fixed++; "[$name]($rel_path{$name})";
    } else { "[$name]($cur)" }
}/ge;

print $content;
exit($fixed ? 0 : 1);
PERLEOF
}

# REMOVE: 移除指向不存在文件的链接 [name](gone) → name
gen_remove_script() {
    cat > "$1" << 'PERLEOF'
#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
use Encode qw(decode);
use File::Basename;
no warnings 'uninitialized';

@ARGV = map { decode('utf-8', $_) } @ARGV;

my ($reg_file, $target_file, $data_dir) = @ARGV;
if (!$data_dir) {
    $data_dir = $ENV{DATA_DIR};
    $data_dir = decode('utf-8', $data_dir) if $data_dir;
}
die "DATA_DIR not set" unless $data_dir;

my %known;
open(my $rf, '<:utf8', $reg_file) or die "registry: $!";
while (<$rf>) { chomp; my ($n,$p)=split /\|/,$_,2; $known{$n}=$p if $n && $p }
close $rf;

open(my $tf, '<:utf8', $target_file) or die "target: $!";
my $content = do { local $/; <$tf> };
close $tf;

my $removed = 0;
$content =~ s/\[([^\]]+)\]\(([^)]*)\)/remove_link($1, $2)/ge;

print $content;
exit($removed ? 0 : 1);

sub remove_link {
    my ($name, $path) = @_;
    # 跳过外部 URL 和锚点
    if ($path =~ m{^[a-zA-Z][a-zA-Z0-9+.-]*://} || $path =~ /^#/) {
        return "[$name]($path)";
    }
    # 检查文件是否存在
    if (-e "$data_dir/$path" || -e (dirname($target_file)."/$path") || -e $path) {
        return "[$name]($path)";
    }
    # 文件不存在，移除链接
    $removed++;
    return $name;
}
PERLEOF
}

# ─── 文件处理函数 ─────────────────────────────────────────────────────────

process_add() {
    local target="$1" reg="$2" perl_script="$3"
    if perl "$perl_script" "$reg" "$target" "$DATA_DIR" > "${target}.tmp"; then
        if ! cmp -s "$target" "${target}.tmp"; then
            mv "${target}.tmp" "$target"
            echo "[ADD] $target" >&2
        else
            rm -f "${target}.tmp"
        fi
    else
        rm -f "${target}.tmp"
    fi
}

process_update() {
    local target="$1" reg="$2" perl_script="$3"
    if perl "$perl_script" "$reg" "$target" "$DATA_DIR" > "${target}.tmp"; then
        if ! cmp -s "$target" "${target}.tmp"; then
            mv "${target}.tmp" "$target"
            echo "[UPDATE] $target" >&2
        else
            rm -f "${target}.tmp"
        fi
    else
        rm -f "${target}.tmp"
    fi
}

process_remove() {
    local target="$1" reg="$2" perl_script="$3"
    if perl "$perl_script" "$reg" "$target" "$DATA_DIR" > "${target}.tmp"; then
        if ! cmp -s "$target" "${target}.tmp"; then
            mv "${target}.tmp" "$target"
            echo "[REMOVE] $target" >&2
        else
            rm -f "${target}.tmp"
        fi
    else
        rm -f "${target}.tmp"
    fi
}

export DATA_DIR
export -f process_add process_update process_remove

# ─── 主入口 ───────────────────────────────────────────────────────────────

main() {
    local cmd="${1:-add}"
    case "$cmd" in add|update|remove) ;; *)
        echo "Usage: $0 {add|update|remove}"
        exit 1 ;;
    esac

    echo "[INFO] 命令: $cmd"
    echo "[INFO] 数据目录: $DATA_DIR"

    # 临时文件清理
    local registry_file perl_script
    registry_file=$(mktemp /tmp/char-registry-XXXXX.txt)
    perl_script=$(mktemp /tmp/link-char-XXXXX.pl)
    trap "rm -f '$registry_file' '$perl_script'" EXIT

    # 建注册表
    build_registry "$registry_file"

    # 生成 Perl 脚本
    case "$cmd" in
        add)    gen_add_script "$perl_script" ;;
        update) gen_update_script "$perl_script" ;;
        remove) gen_remove_script "$perl_script" ;;
    esac

    # 列出所有目标文件
    local total
    total=$(find "$DATA_DIR" -type f -name "*.md" | wc -l)
    echo "[INFO] 共 $total 个目标文件"

    # 并发处理
    local proc_func
    case "$cmd" in
        add)    proc_func=process_add ;;
        update) proc_func=process_update ;;
        remove) proc_func=process_remove ;;
    esac

    export REGISTRY_FILE="$registry_file"
    export PERL_SCRIPT="$perl_script"

    find "$DATA_DIR" -type f -name "*.md" -print0 \
        | xargs -0 -P "$JOBS" -n 1 bash -c '
            '"$proc_func"' "$1" "$REGISTRY_FILE" "$PERL_SCRIPT"
        ' --

    echo "[INFO] 完成！"
}

# 仅在直接执行时运行 main（被 source 时不执行）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
