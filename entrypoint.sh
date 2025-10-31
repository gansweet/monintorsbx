#!/bin/bash
set -e



echo "===== 启动 cf-vps-monitor 容器 ====="
echo "加载环境变量..."
echo "API_KEY: $API_KEY"
echo "SERVER_ID: $SERVER_ID"
echo "WORKER_URL: $WORKER_URL"
echo "--------------------------------------------"

# 执行安装脚本（自动检测是否已配置）
/app/cfmonitor.sh -i -k "$API_KEY" -s "$SERVER_ID" -u "$WORKER_URL"

echo "--------------------------------------------"
echo "安装脚本执行完毕，启动日志守护模式..."
LOG_FILE="/app/.cf-vps-monitor/logs/monitor.log"

# 若日志文件不存在则等待创建
if [ ! -f "$LOG_FILE" ]; then
  echo "等待日志文件创建..."
  mkdir -p "$(dirname "$LOG_FILE")"
  touch "$LOG_FILE"
fi

# 持续输出日志，防止容器退出
echo "正在持续监控日志输出..."
# tail -F "$LOG_FILE"
# 保持前台运行（防止容器退出）

echo ">>> 启动 Cloudsbx 容器安装环境..."
echo "当前时间：$(date)"

# 若环境变量指定了协议端口或参数(环境变量用统一小写字母-原码是小写），导入（仅保留了vless-reality,端口VLPT必须大写有效。如果未填写端口，则随机一个，便于继续部署。其它协议端口可以自行在环境变量中添加）
# export vlpt="${VLPT:-}"
# export vmpt="${VMPT:-}"
# export hypt="${HYPT:-}"
# export tupt="${TUPT:-}"
# export xhpt="${XHPT:-}"
# export vxpt="${VXPT:-}"
# export anpt="${ANPT:-}"
# export arpt="${ARPT:-}"
# export sspt="${SSPT:-}"
# export sopt="${SOPT:-}"
# export warp="${WARP:-}"
# export argo="${ARGO:-}"
# export agn="${ARGO_DOMAIN:-}"
# export agk="${ARGO_AUTH:-}"

# 启动cloudsbx脚本进行安装
bash /app/cloudsbx.sh

tail -f /dev/null
