# -*- coding: utf-8 -*-
import os
import glob

def get_chapters(volume_num):
    """Get all chapter files for a volume in order"""
    # Find the volume directory
    pattern = f"第{volume_num:03d}卷-*"
    dirs = glob.glob(pattern)
    if not dirs:
        return []

    vol_dir = dirs[0]
    # Get all chapter files (.md but not README)
    chapters = [f for f in os.listdir(vol_dir) if f.endswith('.md') and f != 'README.md']
    chapters.sort()
    return [(vol_dir, ch) for ch in chapters]

def merge_volumes(volumes, output_path, header):
    """Merge multiple volumes into one file"""
    content = header

    for v in volumes:
        # Add volume name
        vol_dirs = glob.glob(f"第{v:03d}卷-*")
        if vol_dirs:
            readme_path = os.path.join(vol_dirs[0], 'README.md')
            if os.path.exists(readme_path):
                with open(readme_path, 'r', encoding='utf-8') as f:
                    first_line = f.readline().strip()
                    # Remove BOM if present
                    if first_line.startswith('\ufeff'):
                        first_line = first_line[1:]
                    content += '\n' + first_line + '\n\n'

            # Add chapters
            chapters = get_chapters(v)
            for vol_dir, ch in chapters:
                ch_path = os.path.join(vol_dir, ch)
                with open(ch_path, 'r', encoding='utf-8') as f:
                    ch_content = f.read()
                    content += ch_content + '\n\n'

    # Write output
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(content)

# Change to novel directory
os.chdir(r'D:\doc\zml\修真门派掌门路')

# Header
header = """# 修真门派掌门路

> **作者**：齐可休
> **类型**：仙侠·修真
> **状态**：连载中
> **总章节数**：697章
> **总卷数**：25卷

---

"""

# 001-010卷
print("Merging 001-010卷...")
merge_volumes(list(range(1, 11)), r'D:\doc\zml\修真门派掌门路_第01-10卷_分卷目录合并.md', header)
print("Created 修真门派掌门路_第01-10卷_分卷目录合并.md")

# 011-020卷
print("Merging 011-020卷...")
merge_volumes(list(range(11, 21)), r'D:\doc\zml\修真门派掌门路_第11-20卷_分卷目录合并.md', header)
print("Created 修真门派掌门路_第11-20卷_分卷目录合并.md")

# 021-025卷
print("Merging 021-025卷...")
merge_volumes(list(range(21, 26)), r'D:\doc\zml\修真门派掌门路_第21-25卷_分卷目录合并.md', header)
print("Created 修真门派掌门路_第21-25卷_分卷目录合并.md")

print("All done!")