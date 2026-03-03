# ⚡ CUMT-Net-AutoLogin

**中国矿业大学（CUMT）校园网纯原生、无黑框、事件驱动的自动登录脚本。**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)]()

告别每次开机、断网重连后繁琐的网页手动登录。只需配置一次，后续只要电脑连接到校园网（支持 Wi-Fi 与有线），系统将在底层后台自动瞬间完成认证。

## ✨ 核心特性 (Features)

- **📦 零依赖 (Zero-Dependency)**：纯 Windows 原生 Batch 批处理编写，**无需**安装 Python、Node.js、Go 等任何第三方环境或可执行程序。
- **👻 绝对静默 (Absolutely Silent)**：通过提权至系统最高级别的 `SYSTEM` 幽灵账户运行，认证过程在 Session 0 底层会话中完成，**连一闪而过的 CMD 黑框都不会有**，真正的无感体验。
- **🍃 零消耗 (Event-Driven)**：抛弃传统的“后台死循环+延迟”轮询方案。基于 Windows Event Viewer (事件查看器) 的底层 XML XPath 过滤机制，仅在网络状态发生特定改变的瞬间触发，平时系统资源占用严格为 **0**。
- **🌐 全端兼容**：完美支持学生端 `CUMT_Stu` 与 教师端 `CUMT_Tec`；内置全运营商后缀处理（纯校园网/电信/移动/联通）。
- **♻️ 纯净绿色**：同目录就地生成配置，不污染系统 `AppData` 或注册表，提供一键卸载脚本，来去无踪。

---

## 🚀 安装指南 (Installation)

### 第一步：准备文件
1. 在本页点击绿色的 `<> Code` 按钮，选择 **Download ZIP**。
2. 将下载的压缩包解压。
3. ⚠️ **极其重要**：请将解压后的文件夹移动到一个**安全的、长期的目录**（例如 `D:\Tools\CUMT_AutoLogin\`）。
   > **注意**：请勿在“桌面”、“下载”或直接在压缩包内运行！因为运行后该文件夹不能被移动或删除，否则后台任务将失效。

### 第二步：一键配置
1. 进入文件夹，双击运行 `install.bat`。
2. 脚本会自动请求管理员权限（弹出 UAC 盾牌提示，请点击“是”）。
3. 按照屏幕上的中文提示：
   - 输入你的【纯学号/工号】
   - 输入你的【校园网密码】
   - 输入数字选择你的【运营商】
4. 提示“安装圆满完成”后即可关闭窗口。

🎉 **至此，一切准备就绪。你可以尝试断开 Wi-Fi 重新连接 `CUMT_Stu`，享受无感上网的乐趣。**

---

## 🗑️ 彻底卸载 (Uninstallation)

如果你毕业了，或者不想再使用本工具，只需两步即可将系统恢复原状：

1. 进入你当时存放该工具的文件夹。
2. 双击运行 `uninstall.bat`（同样会请求一次管理员权限）。
3. 提示卸载成功后，你可以直接将整个文件夹放入回收站，不会留下任何系统残留。

---

## 🛠️ 常见问题 (FAQ)

**Q1：安装完成后，我可以把文件夹换个地方吗？**
不可以。系统后台的任务计划是指向该文件夹内生成的 `login.bat` 的。如果你必须移动文件夹，请先运行旧目录下的 `uninstall.bat`，移动完成后，在新的目录下重新运行一次 `install.bat` 即可。

**Q2：如果我输错了密码或换了运营商怎么办？**
直接在当前文件夹下重新双击运行 `install.bat` 即可。脚本具有**幂等性**，会自动用新密码覆盖旧配置，并安全地更新系统底层的触发器。

**Q3：这个脚本安全吗？我的密码会被上传吗？**
**绝对安全。** 本项目完全开源，所有代码均在明文 `.bat` 文件中。你的学号和密码仅以纯文本形式保存在本机的 `login.bat` 内，仅用于向 `10.2.5.251` (矿大校园网认证网关) 发送局域网 POST 请求，**绝不会上传至任何第三方服务器**。

---

## 👨‍💻 技术原理 (How it Works)

对于好奇底层实现的 Geek：

1. **自动提权**：使用 VBScript 动态生成对象绕过普通运行限制，自动调起 UAC。
2. **XPath 精准捕获**：安装器会调用 `schtasks` 向 Windows 任务计划程序注入一段自定义的 XML。通过监听 `Microsoft-Windows-NetworkProfile/Operational` 通道中的 `EventID=10000`，并使用 XPath 限定 `Data[@Name='Name']='CUMT_Stu' or Data[@Name='Name']='CUMT_Tec'`，实现精准的网络状态回调。
3. **Session 0 穿透**：生成的任务配置文件中指定了 `<UserId>S-1-5-18</UserId>`（即 `NT AUTHORITY\SYSTEM`）。这免去了密码驻留的鉴权麻烦，同时保证了前台 UI 零打扰。

## 📄 License
本项目采用 [MIT License](https://opensource.org/licenses/MIT) 开源协议。欢迎 Fork 与 PR！