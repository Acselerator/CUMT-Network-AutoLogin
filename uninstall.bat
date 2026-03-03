@echo off
title 矿大校园网自动登录 - 一键卸载程序

:: ================= 自动请求管理员权限 =================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 正在请求管理员权限...
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b
)
cd /d "%~dp0"
:: ======================================================

echo ========================================================
echo       CUMT 校园网自动登录 - 卸载程序
echo ========================================================
echo.
set /p confirm="确定要卸载自动登录功能吗？(Y/N): "
if /i "%confirm%" NEQ "Y" (
    echo 已取消卸载。
    pause >nul
    exit
)
echo.

:: 1. 删除系统任务计划 (注意：这里的名字要和 install 里的保持一致)
echo [1/2] 正在清理系统后台任务...
schtasks /delete /tn "CUMT_Net_AutoLogin" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo  - 任务清理成功！
) else (
    echo  - 任务不存在或已清理。
)

:: 2. 删除同目录下的 login.bat
echo [2/2] 正在删除核心脚本文件...
if exist "login.bat" (
    del "login.bat"
    echo  - 脚本删除成功！
) else (
    echo  - 未找到 login.bat，可能已被移除。
)

echo.
echo ========================================================
echo 卸载完成！
echo 你的系统已恢复原状，你可以安全地删除当前文件夹了。
echo ========================================================
pause