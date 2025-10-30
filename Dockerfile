# 使用轻量级的 Alpine Linux 作为基础镜像
FROM alpine:latest

# 安装 bash 和 curl (cfmonitor.sh可能需要curl来测试连接或发送数据)
# cloudsbx.sh 也有使用 curl/wget 的逻辑
RUN apk update && \
    apk add --no-cache bash curl wget

# 设置工作目录
WORKDIR /app

# 将本地脚本复制到镜像中
# cfmonitor.sh - VPS 监控脚本
COPY cfmonitor.sh /usr/local/bin/cfmonitor.sh
# cloudsbx.sh - 另一个脚本 (可能是一个工具箱或特定服务)
COPY cloudsbx.sh /usr/local/bin/cloudsbx.sh

# 确保脚本有执行权限
RUN chmod +x /usr/local/bin/cfmonitor.sh /usr/local/bin/cloudsbx.sh

# 复制入口点脚本
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 设置容器的默认入口点
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# 默认命令 (如果没有在 docker run 中指定其他命令)
CMD ["menu"]
