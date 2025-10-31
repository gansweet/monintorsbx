FROM debian:bookworm-slim

# 安装必要依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget bash jq ca-certificates procps iproute2 openssl cron \
 && rm -rf /var/lib/apt/lists/*

COPY cfmonitor.sh /usr/local/bin/cfmonitor.sh
COPY cloudsbx.sh /usr/local/bin/cloudsbx.sh

# 确保脚本换行符和权限正确
RUN chmod +x /usr/local/bin/cfmonitor.sh /usr/local/bin/cloudsbx.sh

# 复制入口点脚本
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# 设置工作目录
WORKDIR /root

# 暴露常用端口（可自定义）
EXPOSE 80 443 8080 8443 2053 2083 2087 2096 3000

# 默认启动命令
ENTRYPOINT ["/entrypoint.sh"]
