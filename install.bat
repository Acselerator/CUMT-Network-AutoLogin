@echo off
title 矿大校园网自动登录 - 一键安装程序

:: ================= 1. 自动请求管理员权限 =================
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
:: =========================================================

echo ========================================================
echo       欢迎使用 CUMT 校园网自动登录配置脚本
echo       (支持学生端 CUMT_Stu 与 教师端 CUMT_Tec)
echo ========================================================
echo.
echo 【重要警告：请确认本脚本的位置！】
echo 本安装程序会直接在【当前目录】下生成核心登录脚本。
echo 当前路径为: %~dp0
echo.
echo 如果你现在是在“桌面”、“下载”或“压缩包内”直接运行的，
echo 请立刻关闭本窗口！将脚本移动到一个长期的、不会被随手删除的文件夹
echo （例如 D:\Tools\CUMT_Net_AutoLogin\）后再重新运行。
echo ========================================================
set /p confirm="确认当前目录安全，继续安装请按 Y，退出请按 N (Y/N): "
if /i "%confirm%" NEQ "Y" (
    echo 已取消安装，按任意键退出...
    pause >nul
    exit
)
echo.

:: 2. 获取用户账号密码
set /p stuid_base="请输入你的【纯学号/工号】: "
set /p pwd="请输入你的【校园网密码】: "

:: 3. 交互式选择运营商
echo.
echo ==================================
echo 请选择你开通的校园网运营商：
echo [1] 纯校园网 (无后缀)
echo [2] 中国电信 (@telecom)
echo [3] 中国移动 (@cmcc)
echo [4] 中国联通 (@unicom)
echo ==================================
set /p op_choice="请输入对应数字 (1/2/3/4): "

:: 根据选择分配后缀
set "suffix="
if "%op_choice%"=="2" set "suffix=@telecom"
if "%op_choice%"=="3" set "suffix=@cmcc"
if "%op_choice%"=="4" set "suffix=@unicom"

:: 拼接最终账号
set "stuid=%stuid_base%%suffix%"
echo.
echo 你的最终登录账号已生成为: 【%stuid%】
echo.

:: 4. 设定安装目录为当前目录
set "INSTALL_DIR=%~dp0"
set "SCRIPT_PATH=%INSTALL_DIR%login.bat"
set "XML_PATH=%INSTALL_DIR%task.xml"

:: 5. 动态生成核心登录脚本 (增加 curl 断网重试机制)
echo [1/3] 正在生成自动登录脚本...
> "%SCRIPT_PATH%" echo @echo off
>>"%SCRIPT_PATH%" echo curl --retry 2 --retry-delay 3 -X POST "http://10.2.5.251:801/eportal/?c=ACSetting&a=Login" -d "DDDDD=%stuid%" -d "upass=%pwd%" -d "R1=0" -d "R2=0" -d "R3=0" -d "R6=0" -d "para=00" -d "0MKKey=123456"
>>"%SCRIPT_PATH%" echo exit

:: 6. 动态生成任务计划的 XML 配置文件 (开机唤醒延迟延长至5秒)
echo [2/3] 正在生成系统任务配置...
> "%XML_PATH%" echo ^<?xml version="1.0" encoding="UTF-16"?^>
>>"%XML_PATH%" echo ^<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^>
>>"%XML_PATH%" echo   ^<Triggers^>
>>"%XML_PATH%" echo     ^<EventTrigger^>
>>"%XML_PATH%" echo       ^<Enabled^>true^</Enabled^>
>>"%XML_PATH%" echo       ^<Subscription^>^&lt;QueryList^&gt;^&lt;Query Id="0" Path="Microsoft-Windows-NetworkProfile/Operational"^&gt;^&lt;Select Path="Microsoft-Windows-NetworkProfile/Operational"^&gt;*[System[(EventID=10000)]] and *[EventData[(Data[@Name='Name']='CUMT_Stu' or Data[@Name='Name']='CUMT_Tec')]]^&lt;/Select^&gt;^&lt;/Query^&gt;^&lt;/QueryList^&gt;^</Subscription^>
>>"%XML_PATH%" echo       ^<Delay^>PT5S^</Delay^>
>>"%XML_PATH%" echo     ^</EventTrigger^>
>>"%XML_PATH%" echo     ^<LogonTrigger^>
>>"%XML_PATH%" echo       ^<Enabled^>true^</Enabled^>
>>"%XML_PATH%" echo       ^<Delay^>PT5S^</Delay^>
>>"%XML_PATH%" echo     ^</LogonTrigger^>
>>"%XML_PATH%" echo     ^<SessionStateChangeTrigger^>
>>"%XML_PATH%" echo       ^<Enabled^>true^</Enabled^>
>>"%XML_PATH%" echo       ^<StateChange^>SessionUnlock^</StateChange^>
>>"%XML_PATH%" echo       ^<Delay^>PT5S^</Delay^>
>>"%XML_PATH%" echo     ^</SessionStateChangeTrigger^>
>>"%XML_PATH%" echo   ^</Triggers^>
>>"%XML_PATH%" echo   ^<Principals^>
>>"%XML_PATH%" echo     ^<Principal id="Author"^>
>>"%XML_PATH%" echo       ^<UserId^>S-1-5-18^</UserId^>
>>"%XML_PATH%" echo       ^<RunLevel^>HighestAvailable^</RunLevel^>
>>"%XML_PATH%" echo     ^</Principal^>
>>"%XML_PATH%" echo   ^</Principals^>
>>"%XML_PATH%" echo   ^<Settings^>
>>"%XML_PATH%" echo     ^<MultipleInstancesPolicy^>StopExisting^</MultipleInstancesPolicy^>
>>"%XML_PATH%" echo     ^<DisallowStartIfOnBatteries^>false^</DisallowStartIfOnBatteries^>
>>"%XML_PATH%" echo     ^<StopIfGoingOnBatteries^>false^</StopIfGoingOnBatteries^>
>>"%XML_PATH%" echo     ^<ExecutionTimeLimit^>PT1M^</ExecutionTimeLimit^>
>>"%XML_PATH%" echo     ^<Hidden^>true^</Hidden^>
>>"%XML_PATH%" echo   ^</Settings^>
>>"%XML_PATH%" echo   ^<Actions Context="Author"^>
>>"%XML_PATH%" echo     ^<Exec^>
>>"%XML_PATH%" echo       ^<Command^>%SCRIPT_PATH%^</Command^>
>>"%XML_PATH%" echo     ^</Exec^>
>>"%XML_PATH%" echo   ^</Actions^>
>>"%XML_PATH%" echo ^</Task^>

:: 7. 调用 schtasks 导入 XML 并创建任务
echo [3/3] 正在向 Windows 注册系统任务...
schtasks /create /tn "CUMT_Net_AutoLogin" /xml "%XML_PATH%" /f

:: 8. 清理 XML 临时文件
del "%XML_PATH%"

echo.
echo ========================================================
echo 安装圆满完成！
echo 核心脚本已生成在: %SCRIPT_PATH%
echo.
echo 以后连上 CUMT_Stu 或 CUMT_Tec，Windows 会在后台彻底静默完成认证。
echo （请妥善保管当前文件夹，不要随意删除或重命名）
echo ========================================================
pause
