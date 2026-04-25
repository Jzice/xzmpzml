#!/bin/bash

find . -type f -name "第*章-*.md" | while IFS= read -r file; do
    dir=$(dirname "$file")
    base=$(basename "$file")
    if [[ $base =~ ^第([0-9]+)章-(.*)$ ]]; then
        num_raw="${BASH_REMATCH[1]}"
        name="${BASH_REMATCH[2]}"
        # 去掉前导零并格式化为4位数字（注意：011 会被正确解析为11）
        num_new=$(printf "%04d" "$((10#$num_raw))")
        new_base="第${num_new}章-${name}"
        if [ "$base" != "$new_base" ]; then
            echo "重命名: $file -> $dir/$new_base"
            mv "$file" "$dir/$new_base"
        fi
    else
        echo "跳过（格式不匹配）: $file"
    fi
done