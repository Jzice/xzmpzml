#!/bin/bash

# 总输出文件
output="README.md"

# 临时文件
tmp_file=$(mktemp)

# 写入文件头
{
    echo "# 修真门派掌门路"
    echo ""
    echo "## 总目录"
    echo ""
} > "$tmp_file"

# 获取所有卷目录并排序（自然排序：第001卷、第002卷...）
# 注意：find 输出的路径以 "./" 开头，需要去除
for dir in $(find . -maxdepth 1 -type d -name "第*卷-*" | sed 's|^\./||' | sort -V); do
    # 生成卷标题：将目录名中的第一个连字符替换为空格
    volume_title="${dir/-/ }"
    
    # 写入卷的一级列表项（无序列表，缩进2空格作为列表标记）
    echo "### ${volume_title}" >> "$tmp_file"
    
    # 进入卷目录
    cd "$dir" || continue
    
    # 收集章文件，并按版本号排序（支持第0001章等）
    shopt -s nullglob
    chap_files=(第*.md)
    # 如果目录下没有章文件，跳过
    if [ ${#chap_files[@]} -eq 0 ]; then
        cd - > /dev/null
        continue
    fi
    
    # 使用 sort -V 排序（确保数字顺序）
    IFS=$'\n' sorted=($(printf "%s\n" "${chap_files[@]}" | sort -V))
    unset IFS
    
    for chap_file in "${sorted[@]}"; do
        # 提取章号：使用 sed 或 bash 内置
        # 方法：删除 "第" 前缀，再删除 "章-..." 后缀
        chap_num="${chap_file#第}"
        chap_num="${chap_num%%章-*}"
        # 提取章名：删除 "第...章-" 前缀，删除 .md 后缀
        chap_name="${chap_file#第*章-}"
        chap_name="${chap_name%.md}"
        
        # 写入二级列表项（缩进4空格，即两个列表层级的缩进）
        echo "- [第${chap_num}章 ${chap_name}](./${dir}/${chap_file})" >> "$tmp_file"
    done
    
    echo "" >> "$tmp_file"
    
    # 返回上级目录
    cd - > /dev/null
done

# 移动临时文件到最终输出
mv "$tmp_file" "$output"

echo "总目录已生成: $output"
