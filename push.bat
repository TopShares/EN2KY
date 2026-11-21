@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions DisableDelayedExpansion

rem 切换到批处理文件所在目录，确保始终在当前仓库根目录执行。
cd /d "%~dp0"

if not exist ".git" (
    echo([错误] 当前目录不是 Git 仓库：%CD%
    pause
    exit /b 1
)

where git.exe >nul 2>&1
if errorlevel 1 (
    echo([错误] 未找到 git.exe，请先安装 Git for Windows 并确认已加入 PATH。
    pause
    exit /b 1
)

echo([信息] 正在添加本地变更并提交...
git add -A
if errorlevel 1 (
    echo([失败] 添加本地变更失败。
    pause
    exit /b 1
)

git diff --cached --quiet
if errorlevel 1 (
    git commit -m "."
    if errorlevel 1 (
        echo([失败] 提交本地变更失败。
        pause
        exit /b 1
    )
) else (
    echo([信息] 没有新的本地变更需要提交。
)

echo([信息] 正在拉取远端最新代码，推送前先执行 git pull --rebase...
git pull --rebase
if errorlevel 1 (
    echo([暂停] 拉取远端最新代码失败，已停止推送。
    echo([提示] 当前远端地址：
    git remote get-url origin
    echo([提示] 如果上方显示 403，请先登录拥有该仓库写权限的 GitHub 账号：
    echo(        gh auth login -h github.com
    echo([提示] 登录后可用以下命令确认当前账号：
    echo(        gh auth status
    echo([提示] 如果是冲突，请解决冲突后执行 git add 文件名，再执行 git rebase --continue。
    echo([提示] 当前仓库状态：
    git status --short --branch
    pause
    exit /b 1
)

echo([信息] 远端代码已同步，正在推送本地提交...
git push
if errorlevel 1 (
    echo([失败] 推送失败，请检查 GitHub 账号权限或远端地址。
    pause
    exit /b 1
)

echo([完成] 提交、拉取并推送成功。
pause
exit /b 0
