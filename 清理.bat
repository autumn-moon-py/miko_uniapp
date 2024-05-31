@echo off
setlocal

REM 设置要复制到剪贴板的文本
set "text=flutter clean"

REM 将文本复制到剪贴板
echo %text% | clip

:: 获取脚本所在目录
set "script_dir=%~dp0"

:: 创建一个VBS脚本来请求管理员权限
set "elevate_vbs=%temp%\elevate.vbs"
echo Set UAC = CreateObject^("Shell.Application"^)>"%elevate_vbs%"
echo UAC.ShellExecute "cmd.exe", "/k cd /d ""%script_dir%""", "", "runas", 1 >>"%elevate_vbs%"

:: 运行VBS脚本以获取管理员权限
cscript "%elevate_vbs%"

:: 删除临时VBS脚本文件
del "%elevate_vbs%"



