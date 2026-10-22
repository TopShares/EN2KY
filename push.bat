@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions

rem 切换到批处理文件所在目录，确保在当前仓库根目录执行。
cd /d "%~dp0"

if not exist ".git" (
    echo [错误] 当前目录不是 Git 仓库：%CD%
    pause
    exit /b 1
)

set "GIT_BASH_EXE="
if exist "%ProgramFiles%\Git\bin\bash.exe" set "GIT_BASH_EXE=%ProgramFiles%\Git\bin\bash.exe"
if not defined GIT_BASH_EXE if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" set "GIT_BASH_EXE=%ProgramFiles(x86)%\Git\bin\bash.exe"

rem Git 也可能安装在非系统盘，从 git.exe 的位置推导 Git Bash 路径。
if not defined GIT_BASH_EXE (
    for /f "delims=" %%G in ('where git.exe 2^>nul') do (
        if not defined GIT_BASH_EXE if exist "%%~dpG..\bin\bash.exe" set "GIT_BASH_EXE=%%~dpG..\bin\bash.exe"
    )
)

if not exist "%GIT_BASH_EXE%" (
    echo [错误] 未找到 Git Bash。
    echo 请确认已安装 Git for Windows，或修改脚本中的 Git Bash 路径。
    pause
    exit /b 1
)

echo [信息] 正在添加本地变更并提交...
"%GIT_BASH_EXE%" -lc "git add -A && (git diff --cached --quiet || git commit -m '.')"
set "COMMIT_EXIT_CODE=%ERRORLEVEL%"

if not "%COMMIT_EXIT_CODE%"=="0" (
    echo [失败] 添加或提交本地变更失败，退出码：%COMMIT_EXIT_CODE%
    pause
    exit /b %COMMIT_EXIT_CODE%
)

echo [信息] 正在拉取远端最新代码，推送前先执行 git pull --rebase...
"%GIT_BASH_EXE%" -lc "git pull --rebase"
set "PULL_EXIT_CODE=%ERRORLEVEL%"

if not "%PULL_EXIT_CODE%"=="0" (
    echo [暂停] 拉取远端最新代码失败，已停止推送。
    echo [提示] 如果拉取过程中出现冲突，请人工解决冲突后执行 git add 文件名，再执行 git rebase --continue。
    echo [提示] 如果不是冲突，请根据上面的错误信息人工处理拉取失败原因。
    "%GIT_BASH_EXE%" -lc "git status --short"
    pause
    exit /b %PULL_EXIT_CODE%
)

echo [信息] 远端代码已同步，正在推送本地提交...
"%GIT_BASH_EXE%" -lc "git push"
set "PUSH_EXIT_CODE=%ERRORLEVEL%"

if "%PUSH_EXIT_CODE%"=="0" (
    echo [完成] 提交、拉取并推送成功。
) else (
    echo [失败] 推送失败，退出码：%PUSH_EXIT_CODE%
)

pause
exit /b %PUSH_EXIT_CODE%
