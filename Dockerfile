# 使用轻量级的 Alpine Linux 作为基础镜像
FROM alpine:latest

# 安装 bash 和 curl (Bash是必需的运行时环境)

RUN apk update && \
    apk add --no-cache bash curl wget

# 设置工作目录
WORKDIR /app

# 将本地脚本复制到工作目录 /app/
# ⚠️ 修正 1: 所有文件复制到 /app/
COPY cfmonitor.sh /app/cfmonitor.sh
COPY cloudsbx.sh /app/cloudsbx.sh

# 确保脚本换行符和权限正确
RUN chmod +x /app/cfmonitor.sh /app/cloudsbx.sh

# 复制入口点脚本
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh

# 设置容器的默认入口点
ENTRYPOINT ["/app/entrypoint.sh"]
