#!/bin/bash

if [ $# -eq 0 ]; then
    echo "用法: $0 <markdown文件>"
    echo "示例: $0 book.md"
    exit 1
fi

input="$1"

if [ ! -f "$input" ]; then
    echo "错误: 文件 '$input' 不存在"
    exit 1
fi

awk '
function generate_readme(vol_dir, vol_title, chapters, n) {
    readme_file = vol_dir "/README.md"
    print "生成 " readme_file
    # 去除卷标题开头的 "## "，变成干净的标题
    clean_title = gensub(/^## /, "", 1, vol_title)
    print "# " clean_title > readme_file
    print "" >> readme_file
    print "## 目录" >> readme_file
    print "" >> readme_file
    for (i = 1; i <= n; i++) {
        split(chapters[i], parts, "|")
        chap_display = parts[1]
        chap_file = parts[2]
        print "- [" chap_display "](" "./" chap_file ")" >> readme_file
    }
    close(readme_file)
}

BEGIN {
    global_chap = 0
    vol_dir = ""
    vol_title = ""
    delete chapters
    chap_count = 0
    current_chap_file = ""
}

/^## .*卷/ {
    # 完成上一个卷
    if (vol_dir != "") {
        generate_readme(vol_dir, vol_title, chapters, chap_count)
    }
    # 提取新卷信息
    vol_num = gensub(/^## 第([0-9]+)卷.*/, "\\1", "g", $0)
    vol_name = gensub(/^## 第[0-9]+卷 (.*)/, "\\1", "g", $0)
    vol_dir = sprintf("%s-%s", "第" vol_num "卷", vol_name)
    system("mkdir -p \"" vol_dir "\"")
    print "创建目录: " vol_dir
    vol_title = $0   # 保留完整卷标题行（含 "## "）
    # 重置章节数组
    chap_count = 0
    delete chapters
    current_chap_file = ""
    next
}

/^### .*章/ {
    # 全局章节号递增
    global_chap++
    chap_num = sprintf("%04d", global_chap)
    # 提取章名（按空格切分取最后一段）
    n = split($0, parts, " ")
    chap_name = parts[n]
    # 章文件名（不含路径）
    chap_basename = sprintf("%s-%s.md", "第" chap_num "章", chap_name)
    chap_fullpath = vol_dir "/" chap_basename
    print "  -> " chap_fullpath
    # 写入章文件
    print $0 > chap_fullpath
    current_chap_file = chap_fullpath
    # 记录章节信息（显示名和文件名）
    chap_count++
    display_name = sprintf("第%s章 %s", chap_num, chap_name)
    chapters[chap_count] = sprintf("%s|%s", display_name, chap_basename)
    next
}

{
    # 普通内容追加到当前章节文件
    if (current_chap_file != "") {
        print $0 >> current_chap_file
    }
    # 注意：卷标题与第一章节之间的内容会被忽略（按需可追加到 README）
}

END {
    if (vol_dir != "") {
        generate_readme(vol_dir, vol_title, chapters, chap_count)
    }
    print "完成！共处理 " global_chap " 个章节。"
}
' "$input"