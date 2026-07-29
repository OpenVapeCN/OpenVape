# OpenVape

对 Vape 4.21 客户端、启动器与本地服务的研究性恢复工程。

## 免责声明与版权说明

本项目为**教育研究性质**的逆向工程恢复项目，旨在进行软件兼容性分析与技术研究。

- 仅限教育、研究与自有授权环境测试用途
- 使用本项目前，**必须已拥有 Vape 的合法授权**
- 使用者需自行确保遵守当地法律、软件许可协议及服务器规则
- 项目作者不对使用者的违规行为承担任何责任

## 独立性声明

本项目为个人自发进行的独立研究工作：

- 未接受任何形式的外部资助、赞助或商业合作
- 不代表、不隶属于任何组织、团体或个人
- 与任何政治立场、意识形态或商业利益无关
- 项目内容仅反映作者个人的技术研究兴趣

项目由个人独立发起并维护，所有观点与成果仅代表技术研究层面，不涉及任何其他立场。

## 安全性声明

本项目仅通过本 GitHub 仓库、[Gitee镜像仓库](https://gitee.com/OpenVape) 与 B站账号 [Gante393_](https://space.bilibili.com/3461573733517603) 视频附带资源发布源码与构建产物，以上渠道发布的文件可保证安全性。
任何在其他 GitHub 仓库、Discord、QQ群、Telegram群、第三方网站或网盘等渠道发布的 "Vape" 相关程序安全性均无法保证。本项目不对这些程序及其可能造成的损失承担任何责任。

## 项目组成

| 仓库                                                       | 职责                                                        | Actions 产物                       |
| -------------------------------------------------------- | --------------------------------------------------------- | -------------------------------- |
| [VapeLoader](https://github.com/OpenVapeCN/VapeLoader)   | 重建的 Windows 启动器；负责本地登录、Minecraft 进程选择、注入编排与加载进度显示         | `vape-v4-controller-windows-x64` |
| [VapeService](https://github.com/OpenVapeCN/VapeService) | Java 17 本地实验服务；提供 Online REST API、Zeus TCP 链路与 JSON 数据持久化 | `vape421-service`                |
| [VapeV4.21](https://github.com/OpenVapeCN/VapeV4.21)     | 恢复后的 Java 产品层，以及 Windows x64 JNI/JVMTI 桥接 DLL 和注入器        | `windows-x64-injection-bundle`   |

## 环境要求

- Windows 10/11 x64；
- JDK 17，用于运行 VapeService；
- Minecraft 1.8.9 测试实例，并使用 64 位 JVM；

## 下载构建产物

三个仓库都通过 GitHub Actions 构建，无需在本地编译：

1. 打开对应仓库的 Actions 页面；
2. 进入最新一次成功的工作流运行；
3. 在页面底部的 **Artifacts** 区域下载表中对应的 artifact；
4. 分别解压，并将运行所需文件放到同一个目录。

快捷入口：

- [VapeLoader / Windows 构建](https://github.com/OpenVapeCN/VapeLoader/actions) 下载 `vape-v4-controller-windows-x64`
- [VapeService / 持续集成](https://github.com/OpenVapeCN/VapeService/actions) 下载 `vape421-experimental-service-0.1.0`
- [VapeV4.21 / 持续集成](https://github.com/OpenVapeCN/VapeV4.21/actions) 下载 `windows-x64-injection-bundle`

Actions artifact 默认只保留 **14 天**。如果页面中没有可下载产物，请登录 GitHub 后手动 **Run workflow** 触发一次构建。

解压 `windows-x64-injection-bundle` 后可得到 `Vape421Native.dll` 和 `Vape421Injector.exe` 两个文件，需与 `vape-v4-controller-windows-x64.exe` 放在同一目录下。

## 快速开始

### 1. 启动本地 Service

在服务 `vape421-experimental-service-0.1.0` 目录下打开 PowerShell，输入以下指令启动服务（需要 JDK 17）：

```powershell
java -jar .\vape421-experimental-service-0.1.0.jar `
  --bind-address 127.0.0.1 `
  --http-port 8080 `
  --zeus-port 8091 `
  --data-file .\data\vape-service.json
```

如果使用本仓库附带的 `start-service.cmd`，它默认从 `C:\Program Files\Java\jdk-17\bin\java.exe` 启动 JDK 17；本机 JDK 安装位置不同时，需要调整脚本中的 `JAVA_COMMAND`。

保持 Service 窗口运行。默认端点为：

| 服务              | 地址                       |
| --------------- | ------------------------ |
| Online HTTP API | `http://127.0.0.1:8080`  |
| Zeus TCP        | `127.0.0.1:8091`         |
| 本地数据            | `data/vape-service.json` |

### 2. 启动 Minecraft

启动使用 64 位 JVM 的 Minecraft 1.8.9 测试实例，并等待游戏窗口出现。Loader 只会列出窗口标题中包含 `Minecraft` 的 `java.exe` 或 `javaw.exe` 进程。

### 3. 通过 Loader 加载

运行 `vape-v4-controller-windows-x64.exe`：

1. 输入一个用户名并点击登录；
2. 从列表中选择 Minecraft 进程；
3. 等待 Loader 显示加载完成。

当前 VapeService 是本地实验服务：登录只按用户名匹配，**不校验密码或 HWID**。用户名首次出现时会创建本地账户，再次使用时会复用账户和长期 token。

成功注入后，`Vape421Native.dll` 会在同目录生成 `vape421-native.log`。排查加载问题时，先检查该日志以及 Service 控制台输出。

## 直接注入模式

`Vape421Injector.exe` 可用于直接注入DLL

使用方向键选择 Java 进程并按 Enter 注入；也可以用于脚本：

```powershell
.\Vape421Injector.exe <pid> .\Vape421Native.dll
```

采用直接方式注入的客户端在线服务（包括配置保存）不会正常工作。

## 常见问题

**Loader 中看不到 Minecraft**\
确认游戏使用 64 位 JVM，进程名为 `java.exe` 或 `javaw.exe`，并且窗口标题包含 `Minecraft`。

**提示找不到** **`Vape421Native.dll`**\
将 DLL 与 `vape-v4-controller-windows-x64.exe` 放在同一目录，保留原始文件名。

**Loader 无法登录本地 Service**\
确认 Service 正在运行且 HTTP 端口未被占用；默认地址是 `http://127.0.0.1:8080`。

**加载超时或注入后没有界面**\
检查 `vape421-native.log` 和 Service 输出，并确认目标是 Minecraft 1.8.9 x64 测试实例。Loader 当前的加载超时为 90 秒。

**Windows 安全软件拦截 DLL 或注入器**\
原生组件会使用 `LoadLibraryW` 写入目标 JVM，这类行为可能触发安全软件。只使用自己从源码或可信 Actions 工作流生成并核验过的产物，不要直接关闭系统防护。

## 从源码构建

每个子仓库都包含独立的构建与验证说明：

- [VapeLoader README](https://github.com/OpenVapeCN/VapeLoader#readme)：CMake + Visual Studio 2022，Windows x64；
- [VapeService README](https://github.com/OpenVapeCN/VapeService#readme)：Gradle Wrapper + JDK 17；
- [VapeV4.21 README](https://github.com/OpenVapeCN/VapeV4.21#readme)：Gradle、CMake、Visual Studio 2022 与 JNI/JVMTI 工具链。

## 鸣谢

- [OpenVapeCN](https://github.com/OpenVapeCN)：本项目的发起人、维护者与贡献者。
- [GPT-5.6 Sol](https://chatgpt.com/)：项目繁重工作的主要完成者。
- [CFR](https://github.com/leibnitz27/cfr)：帮助生成恢复实现代码。
- [Ghidra](https://ghidra-sre.org/)：用于逆向工程的静态分析工具。
- [Steesha](https://blog.steesha.cn/)：提供Vape主程序和部分逆向成果。
- [John Xina](https://github.com/spec-johnxina/)：提供Vape V4.21的dump文件。
- [cubk](https://github.com/cubk1/)：提供Vape V3的逆向工程代码，为映射提供了基础。
- [LvStrnggg](https://github.com/LvStrnggg/zkm-flow)：提供zkm控制流逆向思路。

## 许可证

本项目所有代码采用 [CC0 1.0 Universal](LICENSE) 许可。

你可以：
- 自由复制、分发、传播本项目的源码与构建产物
- 自由修改、二次开发、集成到商业或非商业项目
- 自由用于任何目的，无需支付费用或获得额外许可
- 自由选择是否署名、是否以相同许可发布衍生作品
