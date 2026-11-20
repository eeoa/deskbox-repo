# OpenRA · Red Alert（ARM64 预览）

当前资源 `20261026-playtest-deskbox.5`，需要含 OpenRA Activity 的 Desk Box
（本轮 APK 为 `0.15.0-dev.36`）。OPD2403／Android 16 的 3000×2120 短场景中，
原版 GNU Mesa KGSL + SDL EGL 达到约 60 FPS；两分钟复测检查场景、文字与操作栏。
这是小规模战役场景，不代表大型对战或长期稳定性。触屏首次点击仍可能需要重试，建议鼠标。

采用官方 [playtest-20261026 Red Alert ARM64 AppImage](https://github.com/OpenRA/OpenRA/releases/tag/playtest-20261026)。
稳定版 release-20250330 没有 Linux ARM64 AppImage；本轮不包含 Tiberian Dawn、Dune 2000。
原始引擎包固定于 [deskbox.1 Release](https://github.com/eeoa/deskbox-repo/releases/tag/openra-v20261026-playtest-deskbox.1)，
35,299,652 字节，SHA256 `70f660705b3dde8c62a6328fa0bc53ff5278b2fd55d0240d23eca28a6259a74a`。
AppImage 内 1,367 个引擎、.NET 10.0.13、SDL 2.32.10、OpenAL、mod 和 shader 文件按原字节保留。
对应源码与逐文件来源清单随该发布提供。

`.4` 增加隔离的 GNU Mesa 包，不覆盖公共 GL 库。图形文件来自
[mesa-freedreno-27.0.0-devel-20261025 发布](https://github.com/sabamdarif/termux-desktop/releases/tag/mesa-freedreno-27.0.0-devel-20261025)，
对应 [Mesa 源码 6f90e92d](https://github.com/lfdevs/mesa-for-android-container/tree/6f90e92dfdacc4759d8e9ccb328805d0f0b4439b)。
原始 ZIP SHA256 `7258d559c72b1127542c4fe5ee2a216b214f6e35c3fdeef044e1f2f2c54004dc`；
91 个文件逐字节重装于 `usr/lib/deskbox-mesa-kgsl`。GNU 图形包为 7,773,336 字节，
SHA256 `740d2ca52248a215d7e45b5eee706031f19fa105acf0b42c6a5cd8fad8e76a35`。
许可、源码定位和逐文件清单随 `.4` Release 提供。未编译游戏专属原生适配器，未改引擎、ELF 或 shader。

schema 3 的 install／launch／uninstall 按固定 tag 和 SHA256 取得脚本与资源。
145 包共 178,604,544 个归档字节；共享依赖按哈希复用，不执行包内维护脚本。
自动／KGSL 设置使用 FD750、SDL `SDL_VIDEO_X11_FORCE_EGL=1`，帧率上限 60、VSync 关闭。
GLX 直通出现文字／纹理缺失，Zink 探针黑屏，均未采用；VirGL 图像回读曾只有约 16 FPS，已退出正式路径。
显式软件模式继续使用 Debian llvmpipe，原生分辨率约 2 FPS。

GNU Xlib locale、SDL 显示比例、PulseAudio 子目录和 PseudoFullscreen 由标准配置准备。
首次运行通过游戏自己的 Quick Install 下载红警数据，版权游戏内容不随仓库分发。
配置、Content、Saves 和 Replays 位于 `$HOME/.config/openra`，卸载保留该目录。

本轮基础流程已覆盖首页安装／更新、内容下载、第一关、GUI 保存和正式入口读档、私有音频、
热重连、冷启动、首页强制关闭和数据保留。性能场景使用上游 `Launch.Benchmark` CSV，
自有地图副本追加 Lua 单位移动，不修改共享引擎文件。未验收完整战役通关、联机对战、
大型遭遇战、长期运行、完整回放及卸载后重装。预览版和触屏限制仍保留。

`.5` 修正从旧资源更新时的依赖选择：安装动作明确使用目标 catalog，避免公共 repair 模式保留旧版本清单。图形包继续固定于 `.4`；`.4` 标签保留。

最终 `.5`／dev.36 正式环境的40秒短测为59 FPS，796个local tick样本，
render中位5.75 ms、P95 18.00 ms。热重连、8个归属进程的强制关闭及首页存活检查通过，
存档和其他程序收据摘要未变。首次加载过程中暂停客户端并插入GPU基准曾导致菜单atlas色块；
独立冷启动的菜单与读档面板未复现，底层原因尚未定位。运行基准前应等待菜单加载完毕，
多GPU客户端并发稳定性仍待验证。
