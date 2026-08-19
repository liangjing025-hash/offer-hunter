# 面试工作台（interview-workbench）

本项目是「面试工作台」skill 的主目录。**每次在本目录对话，先读 `SKILL.md` 并严格按其工作流执行**——不要用通用方式回答求职/简历/面试类问题。

## 触发条件（命中即走对应模块，而非自由发挥）

用户提到以下词之一 → 查 SKILL.md「路由」表，走对应模块：

面试 · 求职 · 秋招 · 经历整理/录入 · JD分析 · 匹配度 · 简历草稿/生成简历 · 面试准备/STAR/复习 · 面试复盘 · 知识库/我的经历 · 岗位 · 投递

## 最核心的一条铁律（必须遵守）

每次对话完成一个有效操作后，**必须增量写入 `data/workbench-data.js`**：

1. 更新 `positions` / `experiences` / `reviewRecords` / `contradictionLogs` 等对应数组
2. 在 `sessions` 末尾追加本次对话记录
3. 更新 `meta.lastUpdated`（及 `totalSessions`）
4. 写入后告知用户变动内容

其余铁律（不杜撰、一次只问一个问题、先结构化再产出、五条系统铁律）详见 `SKILL.md`。

## 数据与看板

- 数据中心（唯一数据源）：`data/workbench-data.js`
- 看板：双击 `dashboard.html` 在浏览器打开
