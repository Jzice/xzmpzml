#!/bin/bash

if [ $# -eq 0 ]; then
    echo "用法: $0 <markdown文件>"
    exit 1
fi

input="$1"
if [ ! -f "$input" ]; then
    echo "错误: 文件 '$input' 不存在"
    exit 1
fi

awk '
function output_current_volume() {
    if (vol_dir == "") return
    readme = vol_dir "/README.md"
    print "生成 " readme
    # 卷标题（一级）
    clean_title = gensub(/^## /, "", 1, vol_title_line)
    print "# " clean_title > readme
    # 卷描述
    if (vol_desc != "") {
        print "" >> readme
        gsub(/\n+$/, "", vol_desc)
        print vol_desc >> readme
    }
    # 章节目录
    print "" >> readme
    print "## 目录" >> readme
    print "" >> readme
    for (i = 1; i <= chap_count; i++) {
        split(chapters[i], parts, "|")
        chap_display = parts[1]
        chap_file = parts[2]
        print "- [" chap_display "](" "./" chap_file ")" >> readme
    }
    close(readme)
}

BEGIN {
    global_chap = 0
    vol_dir = ""
    vol_title_line = ""
    vol_desc = ""
    delete chapters
    chap_count = 0
    in_preface = 1
    preface_content = ""
    vol_list_content = ""   # 存储各卷目录列表内容
}

# 卷标题：## 第1卷 卷名
/^## 第[0-9]+卷 / {
    # 输出上一个卷
    if (vol_dir != "") output_current_volume()
    
    # 记录当前卷信息，用于根README的目录
    vol_num = gensub(/^## 第([0-9]+)卷 .*/, "\\1", "g", $0)
    vol_name = gensub(/^## 第[0-9]+卷 (.*)/, "\\1", "g", $0)
    vol_dir = sprintf("第%03d卷-%s", vol_num, vol_name)
    system("mkdir -p \"" vol_dir "\"")
    print "创建目录: " vol_dir
    
    # 生成卷目录链接（用于根README）
    vol_link = sprintf("- [%s](./%s/README.md)", $0, vol_dir)
    vol_list_content = vol_list_content vol_link "\n"
    
    vol_title_line = $0
    vol_desc = ""
    chap_count = 0
    delete chapters
    in_preface = 0   # 离开前言区域
    next
}

# 章节标题：### 第一章 章名
/^### .*章/ {
    if (in_preface) in_preface = 0
    global_chap++
    chap_num = sprintf("%04d", global_chap)
    tmp = $0
    sub(/^### /, "", tmp)
    sub(/^第[^章]+章 /, "", tmp)
    chap_name = tmp
    if (chap_name == "") chap_name = "无标题"
    chap_basename = sprintf("%s-%s.md", "第" chap_num "章", chap_name)
    chap_fullpath = vol_dir "/" chap_basename
    print "  -> " chap_fullpath
    print $0 > chap_fullpath
    close(chap_fullpath)
    display_name = sprintf("第%s章 %s", chap_num, chap_name)
    chap_count++
    chapters[chap_count] = sprintf("%s|%s", display_name, chap_basename)
    next
}

# 普通行
{
    if (in_preface) {
        # 收集前言内容（包括元数据、# 书名等）
        preface_content = preface_content $0 "\n"
    } else if (vol_dir != "") {
        # 当前卷的描述内容
        vol_desc = vol_desc $0 "\n"
    }
}

END {
    # 输出最后一个卷
    if (vol_dir != "") output_current_volume()
    
    # 生成根目录 README.md
    print "生成根目录 README.md"
    root_readme = "README.md"
    # 写入前言内容（去掉可能多余的空行）
    gsub(/\n+$/, "", preface_content)
    print preface_content > root_readme
    print "" >> root_readme
    print "## 卷目录" >> root_readme
    print "" >> root_readme
    # 写入卷列表
    print vol_list_content >> root_readme
    close(root_readme)
    
    print "完成！共处理 " global_chap " 个章节。"
}
' "$input"