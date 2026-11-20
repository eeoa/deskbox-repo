# GIMP

当前适配发布：**3.0.4-deskbox.3**，配套 Desk Box **0.15.0-dev.33**。
程序来自签名 Debian trixie / security ARM64 包 `3.0.4-3+deb13u11`。

`schema.json` 提供 install、launch、uninstall 三个动作，各入口带固定标签路径和
SHA256。发布载荷位于不可变标签 `gimp-v3.0.4-deskbox.3`；本说明补充在 main 上，
不移动已发布标签，不改变既有动作或软件包哈希。

依赖清单包含 326 包，共 171,835,464 字节，其中 228 个既有固定条目原样复用，
新增 98 包 / 58,392,908 字节。安装不执行 Debian maintainer scripts。
配置使用标准 GIMP3、GEGL、BABL 和 GI 环境以及 GIMP 解释器注册表；不修改上游
ELF 或 Python-Fu 插件。GTK 控件和字体按 Desk Box 显示设置缩放，使用原生
`--no-shm` 管道传输，BLAS / LAPACK 通过公共 GNU 额外库搜索目录提供。

2026-11-20 在 OPD2403 / Android 16 验证：

- 上游 Python-Fu / PDB：裁剪、缩放、亮度、透明图层和中文文字。
- 三层 XCF 保存、关闭、重开、再编辑和再次保存，PNG / JPEG 导出。
- 独立图像解码核对尺寸和像素；图层透明度修改影响预期的 5,700 个像素。
- 实际触控画笔、菜单撤销 / 重做、XCF 保存重开和 PNG 导出。
- 热重连、强制关闭且首页保持运行、卸载重装后样本和配置保留。
- VS Code / LibreOffice 安装收据不变；配套 App 构建、lint 和 128 项单元测试通过。

用户配置为 `~/.config/GIMP/3.0`，缓存为 `~/.cache/GIMP/3.0`；卸载释放软件包
引用并保留 HOME、图片及配置。自有系统配置视图位于 `~/.cache/deskbox/gimp`。

当前仅验证 CPU 图像处理，GEGL OpenCL 关闭。ADB 注入 Ctrl+Z / Ctrl+Y 的结果仍
不可靠，不能代替实体键盘验收；菜单撤销 / 重做已通过。大图性能、画笔压感、
复杂 PSD / 第三方插件及色彩管理精度未纳入本次通过范围。
