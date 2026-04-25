#!/bin/bash

if [ $# -eq 0 ]; then
    echo "用法: $0 <markdown文件>"
    exit 1
fi

file="$1"
if [ ! -f "$file" ]; then
    echo "错误: 文件 '$file' 不存在"
    exit 1
fi

# 使用 awk 处理：当上一行非空且当前行非空时，先输出空行再输出当前行
awk '
BEGIN { prev_nonempty = 0 }
{
    if (prev_nonempty && NF > 0) {
        print ""   # 插入空行
    }
    print $0
    prev_nonempty = (NF > 0)
}
' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"

echo "处理完成: $file"