# OpenRA · Red Alert（实验性 ARM64 接入）

当前资源：`20261026-playtest-deskbox.3`，需要含 OpenRA Activity 的 Desk Box APK
（本轮候选 `0.15.0-dev.35`）。**尚未通过可玩性验收**：OPD2403 3000×2120 下约
2 FPS，触摸切换位置后首次点击可能需要重试。GNU 硬件图形路径和输入问题仍待解决。

采用官方 `playtest-20261026` Red Alert ARM64 AppImage；稳定版 `release-20250330`
没有发布 Linux ARM64 AppImage。本轮不包含 Tiberian Dawn／Dune 2000 的移植验收。

引擎 `.deb` 固定于 [`openra-v20261026-playtest-deskbox.1`](https://github.com/eeoa/deskbox-repo/releases/tag/openra-v20261026-playtest-deskbox.1)，
35,299,652 字节，SHA256 `70f660705b3dde8c62a6328fa0bc53ff5278b2fd55d0240d23eca28a6259a74a`。
AppImage 内 1,367 个文件逐字节保留，包括 .NET 10.0.13、SDL 2.32.10、OpenAL、mod、
引擎和 shader。对应源码与逐文件来源清单随该发布提供。没有修改 ELF、C# 或 shader。

schema 3 提供 install／launch／uninstall。144 个包按 SHA256 和固定路径验证，
与已有 GNU 桌面依赖共用哈希存储；本轮新增 12 包／39,423,888 字节。
GNU Xlib locale、SDL 原生显示比例、PulseAudio 子目录和上游 PseudoFullscreen 由
静态配置准备；无 OpenRA 专属 Android 运行逻辑或定制原生适配程序。

首次运行由游戏自己的 Quick Install 取得红警数据。本仓库和引擎包不附带这些版权内容。
用户配置、Content、Saves 和 Replays 位于 `$HOME/.config/openra`，卸载保留该目录。

本轮实测完成正式安装／更新、内容下载、战役加载、GUI 保存、正式入口读档、私有
PulseAudio→OpenSL ES 输出、热重连、冷启动与首页强制关闭。单人短测使用上游内建
`Launch.Benchmark` 导出 CSV；最终 40 秒命令窗口取得 57 个 local tick 样本：render 中位数 477.47 ms、
p95 545.71 ms，逻辑 tick 中位数 4.14 ms（含启动／JIT）。此前 145 样本的 render
中位数为 527.28 ms。它说明当前瓶颈，不代表完整战役／大规模对战通过。
联网对战、音乐／视频内容、全战役和长期稳定性尚未验收。

上游：[发布与源码](https://github.com/OpenRA/OpenRA/releases/tag/playtest-20261026)，
[OpenRA 官网](https://www.openra.net/)。引擎及相关源码按各自原有许可证分发；版权游戏数据
由上游内容安装器单独处理。
