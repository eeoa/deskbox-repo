# Firefox 159.0.1 · deskbox.4

需要Desk Box dev.37的系统GPU桥。安装依赖包含原版virglrenderer-android及ANGLE；桥接进程由App的公共图形层管理，脚本不启动专属后台服务。自动探测失败时使用软件渲染。

系统GPU路径采用软件WebRender、CPU Canvas2D和硬件WebGL。Pixel / Tensor实测GPU Canvas2D存在上下文错误，完整GPU合成也有回读开销，所以不默认启用这两项。KGSL设置保持原有路径，显式软件设置继续生效。

固定上游Firefox包已从上游镜像下线，现镜像SHA256完全一致的原始deb，不修改ELF。来源、官方对应源码下载地址和摘要见[binary-source.json](binary-source.json)；检查过的Termux构建配方仅用于来源说明，不声称已经确认它就是该二进制的构建提交。发布附件提供来源和配方材料，不代表整包分发合规审计已经完成。
