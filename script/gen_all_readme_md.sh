#!/bin/bash

# 总输出文件
output="README.md"

# 初始化临时文件
tmp_file=$(mktemp)

# 写入文件头
{
    echo "# 修真门派掌门路"
    echo ""
    echo "## 总目录"
    echo ""
} > "$tmp_file"

# 按卷目录名排序（使用 sort -V 自然排序）
for dir in $(find . -maxdepth 1 -type d -name "第*卷-*" | sort -V); do
    # 去掉开头的 ./
    dir="${dir#./}"
    
    # 生成卷标题：将目录名中的第一个连字符替换为空格（如 "第001卷-飘零之中掌教门" -> "第001卷 飘零之中掌教门"）
    volume_title="${dir/-/ }"
    
    # 写入卷标题（二级标题）
    {
        echo "## $volume_title"
        echo ""
        echo "| 章节 | 文件 |"
        echo "|------|------|"
    } >> "$tmp_file"
    
    # 进入卷目录
    cd "$dir" || continue
    
    # 列出所有章文件（按版本号排序）
    shopt -s nullglob
    chap_files=(第*.md)
    # 使用 sort -V 排序（若 sort -V 不可用，可改用 ls -v，但这里使用 sort -V 更可靠）
    IFS=$'\n' sorted=($(printf "%s\n" "${chap_files[@]}" | sort -V))
    unset IFS
    
    for chap_file in "${sorted[@]}"; do
        # 提取章号：从 "第0001章-xxx.md" 中提取 0001
        chap_num=$(echo "$chap_file" | sed -nE 's/^第([0-9]+)章-.*/\1/p')
        # 提取章名：去掉 "第...章-" 前缀和 .md 后缀
        chap_name=$(echo "$chap_file" | sed -E 's/^第[0-9]+章-(.*)\.md$/\1/')
        # 写入表格行，链接到实际章文件
        echo "| [第${chap_num}章 ${chap_name}](./$dir/$chap_file) | \`$chap_file\` |" >> "$tmp_file"
    done
    
    echo "" >> "$tmp_file"
    
    # 返回上级目录
    cd - > /dev/null
done

# 移动临时文件到最终输出
mv "$tmp_file" "$output"

echo "总目录已生成: $output"