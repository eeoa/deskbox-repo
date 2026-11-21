# Quake II · Yamagi ARM64

当前资源 `8.50-deskbox.2`，需要 Desk Box `0.15.0-dev.39` 或更新版本的 Quake II 入口。

使用 Debian trixie/contrib 的原版 `yamagi-quake2` / `yamagi-quake2-core` 8.50+dfsg-1 ARM64 包。引擎、GL3 渲染器和游戏逻辑库保持原字节，依赖固定 SHA256，经签名 Debian 索引解析并复用已有共享包，不执行维护脚本。来源和许可随 Debian 包保留；对应源码见 https://deb.debian.org/debian/pool/contrib/y/yquake2/ 。

安装时从 Yamagi 官方镜像取得原始 Quake II 3.14 试玩 ZIP，验证完整归档与 PAK 的 SHA256，只提取试玩数据、玩家模型与原始许可，不运行归档中的 Windows 程序。试玩数据不随 APK、资源仓库或依赖包分发。首次安装需要网络，已有 `pak0.pak` 时保留用户内容。

数据在 `$HOME/Games/QuakeII/baseq2`，引擎配置与存档沿用 `$HOME/.yq2/baseq2`。完整版用户可将自己的完整、已更新的 baseq2 数据（pak0/pak1/pak2 及视频等）放入数据目录；不要将完整版补丁应用到试玩数据。卸载保留这两处内容。

通过上游 `cddir` 参数显式加入只读包视图，让独立引擎包和核心包中的 `game.so` 一起参与搜索；用户数据与存档位置不变。

建议键盘和鼠标，默认60帧上限、关闭忙等，采用GL3。启动脚本消费公共GNU图形能力：高通KGSL使用原有直通路径，其他支持设备自动使用系统Vulkan/Venus，否则软件回退；硬件内部预算1920×1080，桌面显示输出保持原有模式。UI比例按Android密度和内部渲染比例补偿。独立Activity、前台Service和X11 :20负责窗口与生命周期，公共平台不含游戏专用逻辑。

上游资料：
- https://github.com/yquake2/yquake2/tree/QUAKE2_8_50/doc
- https://packages.debian.org/trixie/yamagi-quake2
- https://deponie.yamagi.org/quake2/idstuff/q2-314-demo-x86.exe
