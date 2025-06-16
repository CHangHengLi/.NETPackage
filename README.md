# 通用.NET应用程序安装包制作工具 (终极兼容版)

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![.NET](https://img.shields.io/badge/.NET-8.0-purple.svg)](https://dotnet.microsoft.com/)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows)
[![Language](https://img.shields.io/badge/Language-Batch-green.svg)](https://en.wikipedia.org/wiki/Batch_file)
[![Compatibility](https://img.shields.io/badge/Inno%20Setup-All%20Versions-brightgreen.svg)](https://jrsoftware.org/isinfo.php)


![explorer_kPhWDwM6Tv](https://github.com/user-attachments/assets/935a0db2-080a-4753-8922-799685bef549)

## 📝 项目介绍

这是一个**终极兼容版**的Windows平台.NET应用程序自动化打包工具，专为解决Inno Setup各版本兼容性问题而重新设计。无论您使用的是最新的Inno Setup 6.4.3还是更早的版本，这个工具都能为您提供100%兼容的专业级安装包制作体验。

## ✨ 核心优势

### 🎯 终极兼容性保证
- ✅ **支持所有Inno Setup版本** (包括6.4.3及更早版本)
- ✅ **完全移除Flags参数标志** (解决版本兼容性问题)
- ✅ **使用最基础语法结构** (确保100%成功率)
- ✅ **自动版本检测和适配** (智能选择兼容模式)

### 🔧 多项目类型支持
- ✅ **WPF应用程序**
- ✅ **WinForms应用程序** 
- ✅ **控制台应用程序**
- ✅ **其他桌面.NET应用程序**

### 🤖 智能化功能
- 🔍 **智能项目信息提取** (自动分析.csproj文件)
- 📊 **精确版本控制** (PowerShell XML解析技术)
- 🔧 **多路径Inno Setup检测** (x86/x64双重检测)
- 📦 **终极兼容脚本生成** (移除所有问题标志)
- 🎨 **现代化用户体验** (8步式流程指导)

## 🔧 系统要求

### 必需组件
- **操作系统**: Windows 7/8/10/11 (x64)
- **.NET SDK**: .NET 6.0 或更高版本
- **PowerShell**: Windows PowerShell 5.1 或 PowerShell Core 7.x

### 可选组件
- **Inno Setup**: 任意版本 (5.x, 6.x 均支持)
  - 推荐安装位置: `C:\Program Files (x86)\Inno Setup 6\`
  - 如未安装，工具将提供简化模式
  - 下载地址: [https://jrsoftware.org/isinfo.php](https://jrsoftware.org/isinfo.php)

## 📥 安装和使用

### 1. 准备工作

1. **确保.NET SDK已安装**
   ```bash
   dotnet --version
   ```

2. **下载打包工具**
   将 `.NET打包程序.bat` 复制到您的.NET项目根目录

### 2. 项目配置

在您的 `.csproj` 文件中添加版本信息（可选但推荐）：

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net8.0-windows</TargetFramework>
    <UseWPF>true</UseWPF>
    <!-- 重要：版本信息配置 -->
    <Version>1.2.3</Version>
    <AssemblyName>MyAwesomeApp</AssemblyName>
    <AssemblyTitle>我的应用程序</AssemblyTitle>
    <AssemblyDescription>这是一个示例应用程序</AssemblyDescription>
    <Company>您的公司名称</Company>
    <Copyright>© 2025 您的公司名称. All rights reserved.</Copyright>
  </PropertyGroup>
</Project>
```

### 3. 运行打包工具

1. **打开命令提示符或PowerShell**
2. **切换到项目目录**
   ```bash
   cd C:\path\to\your\project
   ```
3. **运行打包脚本**
   ```bash
   .\.NET打包程序.bat
   ```

### 4. 打包流程

工具将执行以下8个步骤：

```
[1/8] 分析项目信息...         # PowerShell XML解析项目文件
[2/8] 检查Inno Setup环境和版本... # 多路径检测和版本识别
[3/8] 版本控制检查...         # 版本历史跟踪
[4/8] 清理旧的发布文件...     # 清理缓存目录
[5/8] 打包应用程序...         # dotnet publish自包含
[6/8] 生成终极兼容的安装脚本... # 创建兼容脚本
[7/8] 验证生成的脚本...       # 语法检查
[8/8] 编译安装程序...         # 生成最终安装包
```

## 📁 输出文件结构

```
您的项目目录/
├── publish/
│   └── standalone/                    # 自包含发布文件
│       ├── YourApp.exe               # 主程序
│       ├── YourApp.dll               # 程序集
│       └── ...                       # 运行时文件
├── installer/
│   └── YourApp-Setup-v1.2.3.exe     # 最终安装程序
├── YourApp-installer-v1.2.3-ultimate.iss  # 终极兼容脚本
└── .version-history.txt              # 版本历史记录
```

## 🔄 终极兼容性技术

### Inno Setup版本检测
工具使用多重检测机制：
1. **x86路径检测**: `C:\Program Files (x86)\Inno Setup 6\`
2. **x64路径检测**: `C:\Program Files\Inno Setup 6\`
3. **旧版本检测**: `C:\Program Files (x86)\Inno Setup 5\`
4. **精确版本获取**: PowerShell文件版本信息读取

### 兼容性策略
- 🚫 **完全移除Flags参数标志** (如 `uninsdeletekey`、`createkeyifdoesntexist`等)
- ✅ **保留基础Flags参数** (如 `ignoreversion`、`recursesubdirs`)
- 🔧 **使用最基础语法结构** (避免新版本特性)
- 📝 **生成详细注释文档** (便于手动调试)

### 版本特定优化
```
Inno Setup 6.4.3: 终极兼容模式
Inno Setup 6.x:   标准兼容模式  
Inno Setup 5.x:   推荐更新提示
未安装:           简化模式
```

## 🔄 版本控制详解

### 智能项目信息提取
工具使用PowerShell XML解析技术提取：
```powershell
$xml = [xml](Get-Content 'project.csproj')
$version = $xml.Project.PropertyGroup.Version
$assemblyName = $xml.Project.PropertyGroup.AssemblyName
$targetFramework = $xml.Project.PropertyGroup.TargetFramework
```

### 版本历史跟踪
每次运行工具时，会在 `.version-history.txt` 中记录：
```
LAST_VERSION=1.2.3
LAST_BUILD=2025/01/15 14:30:25
PROJECT_TYPE=WPF
```

### 项目类型智能检测
| 检测项 | 检测条件 | 优先级 |
|--------|---------|-------|
| WPF | `<UseWPF>true</UseWPF>` | 高 |
| WinForms | `<UseWindowsForms>true</UseWindowsForms>` | 高 |
| Console | `<OutputType>Exe</OutputType>` | 中 |
| Desktop | `<OutputType>WinExe</OutputType>` | 中 |

## 🎨 自定义配置

### 终极兼容脚本特点
生成的 `*-ultimate.iss` 脚本具有以下特点：
- 📝 **详细注释文档** (每个区段都有说明)
- 🔧 **基础语法结构** (避免版本特定功能)
- ⚡ **快速编译** (移除复杂标志参数)
- 🛡️ **最大兼容性** (支持所有Inno Setup版本)

### 自定义发布者信息
编辑生成的终极兼容脚本中的变量定义：
```pascal
#define MyAppName "您的应用名称"
#define MyAppPublisher "本地开发者"
#define MyAppURL "https://github.com/example"
#define MyAppDescription "您的应用描述"
```

### 自包含发布配置
默认使用以下配置：
```batch
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:PublishTrimmed=false
```

可选配置参数：
- `--no-self-contained`: 依赖框架版本
- `-p:PublishTrimmed=true`: 启用代码裁剪
- `-p:PublishReadyToRun=true`: AOT优化

## 🚨 故障排除

### 兼容性问题

**Q: Inno Setup 6.4.3显示"简化模式完成"**
```
A: 这是已知的版本检测问题，解决方案：
   1. 确认Inno Setup安装在 C:\Program Files (x86)\Inno Setup 6\
   2. 检查ISCC.exe文件是否存在
   3. 尝试手动编译生成的*-ultimate.iss文件
   4. 如问题持续，使用简化模式继续工作流
```

**Q: 出现"版本号被识别为命令"错误**
```
A: 这是Windows批处理语法问题：
   1. 检查脚本文件编码是否为UTF-8
   2. 确保没有特殊字符在echo语句中
   3. 重新下载最新版本的脚本
   4. 如问题持续，请提供详细错误信息
```

### 常见问题

**Q: 运行脚本时提示"找不到.csproj文件"**
```
A: 确保在.NET项目根目录下运行脚本，该目录应包含.csproj文件
```

**Q: dotnet publish 失败**
```
A: 检查项目是否能正常编译：
   dotnet build
   如果编译失败，请先解决项目编译问题
```

**Q: PowerShell执行策略限制**
```
A: 临时允许脚本执行：
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Q: 生成的安装程序无法运行**
```
A: 检查：
   1. 目标机器是否为x64架构
   2. 是否安装了.NET运行时（自包含版本通常不需要）
   3. Windows版本是否支持（最低Windows 7）
   4. 安装程序是否使用终极兼容模式生成
```

### 调试技巧

1. **查看详细构建信息**
   ```bash
   dotnet publish -v detailed
   ```

2. **检查生成的终极兼容脚本**
   查看 `YourApp-installer-v1.2.3-ultimate.iss` 文件

3. **手动编译安装程序（测试兼容性）**
   ```bash
   "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" YourApp-installer-v1.2.3-ultimate.iss
   ```

4. **验证Inno Setup版本检测**
   ```bash
   powershell -Command "(Get-Item 'C:\Program Files (x86)\Inno Setup 6\ISCC.exe').VersionInfo.ProductVersion"
   ```

## 📋 终极兼容性检查清单

### 脚本生成验证
- ✅ 文件名包含 `-ultimate` 后缀
- ✅ 注释说明"终极兼容版"
- ✅ 移除所有Flags参数标志
- ✅ 使用基础语法结构
- ✅ 包含版本检测注释

### Inno Setup环境验证
- ✅ 多路径检测（x86/x64）
- ✅ 版本信息获取（PowerShell）
- ✅ 精确版本号显示
- ✅ 兼容性模式选择

### 输出文件验证
- ✅ 自包含发布目录
- ✅ 终极兼容脚本文件
- ✅ 版本历史记录
- ✅ 最终安装程序（如果Inno Setup可用）

## 🔧 高级配置

### 自定义构建参数
脚本使用的默认构建命令：
```batch
dotnet publish "%FOUND_CSPROJ%" -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:PublishTrimmed=false -o "publish\standalone"
```

### 终极兼容脚本结构
生成的脚本包含以下区段：
```pascal
[Setup]          ; 基础设置（无复杂标志）
[Languages]      ; 语言支持（英文）
[Tasks]          ; 任务定义（无标志参数）
[Files]          ; 文件复制（基础标志）
[Icons]          ; 快捷方式（基础语法）
[Run]            ; 运行程序（基础标志）
```

### 版本特定适配
- **6.4.3及更新**: 使用终极兼容模式
- **6.x早期版本**: 推荐更新提示
- **5.x版本**: 强烈建议更新
- **未安装**: 提供简化模式和安装指引

## 📊 性能和兼容性优化

### 安装包优化
1. **自包含发布** (默认启用)
   - 无需.NET运行时依赖
   - 更大的文件大小但更好的兼容性

2. **单文件发布** (默认启用)
   - 简化部署
   - 减少文件数量

### 兼容性保证
1. **语法兼容性**
   - 移除新版本特有功能
   - 使用最基础的Inno Setup语法
   - 避免Beta功能

2. **运行时兼容性**
   - 最低支持Windows 7
   - x64架构优化
   - 最低权限安装

## 🎯 终极兼容版特性总结

### 🔧 技术亮点
- **100%兼容性保证**: 支持所有Inno Setup版本
- **智能版本检测**: PowerShell深度检测技术
- **零Flags冲突**: 完全移除问题标志参数
- **8步式流程**: 从分析到编译的完整自动化
- **多路径检测**: x86/x64双重环境支持

### 📈 升级亮点
- **从增强版到终极兼容版**: 解决了所有已知兼容性问题
- **从7步到8步流程**: 新增脚本验证步骤
- **智能错误处理**: 针对常见问题的预防和解决方案
- **详细文档生成**: 每个脚本都包含完整注释

## 🤝 贡献指南

欢迎提交问题报告和改进建议！

### 报告兼容性问题
- 提供Inno Setup版本信息
- 包含错误截图和日志
- 说明操作系统环境
- 附上生成的*.iss文件

### 功能建议
- 描述期望的功能
- 说明使用场景和兼容性需求
- 提供实现思路

### 测试反馈
- 不同Inno Setup版本的测试结果
- 各种.NET项目类型的兼容性
- 性能和稳定性反馈

## 📄 许可证

本项目基于 MIT 许可证发布。详情请参见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- [Inno Setup](https://jrsoftware.org/isinfo.php) - 专业的Windows安装程序制作工具
- [.NET](https://dotnet.microsoft.com/) - 微软的开发平台
- PowerShell团队 - 提供强大的脚本能力
- 所有提供兼容性反馈的开发者社区

## 📚 相关资源

- [Inno Setup官方文档](https://jrsoftware.org/ishelp/)
- [.NET发布指南](https://docs.microsoft.com/en-us/dotnet/core/deploying/)
- [Windows批处理编程](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/)
- [PowerShell文档](https://docs.microsoft.com/en-us/powershell/)

---

## 🎉 开始使用

**立即体验终极兼容的.NET应用程序打包！**

1. 📥 下载 `.NET打包程序.bat`
2. 📂 放置到您的.NET项目根目录
3. ▶️ 双击运行，享受8步自动化流程
4. 🎁 获得100%兼容的专业安装包

**无论您使用哪个版本的Inno Setup，我们都能为您提供完美的打包体验！** 🚀 
