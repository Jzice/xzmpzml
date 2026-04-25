#!/bin/bash

for dir in 第*卷-*/; do
    dir="${dir%/}"
    [ -d "$dir" ] || continue
    echo "处理目录: $dir"
    cd "$dir" || continue

    volume_title="${dir/-/ }"

    {
        echo "## $volume_title"
        echo ""
        echo "### 目录"
        echo ""
        for chap_file in $(ls -v 第*.md 2>/dev/null); do
            # 使用 sed 提取章号（兼容 GNU/BSD sed）
            chap_num=$(echo "$chap_file" | sed -nE 's/^第([0-9]+)章-.*/\1/p')
            # 提取章名
            chap_name=$(echo "$chap_file" | sed -E 's/^第[0-9]+章-(.*)\.md$/\1/')
            echo "- [第${chap_num}章 ${chap_name}](./${chap_file})"
        done
    } > README.md

    cd - > /dev/null
    echo "已生成: $dir/README.md"
done

echo "完成。"
