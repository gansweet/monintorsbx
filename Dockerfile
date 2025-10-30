# 使用轻量级的 Alpine Linux 作为基础镜像
FROM alpine:latest

# 安装 bash 和 curl (cfmonitor.sh可能需要curl来测试连接或发送数据)
# cloudsbx.sh 也有使用 curl/wget 的逻辑
# 安装 bash 是必要的，因为 entrypoint.sh 是 bash 脚本
RUN apk update && \
    apk add --no-cache bash curl wget

# 设置工作目录
WORKDIR /app

# 将本地脚本复制到镜像中
# cfmonitor.sh - VPS 监控脚本
# ⚠️ 修正：复制为 cf-vps-monitor.sh，以兼容脚本内部可能的硬编码或惯例
COPY cfmonitor.sh /usr/local/bin/cf-vps-monitor.sh
# cloudsbx.sh - 另一个脚本
COPY cloudsbx.sh /usr/local/bin/cloudsbx.sh

# 确保脚本有执行权限 (这一步至关重要)
RUN chmod +x /usr/local/bin/cf-vps-monitor.sh /usr/local/bin/cloudsbx.sh

# 复制入口点脚本
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 设置容器的默认入口点
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# 默认命令 (如果没有在 docker run 中指定其他命令)
CMD ["menu"]
