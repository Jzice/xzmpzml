#!/bin/bash

# 检查是否提供了输入文件
if [ $# -eq 0 ]; then
    echo "用法: $0 <markdown文件>"
    echo "示例: $0 book.md"
    exit 1
fi

input="$1"

# 检查文件是否存在
if [ ! -f "$input" ]; then
    echo "错误: 文件 '$input' 不存在"
    exit 1
fi

awk '
/^## .*卷/ {
    # 遇到卷标题：关闭上一个文件，创建新文件
    if (out != "") close(out)
    
    # 提取卷号（如 001）和卷名（如 飘零之中掌教门）
    # 匹配格式：## 第001卷 飘零之中掌教门
    vol_num = gensub(/^## 第([0-9]+)卷.*/, "\\1", "g", $0)
    vol_name = gensub(/^## 第[0-9]+卷 (.*)/, "\\1", "g", $0)
    
    # 生成文件名：第001卷-飘零之中掌教门.md
    out = sprintf("%s-%s.md", "第" vol_num "卷", vol_name)
    print "创建文件: " out > "/dev/stderr"
    print $0 > out
    next
}
{
    # 普通内容追加到当前卷文件
    if (out != "") print $0 >> out
}
' "$input"

echo "分割完成！"