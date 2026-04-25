# 修真门派掌门路 - AGENTS.md

## Repository Nature

**NOT a software project.** This is a Chinese web novel (仙侠/修真小说) document repository.

- **Author**: 齐可休
- **Status**: 连载中 (ongoing)
- **Total Chapters**: 697 (ongoing into 卷25)
- **Type**: 仙侠·修真 (Xianxia/cultivation fantasy)

## Structure

```
├── md/修真门派掌门路_001-697.md           # Consolidated full novel (all chapters)
├── txt/修真门派掌门路_原文_齐可休-001_697.txt  # Raw original text dump
├── md/
│   ├── 第0XX卷-卷名/         # Per-volume chapters (1 file per chapter)
│   ├── 设定/                  # World-building settings (lore)
│   ├── 番外/                 # Side stories
│   ├── 人物势力/              # Characters & factions
│   ├── 地图集/               # Maps
│   ├── 大纲.md               # Outline by volume
│   └── README.md              # Volume index
└── README.md                # Root reference (huijiwiki link)
```

## Conventions

- **Chapter naming**: `第XXX章-章名.md` (e.g., `第697章-后颈的尸斑.md`)
- **Volume naming**: `第0X卷-卷名/` (e.g., `第025卷-美人恩重元婴成/`)
- **Settings files**: World-building docs in `设定/` folder

## Content Discovery

- **Main reference**: https://zml.huijiwiki.com/wiki/首页 (huijiwiki)
- **Search by character**: Find chapter files directly; novel uses straightforward Chinese prose
- **Chapter sequence**: Files in each volume folder are sequential by chapter number

## Operations

This is a passive document repository. There are no build scripts, tests, or CI workflows.

- No developer commands needed
- No lint/typecheck/tests
- Just organize and maintain documents
- Edit prose in Chinese markdown files using standard text editors

## graphify

This project has a graphify knowledge graph at graphify-out/.

Rules:
- Before answering architecture or codebase questions, read graphify-out/GRAPH_REPORT.md for god nodes and community structure
- If graphify-out/wiki/index.md exists, navigate it instead of reading raw files
- After modifying code files in this session, run `graphify update .` to keep the graph current (AST-only, no API cost)
