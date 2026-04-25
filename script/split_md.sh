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
BEGIN {
    global_chap = 0
    vol_dir = ""
    current_chap = ""
    desc_file = ""
    in_vol_desc = 0
    in_preface = 1
    preface = ""
}

# 卷标题：## 第1卷 卷名
/^## 第[0-9]+卷 / {
    if (in_preface) {
        if (preface != "") {
            print "创建前言: 00_前言.md"
            print preface > "00_前言.md"
            close("00_前言.md")
        }
        in_preface = 0
    }
    # 关闭上一个卷的描述文件和章文件
    if (desc_file != "") close(desc_file)
    if (current_chap != "") close(current_chap)

    # 提取卷号和卷名
    vol_num = gensub(/^## 第([0-9]+)卷 .*/, "\\1", "g", $0)
    vol_name = gensub(/^## 第[0-9]+卷 (.*)/, "\\1", "g", $0)
    vol_dir = sprintf("第%03d卷-%s", vol_num, vol_name)
    system("mkdir -p \"" vol_dir "\"")
    print "创建目录: " vol_dir

    # 开启卷描述文件
    desc_file = vol_dir "/00_卷描述.md"
    in_vol_desc = 1
    print $0 > desc_file   # 写入卷标题
    next
}

# 章节标题：### 第一章 章名
/^### .*章/ {
    if (in_preface) in_preface = 0   # 避免前言误判
    # 关闭卷描述
    if (desc_file != "") {
        close(desc_file)
        desc_file = ""
        in_vol_desc = 0
    }
    # 全局章节号递增
    global_chap++
    chap_num = sprintf("%04d", global_chap)

    # 提取章名：去掉"### "和章号部分（如"第一章 "）
    tmp = $0
    sub(/^### /, "", tmp)
    sub(/^第[^章]+章 /, "", tmp)
    chap_name = tmp
    if (chap_name == "") chap_name = "无标题"

    # 章文件路径
    chap_file = sprintf("%s/%s-%s.md", vol_dir, "第" chap_num "章", chap_name)
    print "  -> " chap_file
    print $0 > chap_file
    current_chap = chap_file
    next
}

# 普通行处理
{
    if (in_preface) {
        preface = preface $0 "\n"
    } else if (desc_file != "" && in_vol_desc) {
        print $0 >> desc_file
    } else if (current_chap != "") {
        print $0 >> current_chap
    }
}

END {
    # 处理未关闭的前言
    if (in_preface && preface != "") {
        print "创建前言: 00_前言.md"
        print preface > "00_前言.md"
    }
    # 关闭所有打开的文件
    if (desc_file != "") close(desc_file)
    if (current_chap != "") close(current_chap)
    print "完成！共处理 " global_chap " 个章节。"
}
' "$input"