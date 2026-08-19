@echo off
chcp 65001 >nul
setlocal
echo ============================================
echo  面试工作台（interview-workbench）一键安装
echo ============================================

set "SRC=%~dp0"
set "TARGET=%USERPROFILE%\.claude\skills\interview-workbench"

if not exist "%USERPROFILE%\.claude\skills" mkdir "%USERPROFILE%\.claude\skills"

if exist "%TARGET%" (
    echo [!] 目标已存在，将覆盖安装。
    pause
    rmdir /s /q "%TARGET%"
)

mkdir "%TARGET%"
mkdir "%TARGET%\data"

echo 正在复制文件...
xcopy "%SRC%SKILL.md" "%TARGET%\" /y >nul
xcopy "%SRC%CLAUDE.md" "%TARGET%\" /y >nul
xcopy "%SRC%dashboard.html" "%TARGET%\" /y >nul
xcopy "%SRC%README.md" "%TARGET%\" /y >nul
xcopy "%SRC%frameworks" "%TARGET%\frameworks\" /e /i /y >nul
xcopy "%SRC%prompts" "%TARGET%\prompts\" /e /i /y >nul
xcopy "%SRC%templates" "%TARGET%\templates\" /e /i /y >nul
copy "%SRC%data\workbench-data.example.js" "%TARGET%\data\" >nul
copy "%TARGET%\data\workbench-data.example.js" "%TARGET%\data\workbench-data.js" >nul

echo.
echo ✅ 安装完成！
echo    目标目录：%TARGET%
echo    现在打开 Claude Code，说「录入经历」「分析JD」即可使用。
echo.
pause
