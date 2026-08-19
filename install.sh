#!/usr/bin/env bash
# 一键安装：把本 skill 装到用户级 Claude Code 技能目录
# 用法：在仓库根目录运行  ./install.sh
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${HOME}/.claude/skills/interview-workbench"

echo "============================================"
echo " 面试工作台（interview-workbench）一键安装"
echo "============================================"
echo "源目录:   ${SRC}"
echo "目标目录: ${TARGET}"
echo ""

if [ -d "${TARGET}" ]; then
  read -r -p "已存在 ${TARGET}，覆盖安装？[y/N] " ans
  case "${ans}" in
    [yY]* ) rm -rf "${TARGET}" ;;
    * ) echo "已取消"; exit 0 ;;
  esac
fi

mkdir -p "${TARGET}/data"

# 复制 skill 文件（不含 .git、安装脚本、简历等）
for item in SKILL.md CLAUDE.md dashboard.html README.md frameworks prompts templates; do
  cp -r "${SRC}/${item}" "${TARGET}/"
done

# 初始化数据文件：从空模板复制出 workbench-data.js
cp "${SRC}/data/workbench-data.example.js" "${TARGET}/data/workbench-data.js"

echo ""
echo "✅ 安装完成：${TARGET}"
echo "现在打开 Claude Code，说「录入经历」「分析JD」即可使用。"
