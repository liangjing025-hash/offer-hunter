# 面试工作台（interview-workbench）

> 一站式秋招求职工具 —— 把散落在各次对话里的求职进度，集中到一个数据文件 + 一个看板页面。

一个 [Claude Code](https://claude.com/claude-code) 的 **skill**。你在对话里说「录入经历」「分析 JD」「生成简历」「准备面试」等触发词，Agent 就会按内置规则帮你梳理，并把结果增量写入 `data/workbench-data.js`，随时在 `dashboard.html` 看板里查看总览。

---

## 核心循环

```
录入经历 → JD分析 → 能力匹配 → 简历草稿 → 面试准备 → 面试复盘 → 重新录入...
```

---

## 功能模块（8 个）

| 模块 | 触发词 | 做什么 |
|---|---|---|
| 1 · 经历沉淀 | 录入经历 / 上传简历 | 三层追问引擎，把经历按「行为 · 方法 · 结果」结构化入库 |
| 2 · JD 拆解 | 分析 JD / JD 画像 | 五图层解码 JD，输出关键词、硬性要求、隐藏信号、红旗 |
| 3 · 简历生成 | 生成简历 / 简历草稿 | 严格按经历表字段产出 ATS 简历，不扩写、不杜撰 |
| 4 · 能力匹配 | 匹配度 / 能力看板 | 算匹配分，拆 Gap 三档 + Risk 六维 |
| 5 · 面试准备 | 准备面试 / STAR | 硬技能复习卡 + 预判面试题 STAR 初稿 |
| 6 · 面试复盘 | 面试复盘 / 刚面完 | 录音转写 → 评价 → 提取新经历 |
| 7 · 矛盾检测 | 有没有矛盾 | 检查经历之间的冲突 |
| 8 · 全自动流水线 | 贴 JD / 一键跑完 | 分析→匹配→简历→面试 四环节串联，逐环节落库 |

---

## 目录结构

```
interview-workbench/
├── SKILL.md              # skill 入口（含 name / description 元信息）
├── CLAUDE.md             # 项目说明（触发条件 + 铁律）
├── dashboard.html        # 工作台看板（双击浏览器打开）
├── data/
│   ├── workbench-data.example.js # 空模板（提交用）
│   └── workbench-data.js         # 🏠 数据中心（本地生成，不提交）
├── frameworks/           # 知识词典 + 规则（4 个）
├── prompts/              # 8 个模块的执行引擎
└── templates/            # 简历 HTML 模板（黑白 ATS）
```

---

## 安装

### 一句话安装（复制给你的 Agent）

```text
帮我安装面试工作台：https://raw.githubusercontent.com/<你的用户名>/<仓库名>/main/docs/install.md
```

复制这句话给你的 Agent，它几分钟内就会帮你装好这个 skill。

已装过？更新也只需一句话：

```text
帮我更新面试工作台：https://raw.githubusercontent.com/<你的用户名>/<仓库名>/main/docs/update.md
```

### 脚本安装

克隆仓库后，在仓库目录里运行：

```bash
./install.sh
```

Windows 用户可直接**双击 `install.bat`**。

不想用脚本，也可以手动执行一条命令：

**Git Bash / macOS / Linux**

```bash
mkdir -p ~/.claude/skills/interview-workbench/data && cp -r SKILL.md CLAUDE.md dashboard.html README.md frameworks prompts templates ~/.claude/skills/interview-workbench/ && cp data/workbench-data.example.js ~/.claude/skills/interview-workbench/data/workbench-data.js
```

**Windows PowerShell**

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills\interview-workbench\data" | Out-Null; Copy-Item SKILL.md,CLAUDE.md,dashboard.html,README.md "$env:USERPROFILE\.claude\skills\interview-workbench\"; Copy-Item frameworks,prompts,templates "$env:USERPROFILE\.claude\skills\interview-workbench\" -Recurse; Copy-Item data\workbench-data.example.js "$env:USERPROFILE\.claude\skills\interview-workbench\data\workbench-data.js"
```

### 手动安装

把本目录作为一个 skill 安装到 Claude Code：

```bash
# 用户级（所有项目可用）
cp -r job-skill ~/.claude/skills/interview-workbench

# 或 项目级（仅当前项目）
cp -r job-skill 你的项目/.claude/skills/interview-workbench
```

> Windows 用户级路径为 `C:\Users\<你的用户名>\.claude\skills\interview-workbench`。

首次使用前，先初始化数据文件（从模板复制一份）：

```bash
cp data/workbench-data.example.js data/workbench-data.js
```

安装后，在 Claude Code 里直接说「录入经历」「分析 JD」「准备面试」等触发词即可，无需手动加载。

---

## 使用

1. 对话中触发任意模块，Agent 会按 skill 规则梳理；
2. 每个有效操作后，自动增量写入 `data/workbench-data.js`；
3. 想查看总览：**双击 `dashboard.html`** 在浏览器打开看板。

---

## 设计铁律

**三条共用铁律**（对用户）：

1. **绝不杜撰** —— 所有经历、职责、数字必须来自用户真实提供的内容；
2. **一次只问一个问题** —— 对话式收集，不是问卷；
3. **先结构化再产出** —— 先落到标准数据字段，确认无误再写入。

**五条系统铁律**（对应 PRD，Agent 必须遵守）：经历入库必须闭环、简历严禁胡编乱造、理论与经历绝对隔离、依赖全局刷新机制、响应式干预匹配。详见 `SKILL.md`。

---

## ⚠️ 隐私提示

本仓库**不含任何个人数据**：`data/workbench-data.example.js` 是空模板；真正的 `data/workbench-data.js` 由你本地从模板复制生成，且已被 `.gitignore` 忽略，**不会被提交**。

你在本地使用过程中产生的数据（个人经历、简历草稿、面试复盘）都会写入 `data/workbench-data.js`。该文件以及 `transcript.json`、`简历-*.html`、音视频文件均已加入 `.gitignore`，正常 `git add .` 不会提交它们。切勿用 `git add -f` 强推这些文件到公开仓库。

---

## License

按需添加（如 `MIT`）。
