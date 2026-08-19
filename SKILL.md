---
name: interview-workbench
description: "面试工作台——秋招求职一站式工具。管理个人经历知识库、分析JD画像、生成简历草稿、岗位能力匹配、面试准备（硬技能复习+STAR问答打磨）、面试复盘归档。所有数据写入 data/workbench-data.js，配套 dashboard.html 提供集中看板。触发词：面试、求职、秋招、经历整理、JD分析、匹配度、简历草稿、面试准备、STAR、面试复盘、知识库、我的经历、岗位、投递。"
---

# 面试工作台

一站式秋招求职工具。把散落在各次对话里的求职进度集中到一个数据文件 + 一个看板页面。

```
对话完成 → Agent 按本 skill 规则梳理 → 增量写入 data/workbench-data.js
                                              ↓
                                    双击 dashboard.html → 浏览器看板
```

## 核心循环

```
录入经历 → JD分析 → 能力匹配 → 简历草稿 → 面试准备 → 面试复盘 → 重新录入...
```

---

## 三条共用铁律（每次对话必须遵守）

1. **绝不杜撰。** 所有经历、职责、数字必须来自用户真实提供的内容。可以引导、追问、帮用户把模糊的说清楚，但绝不编造公司、职位、成果或量化数字。**任何数字要向用户求证。**

2. **一次只问一个问题。** 收集经历、做匹配分析、准备面试都是对话，不是问卷。问一个 → 等回答 → 顺着追问。

3. **先结构化再产出。** 无论是经历还是简历，先落到标准数据字段，跟用户确认无误后再写入 data/workbench-data.js。

---

## 五条系统铁律（对应 PRD，Agent 每次对话必须理解并遵守）

**铁律一 · 经历入库必须闭环。** 任何新增经历必须追问行为、方法、结果三要素。若用户跳过，状态标为 `rough_pending`；补全至少两项标为 `complete`。

**铁律二 · 简历严禁胡编乱造。** 经历表里有什么字段就输出什么。缺失字段直接跳过不显示，绝不可用大模型润色扩写。

**铁律三 · 理论与经历绝对隔离。** 硬技能复习内容（原理/操作/概念）只缓存在岗位本地，绝不写入全局经历表。

**铁律四 · 依赖全局刷新机制。** 当任意经历被修改/覆盖/补充时，必须扫描所有引用了该经历的面试问答和简历草稿，提醒用户同步更新。

**铁律五 · 响应式干预匹配。** JD匹配时，若判定为"原理相似延伸"，必须弹出确认让用户手动点击"确认匹配"或"不匹配"，禁止自动强绑定。

---

## 路由：用户进来先判断意图

| 用户说的话 | 走哪个模块 |
|---|---|
| "录入经历" / "记一条经历" / "上传简历" / "我有段经历" | → 模块1 经历沉淀 [prompts/extract-experience.md](prompts/extract-experience.md) |
| "看看经历" / "知识库" / "我的经历列表" / "待完善" | → 先读 data/workbench-data.js 汇报 |
| "分析JD" / "帮我看看这个岗位" / "JD画像" / "只分析JD" | → 模块2 JD拆解与分析 [prompts/analyze-jd.md](prompts/analyze-jd.md) |
| 贴了JD文本/链接 / "全自动" / "一键跑完" / "继续跑<岗位>" | → 模块8 全自动流水线 [prompts/auto-pipeline.md](prompts/auto-pipeline.md)（**贴JD默认走流水线**，只想分析说"只分析JD"） |
| "生成简历" / "简历草稿" / "帮我做份简历" | → 模块3 简历生成 [prompts/generate-resume.md](prompts/generate-resume.md) |
| "匹配度" / "我和这个岗位差在哪" / "能力看板" | → 模块4 能力匹配 [prompts/match-requirements.md](prompts/match-requirements.md) |
| "准备面试" / "复习" / "面试问答" / "STAR" | → 模块5 面试准备 [prompts/prep-interview.md](prompts/prep-interview.md) |
| "面试复盘" / "刚面完" / "录音复盘" | → 模块6 面试复盘 [prompts/review-session.md](prompts/review-session.md) |
| "有没有矛盾" / "检查一下经历有没有冲突" | → 模块7 矛盾检测 [prompts/check-contradiction.md](prompts/check-contradiction.md) |
| "打开看板" / "工作台总览" | → 打开 dashboard.html 或在对话中汇报数据总览 |

判断不了就问一句：

> "你现在想做哪件事？
> · 📝 **录入经历**（记一段做过的事，或上传旧简历提取）
> · 🔍 **分析岗位**（贴 JD，看要求画像）
> · ⚡ **全自动流水线**（贴 JD 一键跑完：分析→匹配→简历→面试，中途可停）
> · 📊 **能力匹配**（看我的经历能覆盖 JD 多少）
> · 📄 **生成简历**（针对某个岗位出简历草稿）
> · 🎯 **准备面试**（硬技能复习 + STAR 问答打磨）
> · 🎙️ **面试复盘**（面完复盘，提取新经历）
> · 📋 **看板总览**（打开工作台看板）"

---

## 每次对话结束前：写入数据（硬性规定）

**这是本 skill 最核心的规则。** 每次和用户对话完成一个有效操作后，必须执行以下流程：

> **全自动流水线（模块8）例外：** 走流水线时，每个环节一完成就立即落库（checkpoint），而不是等对话结束一次性写。这样用户中途停在哪一环，已完成的部分都不丢。详见 [prompts/auto-pipeline.md](prompts/auto-pipeline.md)。

### 1. 梳理本次对话产出

判断本次对话是否有以下产出：
- 新增/修改/删除了经历 → 更新 `workbench-data.js` 的 `experiences` 数组
- 创建/更新了岗位 → 更新 `positions` 数组
- 生成了简历草稿 → 更新对应 position 的 `resumeDraft`
- 生成了面试问答 → 更新对应 position 的 `interviewQAs`
- 进行了面试复盘 → 更新 `reviewRecords` 数组
- 检测到经历矛盾 → 更新 `contradictionLogs` 数组

### 2. 读取并更新 data/workbench-data.js

```javascript
// 数据结构（不可改动 schema，只能往里面填数据）
const WORKBENCH = {
  meta: {
    version: "1.0",
    lastUpdated: "ISO时间戳",
    totalSessions: N
  },
  experiences: [
    {
      id: "exp_<timestamp>",
      title: "一句话标题",
      behavior: "具体做了什么（行为）",
      method: "怎么做的（方法/工具/手段）",
      result: "结果和影响（尽量量化）",
      type: "实习/项目/校园/其他",
      role: "担任角色",
      startDate: "YYYY-MM",
      endDate: "YYYY-MM",
      tags: ["标签1", "标签2"],
      status: "complete | rough_pending",
      version: 1,
      previousVersionId: null,
      createdAt: "ISO时间戳",
      updatedAt: "ISO时间戳"
    }
  ],
  positions: [
    {
      id: "pos_<timestamp>",
      name: "公司-岗位名",
      jdRawText: "JD原文摘要",
      jdSummary: {
        keywords: [
          { name: "关键词", weight: 20 }
        ],
        mustHave: ["硬性要求1", "硬性要求2"],
        niceToHave: ["加分项1"],
        hiddenSignals: ["信号1：自驱型团队 — JD反复出现ambiguity → 突出主动定义问题的故事"],
        levelInfer: "推断Level/团队阶段/汇报关系（基于JD措辞，每条标依据）",
        redFlags: ["红旗：JD列了12条must have — HM可能不知道自己要什么"]
      },
      requirements: [
        {
          id: "req_<timestamp>",
          text: "如：精通Python",
          status: "matched | short_term_fill | absolute_missing",
          score: 1.0,  // 1.0 | 0.5 | 0.0
          matchedExpIds: ["exp_xxx"],
          gapTier: "fixable | hard | irrelevant",  // 仅当 status ≠ matched
          gapFix: "具体补全建议",                   // 仅当 gapTier = "fixable"
          note: ""
        }
      ],
      interviewQAs: [
        {
          id: "qa_<timestamp>",
          category: "behavior | deep-dive | skill | company-specific",
          question: "面试问题",
          source: "Hidden Signal — ambiguity / Risk — 大厂→创业 / 匹配经历 — xxx",
          whyAsked: "为什么会问这道题的简短说明",
          prepDirection: "准备方向（框架，不给答案）",
          draftAnswer: "用户保存的最终版",
          aiGeneratedDraft: "AI生成的STAR初稿",
          referencedExpIds: ["exp_xxx"],
          createdAt: "ISO时间戳",
          updatedAt: "ISO时间戳"
        }
      ],
      resumeDraft: {
        content: "简历纯文本备份",
        htmlPath: "简历-<岗位名>-<日期>.html",
        referencedExpIds: ["exp_xxx"],
        generatedAt: "ISO时间戳"
      },
      matchResult: {
        score: "72-80%",
        tier: "强匹配",
        mustHaveScore: 0.75,
        niceToHaveScore: 0.6,
        hiddenSignalFit: 0.7,
        risks: [
          {
            dimension: "背景跨度",
            level: "中",
            concern: "HM可能担心大厂背景不适应小团队",
            probe: "HM会怎么问",
            response: "建议应对策略",
            relatedExpId: "exp_xxx"
          }
        ],
        assessedAt: "ISO时间戳"
      },
      skillCards: [
        {
          id: "skill_<timestamp>",
          name: "技能名",
          principle: "原理简述",
          completed: false
        }
      ],
      createdAt: "ISO时间戳",
      updatedAt: "ISO时间戳"
    }
  ],
  reviewRecords: [
    {
      id: "review_<timestamp>",
      positionId: "pos_xxx",
      date: "YYYY-MM-DD",
      transcript: "复盘文本摘要",
      evaluation: "评价",
      newExperiencesExtracted: ["exp_xxx"],
      createdAt: "ISO时间戳"
    }
  ],
  contradictionLogs: [
    {
      id: "contra_<timestamp>",
      newExpId: "exp_xxx",
      oldExpId: "exp_yyy",
      conflictField: "result | method | behavior",
      oldValue: "旧值",
      newValue: "新值",
      resolution: "overwrite | merge | pending_verify"
    }
  ],
  sessions: [
    {
      id: "session_<timestamp>",
      date: "YYYY-MM-DD",
      summary: "本次对话做了什么",
      modulesUsed: ["模块1", "模块4"],
      changes: [
        { action: "created", target: "experience", id: "exp_xxx", title: "..." },
        { action: "updated", target: "position", id: "pos_xxx", field: "requirements" }
      ]
    }
  ]
};
```

### 3. 写入规则

- **读取当前文件**（用 Read 工具读 `data/workbench-data.js`）
- **增量更新**：只修改变化的部分，保留其余内容不变
- **追加 session 日志**：在 `sessions` 数组末尾追加本次对话记录
- **更新时间戳**：更新 `meta.lastUpdated`
- **用 Write 工具写回**：整个文件回写

### 4. 写入后告知用户

> "✅ 本次内容已更新到工作台数据。
> · 变动：___（列举改了什么）
> · 📋 双击 `dashboard.html` 可在浏览器查看看板。"

---

## 参考文件（按需读取，别一次全加载）

### Prompts（8 个模块的执行引擎）
- [prompts/extract-experience.md](prompts/extract-experience.md) — 模块1：经历沉淀（三层追问引擎）
- [prompts/analyze-jd.md](prompts/analyze-jd.md) — 模块2：JD拆解与分析（五图层解码）
- [prompts/generate-resume.md](prompts/generate-resume.md) — 模块3：简历生成
- [prompts/match-requirements.md](prompts/match-requirements.md) — 模块4：能力匹配看板
- [prompts/prep-interview.md](prompts/prep-interview.md) — 模块5：面试准备（双子Tab）
- [prompts/review-session.md](prompts/review-session.md) — 模块6：面试复盘
- [prompts/check-contradiction.md](prompts/check-contradiction.md) — 模块7：矛盾检测
- [prompts/auto-pipeline.md](prompts/auto-pipeline.md) — 模块8：全自动流水线（贴JD一键串联四个环节，逐环节落库+断点续跑）

### Frameworks（知识词典 + 规则）
- [frameworks/competency-tags.md](frameworks/competency-tags.md) — 能力标签词典 + 反查
- [frameworks/match-rubric.md](frameworks/match-rubric.md) — 匹配度公式 + Gap三档 + Risk六维
- [frameworks/experience-schema.md](frameworks/experience-schema.md) — 经历三要素详细规范
- [frameworks/business-rules.md](frameworks/business-rules.md) — 五条铁律执行细则 + 状态机

### 模板
- [templates/resume-template.html](templates/resume-template.html) — 黑白ATS简历模板（仅此一套）
### 数据和看板
- [data/workbench-data.js](data/workbench-data.js) — 🏠 数据中心（唯一的数据源）
- [dashboard.html](dashboard.html) — 📋 工作台看板（浏览器打开即可）
