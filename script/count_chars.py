#!/usr/bin/env python3
"""Count Chinese characters in a markdown file.
Usage: count_chars.py <file>
"""
import re, sys

def main():
    if len(sys.argv) < 2:
        print("Usage: count_chars.py <file>")
        sys.exit(1)
    with open(sys.argv[1], 'r', encoding='utf-8') as f:
        text = f.read()
    cc = len(re.findall(r'[\u4e00-\u9fff\u3400-\u4dbf]', text))
    lines = text.count('\n')
    print(f"Lines: {lines}")
    print(f"Chinese characters: {cc}")
    print(f"Under 5000: {'YES' if cc <= 5000 else 'NO, exceeded by ' + str(cc-5000)}")

if __name__ == '__main__':
    main()
