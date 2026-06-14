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
│   ├── 档案资料/              # Characters & factions（角色档案系统）
│   │   ├── README.md          # Root index with character tables + directory tree
│   │   ├── 001.齐云/           # 齐云派 (超级宗门)
│   │   │   ├── 人物/05.化神/       # 角色档案，按修为等级划分
│   │   │   ├── 山峰/               # 齐云各大山峰
│   │   │   ├── 商户/               # 齐云商会
│   │   │   └── 家族门派/           # 家族、附属门派、修真城市
│   │   ├── 000.楚秦门/           # 楚秦门（独立一级目录）
│   │   ├── 002.白山/           # 白山势力
│   │   │   ├── 人物/             # 角色档案（含非楚秦门角色）
│   │   │   ├── 白山五行盟/
│   │   │   ├── 九星坊/陵梁宗/
│   │   │   └── 其他/
│   │   ├── 003.御兽门/
│   │   ├── 004.大周书院/
│   │   ├── 005.黑风谷/
│   │   ├── 006.青莲剑宗/
│   │   ├── 007.南林寺/
│   │   ├── 008.外海/
│   │   ├── 009.蛮荒/醒狮谷/
│   │   ├── 010.天理门/
│   │   ├── 011.稷下城/
│   │   ├── 012.明阳山/
│   │   ├── 013.阳明山/
│   │   ├── 014.其他/摘星阁/
│   │   └── 015.散修/
│   ├── 地图集/               # Maps
│   ├── 大纲.md               # Outline by volume
│   └── README.md              # Volume index
└── README.md                # Root reference (huijiwiki link)
```

### 档案资料目录约定

- **顶级目录**: 按势力划分（楚秦门、齐云、白山、御兽门、大周书院等），每个顶级势力含 README.md 概览
- **二级目录**: 按势力内部结构（山峰/家族/商会/附属/五行盟/其他等）
- **三级目录**: 按修为境界（化神/元婴/金丹/筑基/练气/凡人）
- **角色文件命名**: `[编号]-[姓名].md`（如 `100-蔡渊.md`），部分无编号角色仅用姓名（如 `蓝隶.md`）
- **README.md**: 每个势力目录都有 README.md，包含势力概况、角色档案索引、设定关联

### Agent 目录浏览规则

**每个目录都应包含 README.md 文件**，作为该目录的索引和概览。

README.md 应包含：
- 本目录基本信息（名称、类型、说明）
- 目录内子内容索引（列表或表格形式）
- 关联说明（与其他目录的关系）

**Agent 扫描目录时的标准流程**：
1. **先读 README.md** — 快速了解目录结构和基本信息
2. **再按需查看子内容** — 根据任务需求深入检查具体文件
3. **不要跳过 README 直接扫描文件** — README 提供的上下文能避免误判和遗漏

此规则适用于所有目录，尤其是：
- `档案资料/` 及其子目录
- `设定/` 目录
- 各卷目录（`第0XX卷-卷名/`）

### 角色文件模板

每个角色文件按此结构组织：
```
# 姓名
## 基本信息（姓名/性别/修为/本命/势力/首次出现/现状）
## 角色关系（所属/师承/相关人物）
## 主要事迹（分卷按章节梳理）
## 修为特点
## 主要事件时间线
## 势力范围归属（势力范围/门派/职务）
## 设定关联
## 备注
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
