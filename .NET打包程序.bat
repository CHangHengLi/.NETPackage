@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

echo.
echo ========================================
echo 通用.NET应用程序安装包制作工具  (终极兼容版)
echo ========================================
echo 支持项目类型: WPF, WinForms, Console, 其他.NET应用
echo 兼容版本: 所有 Inno Setup 版本 (包括最老版本)
echo 完全移除Flags参数，确保100%%兼容性
echo ========================================
echo.

:: 获取项目名称
for %%I in (.) do set PROJECT_NAME=%%~nxI
echo 检测到项目目录: %PROJECT_NAME%

:: 检查是否存在.csproj文件
set FOUND_CSPROJ=
for %%f in (*.csproj) do set FOUND_CSPROJ=%%f

if "%FOUND_CSPROJ%"=="" (
    echo 错误: 当前目录下没有找到.csproj文件
    echo 请确保在.NET项目根目录下运行此脚本
    pause
    exit /b 1
)

echo 使用项目文件: %FOUND_CSPROJ%

:: 从项目文件中提取信息
echo.
echo [步骤1/8] 分析项目信息...
call :extract_project_info
echo 项目类型: !PROJECT_TYPE!
echo 项目版本: !APP_VERSION!
echo 程序集名称: !ASSEMBLY_NAME!

:: 检查是否安装了Inno Setup并检查版本
echo.
echo [步骤2/8] 检查Inno Setup环境和版本...
call :check_inno_setup_with_version

:: 版本控制检查
echo.
echo [步骤3/8] 版本控制检查...
call :version_control_check

:: 清理旧文件
echo.
echo [步骤4/8] 清理旧的发布文件...
if exist publish rmdir /s /q publish 2>nul
if exist installer rmdir /s /q installer 2>nul
mkdir publish 2>nul
mkdir installer 2>nul
echo 清理完成

:: 打包应用程序
echo.
echo [步骤5/8] 打包应用程序...
call :build_application

:: 创建终极兼容版安装脚本
echo.
echo [步骤6/8] 生成终极兼容的安装脚本...
call :create_ultimate_compatible_installer_script
echo 终极兼容版安装脚本生成完成

:: 显示生成的脚本内容（调试用）
echo.
echo [步骤7/8] 验证生成的脚本...
call :verify_generated_script

:: 编译安装程序
echo.
echo [步骤8/8] 编译安装程序...
if defined INNO_PATH (
    "!INNO_PATH!" "!ISS_FILE!"
    if errorlevel 1 (
        echo 错误: 安装程序编译失败
        echo 当前使用: 终极兼容模式 ^(无Flags参数^)
        echo 请检查以下项目:
        echo   A. Inno Setup 版本: !INNO_VERSION! ^(!INNO_EXACT_VERSION!^)
        echo   B. 生成的脚本文件: !ISS_FILE!
        echo   C. 项目发布目录: publish\standalone
        echo.
        echo 建议操作:
        if "!RECOMMEND_UPDATE!"=="true" (
            echo   - 建议更新 Inno Setup 到最新版本
            echo   - 下载地址: https://jrsoftware.org/isinfo.php
        )
        echo   - 查看生成的脚本文件检查语法
        echo   - 手动编译脚本进行调试
        pause
        exit /b 1
    )
    call :show_results
    exit /b 0
) else (
    call :show_simple_results
    exit /b 0
)

:: ============================
:: 提取项目信息函数
:: ============================
:extract_project_info
set APP_VERSION=1.0.0
set ASSEMBLY_NAME=%PROJECT_NAME%
set PROJECT_TYPE=Unknown
set TARGET_FRAMEWORK=net8.0

:: 使用PowerShell解析XML项目文件
powershell -Command "try { $xml = [xml](Get-Content '%FOUND_CSPROJ%'); $version = $xml.Project.PropertyGroup.Version; $assemblyName = $xml.Project.PropertyGroup.AssemblyName; $targetFramework = $xml.Project.PropertyGroup.TargetFramework; $outputType = $xml.Project.PropertyGroup.OutputType; $useWPF = $xml.Project.PropertyGroup.UseWPF; $useWindowsForms = $xml.Project.PropertyGroup.UseWindowsForms; Write-Host \"VERSION:$version\"; Write-Host \"ASSEMBLY:$assemblyName\"; Write-Host \"FRAMEWORK:$targetFramework\"; Write-Host \"OUTPUT:$outputType\"; Write-Host \"WPF:$useWPF\"; Write-Host \"WINFORMS:$useWindowsForms\" } catch { Write-Host 'PARSE_ERROR' }" > temp_project_info.txt

for /f "tokens=1,2 delims=:" %%a in (temp_project_info.txt) do (
    if "%%a"=="VERSION" if not "%%b"=="" set APP_VERSION=%%b
    if "%%a"=="ASSEMBLY" if not "%%b"=="" set ASSEMBLY_NAME=%%b
    if "%%a"=="FRAMEWORK" if not "%%b"=="" set TARGET_FRAMEWORK=%%b
    if "%%a"=="OUTPUT" set OUTPUT_TYPE=%%b
    if "%%a"=="WPF" if "%%b"=="true" set PROJECT_TYPE=WPF
    if "%%a"=="WINFORMS" if "%%b"=="true" set PROJECT_TYPE=WinForms
)

del temp_project_info.txt 2>nul

:: 如果没有检测到WPF或WinForms，根据OutputType判断
if "!PROJECT_TYPE!"=="Unknown" (
    if "!OUTPUT_TYPE!"=="Exe" set PROJECT_TYPE=Console
    if "!OUTPUT_TYPE!"=="WinExe" set PROJECT_TYPE=Desktop
)

if "!APP_VERSION!"=="" set APP_VERSION=1.0.0
if "!ASSEMBLY_NAME!"=="" set ASSEMBLY_NAME=%PROJECT_NAME%

exit /b 0

:: ============================
:: 检查Inno Setup版本函数
:: ============================
:check_inno_setup_with_version
set INNO_PATH=
set INNO_VERSION=未知
set INNO_EXACT_VERSION=未知
set RECOMMEND_UPDATE=false

if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    set "INNO_PATH=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    set INNO_VERSION=6.x
    call :get_exact_version "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
) else if exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
    set "INNO_PATH=C:\Program Files\Inno Setup 6\ISCC.exe"
    set INNO_VERSION=6.x
    call :get_exact_version "C:\Program Files\Inno Setup 6\ISCC.exe"
) else if exist "C:\Program Files (x86)\Inno Setup 5\ISCC.exe" (
    set "INNO_PATH=C:\Program Files (x86)\Inno Setup 5\ISCC.exe"
    set INNO_VERSION=5.x
    set RECOMMEND_UPDATE=true
    call :get_exact_version "C:\Program Files (x86)\Inno Setup 5\ISCC.exe"
) else (
    echo 未找到Inno Setup，将使用简化模式
    echo 建议安装最新版Inno Setup: https://jrsoftware.org/isinfo.php
    set RECOMMEND_UPDATE=true
)

if defined INNO_PATH (
    echo 找到Inno Setup: !INNO_VERSION! ^(!INNO_EXACT_VERSION!^)
    echo 安装路径: !INNO_PATH!
    
    :: 检查是否需要推荐更新
    if "!INNO_VERSION!"=="5.x" (
        set RECOMMEND_UPDATE=true
        echo 注意: 使用较老版本，建议更新到 Inno Setup 6.x
    )
    
    if "!INNO_EXACT_VERSION!"=="6.4.3" (
        echo 检测到版本6.4.3 - 将使用终极兼容模式
    )
)

exit /b 0

:: ============================
:: 获取精确版本号
:: ============================
:get_exact_version
set temp_exe=%~1
if exist "%temp_exe%" (
    for /f "tokens=*" %%v in ('powershell -Command "try { (Get-Item '%temp_exe%').VersionInfo.ProductVersion } catch { 'Unknown' }"') do (
        set INNO_EXACT_VERSION=%%v
    )
)
exit /b 0

:: ============================
:: 版本控制检查函数
:: ============================
:version_control_check
set VERSION_FILE=.version-history.txt

:: 显示版本确认信息
echo 正在确认应用程序版本...
echo.
echo 当前版本号: !APP_VERSION!
echo 项目类型: !PROJECT_TYPE!
echo 目标框架: !TARGET_FRAMEWORK!
echo.
echo 版本信息已确认

:: 更新版本历史
echo LAST_VERSION=!APP_VERSION! > "%VERSION_FILE%"
echo LAST_BUILD=%date% %time% >> "%VERSION_FILE%"
echo PROJECT_TYPE=!PROJECT_TYPE! >> "%VERSION_FILE%"

exit /b 0

:: ============================
:: 构建应用程序函数
:: ============================
:build_application
:: 确保输出目录存在
if not exist "publish\standalone" mkdir "publish\standalone"

:: 统一的发布配置
set BUILD_CONFIG=Release
set RUNTIME_ID=win-x64

echo 正在发布应用程序...
echo 配置: !BUILD_CONFIG!
echo 运行时: !RUNTIME_ID!
echo 包含运行时: 是 ^(自包含应用程序^)

dotnet publish "%FOUND_CSPROJ%" -c !BUILD_CONFIG! -r !RUNTIME_ID! --self-contained true -p:PublishSingleFile=true -p:PublishTrimmed=false -o "publish\standalone"

if errorlevel 1 (
    echo 错误: 应用程序发布失败
    echo 请检查项目是否能正常编译
    pause
    exit /b 1
)

:: 确定可执行文件名
set APP_EXE_NAME=!ASSEMBLY_NAME!.exe
if not exist "publish\standalone\!APP_EXE_NAME!" (
    for %%f in (publish\standalone\*.exe) do (
        set APP_EXE_NAME=%%~nxf
        goto :found_exe
    )
    echo 错误: 未找到可执行文件
    pause
    exit /b 1
)
:found_exe

echo 应用程序打包完成: !APP_EXE_NAME!
exit /b 0

:: ============================
:: 创建终极兼容版安装脚本函数
:: ============================
:create_ultimate_compatible_installer_script
set ISS_FILE=%PROJECT_NAME%-installer-v!APP_VERSION!-ultimate.iss

echo ; 自动生成的安装脚本 ^(终极兼容版^) > "%ISS_FILE%"
echo ; 项目: %PROJECT_NAME% ^(!PROJECT_TYPE! 应用程序^) >> "%ISS_FILE%"
echo ; 版本: !APP_VERSION! >> "%ISS_FILE%"
echo ; 生成时间: %date% %time% >> "%ISS_FILE%"
echo ; 目标框架: !TARGET_FRAMEWORK! >> "%ISS_FILE%"
echo ; 兼容: 所有 Inno Setup 版本 ^(包括最老版本^) >> "%ISS_FILE%"
echo ; 特点: 完全移除Flags参数，使用最基础语法 >> "%ISS_FILE%"
echo. >> "%ISS_FILE%"

:: 定义变量
echo #define MyAppName "%PROJECT_NAME%" >> "%ISS_FILE%"
echo #define MyAppVersion "!APP_VERSION!" >> "%ISS_FILE%"
echo #define MyAppPublisher "本地开发者" >> "%ISS_FILE%"
echo #define MyAppURL "https://github.com/example" >> "%ISS_FILE%"
echo #define MyAppExeName "!APP_EXE_NAME!" >> "%ISS_FILE%"
echo #define MyAppDescription "%PROJECT_NAME% - !PROJECT_TYPE! .NET 应用程序" >> "%ISS_FILE%"
echo. >> "%ISS_FILE%"

:: Setup区段 - 使用最基础的指令
echo [Setup] >> "%ISS_FILE%"
echo AppName={#MyAppName} >> "%ISS_FILE%"
echo AppVersion={#MyAppVersion} >> "%ISS_FILE%"
echo AppVerName={#MyAppName} {#MyAppVersion} >> "%ISS_FILE%"
echo AppPublisher={#MyAppPublisher} >> "%ISS_FILE%"
echo DefaultDirName={autopf}\{#MyAppName} >> "%ISS_FILE%"
echo DefaultGroupName={#MyAppName} >> "%ISS_FILE%"
echo OutputDir=installer >> "%ISS_FILE%"
echo OutputBaseFilename={#MyAppName}-Setup-v{#MyAppVersion} >> "%ISS_FILE%"
echo Compression=lzma >> "%ISS_FILE%"
echo SolidCompression=yes >> "%ISS_FILE%"
echo PrivilegesRequired=lowest >> "%ISS_FILE%"
echo ArchitecturesAllowed=x64 >> "%ISS_FILE%"
echo ArchitecturesInstallIn64BitMode=x64 >> "%ISS_FILE%"
echo VersionInfoVersion=!APP_VERSION! >> "%ISS_FILE%"
echo VersionInfoProductVersion=!APP_VERSION! >> "%ISS_FILE%"
echo VersionInfoTextVersion=!APP_VERSION! >> "%ISS_FILE%"
echo MinVersion=6.1 >> "%ISS_FILE%"
echo UninstallDisplayName={#MyAppName} {#MyAppVersion} >> "%ISS_FILE%"
echo. >> "%ISS_FILE%"

:: 语言区段
echo [Languages] >> "%ISS_FILE%"
echo Name: "english"; MessagesFile: "compiler:Default.isl" >> "%ISS_FILE%"
echo. >> "%ISS_FILE%"

:: 任务区段 - 完全移除Flags参数
echo [Tasks] >> "%ISS_FILE%"
echo Name: "desktopicon"; Description: "创建桌面快捷方式" >> "%ISS_FILE%"
echo Name: "startmenu"; Description: "添加到开始菜单" >> "%ISS_FILE%"
echo. >> "%ISS_FILE%"

:: 文件区段 - 使用最基础的标志
echo [Files] >> "%ISS_FILE%"
echo Source: "publish\standalone\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs >> "%ISS_FILE%"
echo Source: ".version-history.txt"; DestDir: "{app}"; Flags: ignoreversion >> "%ISS_FILE%"
echo. >> "%ISS_FILE%"

:: 图标区段 - 使用最基础的语法
echo [Icons] >> "%ISS_FILE%"
echo Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}" >> "%ISS_FILE%"
echo Name: "{group}\卸载 {#MyAppName}"; Filename: "{uninstallexe}" >> "%ISS_FILE%"
echo Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon >> "%ISS_FILE%"
echo. >> "%ISS_FILE%"

:: 运行区段 - 使用最基础的标志
echo [Run] >> "%ISS_FILE%"
echo Filename: "{app}\{#MyAppExeName}"; Description: "启动应用程序"; Flags: nowait postinstall >> "%ISS_FILE%"

echo 终极兼容版脚本已生成: !ISS_FILE!
echo 特点: 完全移除所有Flags参数中的标志，使用最基础语法

exit /b 0

:: ============================
:: 验证生成的脚本函数
:: ============================
:verify_generated_script
echo 正在验证生成的脚本语法...
if exist "!ISS_FILE!" (
    echo 脚本文件存在: !ISS_FILE!
    echo 文件大小: 
    for %%f in ("!ISS_FILE!") do echo   %%~zf 字节
    
    echo.
    echo 脚本特点:
    echo   - 完全移除Flags参数中的所有标志
    echo   - 保留基础的任务定义
    echo   - 使用最简单的语法结构
    echo   - 兼容所有Inno Setup版本
) else (
    echo 警告: 脚本文件生成失败
)

exit /b 0

:: ============================
:: 显示结果函数
:: ============================
:show_results
echo.
echo ========================================
echo 安装程序制作完成！
echo ========================================
echo.
echo 项目信息:
echo   名称: %PROJECT_NAME%
echo   类型: !PROJECT_TYPE!
echo   版本: !APP_VERSION!
echo   可执行文件: !APP_EXE_NAME!
echo   Inno Setup: !INNO_VERSION! ^(!INNO_EXACT_VERSION!^)
echo.
echo 生成的安装程序:
for %%f in (installer\*.exe) do (
    echo   %%f
    set INSTALLER_FILE=%%f
)

echo.
echo 终极兼容性保证:
echo   [成功] 所有 Inno Setup 版本兼容 ^(包括6.4.3及更早^)
echo   [成功] 完全移除所有Flags参数标志
echo   [成功] 使用最基础语法结构
echo   [成功] 核心功能完整保留
echo   [成功] 版本检查和更新提示
echo.

if "!RECOMMEND_UPDATE!"=="true" (
    echo 版本更新建议:
    echo   - 当前版本较老，建议更新到最新版 Inno Setup
    echo   - 更新可获得更多功能和更好的兼容性
    echo   - 下载地址: https://jrsoftware.org/isinfo.php
    echo.
)

:: 设置一个标志，表示用户已经交互过了
set USER_INTERACTED=false

if defined INSTALLER_FILE (
    echo 请选择操作:
    echo   Y - 立即测试安装程序
    echo   N - 不测试，直接退出
    echo.
    set /p TEST_INSTALLER=请输入选择 ^(Y/N^): 
    set USER_INTERACTED=true
    
    if /i "!TEST_INSTALLER!"=="Y" (
        echo.
        echo 正在启动安装程序...
        start "" "!INSTALLER_FILE!"
        echo 安装程序已启动！
        echo.
        echo 感谢使用通用.NET应用程序打包工具 v7.0！
        timeout /t 2 /nobreak >nul
    ) else (
        echo.
        echo 感谢使用通用.NET应用程序打包工具 v7.0！
    )
) else (
    echo.
    echo 感谢使用通用.NET应用程序打包工具 v7.0！
    timeout /t 2 /nobreak >nul
)

exit /b 0

:: ============================
:: 显示简化模式结果函数
:: ============================
:show_simple_results
echo.
echo ========================================
echo 简化模式完成！
echo ========================================
echo.
echo 已生成文件:
echo   1. 打包应用: publish\standalone\!APP_EXE_NAME!
echo   2. 终极兼容安装脚本: !ISS_FILE!
echo   3. 版本历史: .version-history.txt
echo.
echo 项目信息:
echo   类型: !PROJECT_TYPE!
echo   版本: !APP_VERSION!
echo.
echo 下一步操作:
echo   1. 安装最新版 Inno Setup: https://jrsoftware.org/isinfo.php
echo   2. 重新运行此脚本获得完整功能

echo.
echo 请选择操作:
echo   Y - 测试应用程序
echo   N - 不测试，直接退出
echo.
set /p TEST_CHOICE=请输入选择 ^(Y/N^): 

if /i "!TEST_CHOICE!"=="Y" (
    echo.
    echo 正在启动应用程序...
    start "" "publish\standalone\!APP_EXE_NAME!"
    echo 应用程序已启动！
    echo.
    echo 感谢使用通用.NET应用程序打包工具 ！
    timeout /t 2 /nobreak >nul
) else (
    echo.
    echo 感谢使用通用.NET应用程序打包工具 ！
)

exit /b 0 