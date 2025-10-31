FROM debian:12-slim
LABEL maintainer="yourname <you@example.com>" \
      description="Argosbx / Cloudsbx 一键脚本容器版" \
      version="v1.0"

# 安装必要依赖
WORKDIR /app
ENV HOME=/app
RUN apt-get update && apt-get install -y curl bash procps iproute2 cron && rm -rf /var/lib/apt/lists/*

COPY cfmonitor.sh /app/cfmonitor.sh
COPY cloudsbx.sh /app/cloudsbx.sh
COPY start.sh /app/entrypoint.sh

RUN chmod +x /app/cfmonitor.sh /app/entrypoint.sh /app/cloudsbx.sh && chmod -R 777 /app
RUN mkdir -p /app/.cf-vps-monitor/logs && \
    chmod -R 777 /app/.cf-vps-monitor

EXPOSE 7860
ENV API_KEY=""
ENV SERVER_ID=""
ENV WORKER_URL=""

EXPOSE 7860 80 443 8080 8443 2053 2083 2087 2096 3000

# 默认启动命令
ENTRYPOINT ["/entrypoint.sh"]
