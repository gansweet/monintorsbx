FROM debian:bookworm-slim

# 安装必要依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget bash jq ca-certificates procps iproute2 openssl cron \
 && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 将本地脚本复制到工作目录 /app/

COPY cfmonitor.sh /app/cfmonitor.sh
COPY cloudsbx.sh /app/cloudsbx.sh

# 确保脚本换行符和权限正确
RUN chmod +x /app/cfmonitor.sh /app/cloudsbx.sh

# 复制入口点脚本
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh

# 设置容器的默认入口点
ENTRYPOINT ["/app/entrypoint.sh"]
