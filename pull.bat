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

echo [信息] 正在通过 Git Bash 拉取最新代码...
"%GIT_BASH_EXE%" -lc "git pull"
set "PULL_EXIT_CODE=%ERRORLEVEL%"

if "%PULL_EXIT_CODE%"=="0" (
    echo [完成] git pull 执行成功。
) else (
    echo [失败] git pull 执行失败，退出码：%PULL_EXIT_CODE%
    echo 请检查本地修改、合并冲突或远程仓库权限。
)

pause
exit /b %PULL_EXIT_CODE%
