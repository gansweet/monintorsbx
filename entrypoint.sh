#!/bin/bash
set -e

echo ">>> 启动容器，检查环境变量..."

# 若环境变量指定了协议端口或参数(环境变量用统一小写字母-原码是小写），导入（仅保留了vless-reality,端口VLPT必须大写有效。如果未填写端口，则随机一个，便于继续部署。其它协议端口可以自行在环境变量中添加）
export vlpt="${VLPT:-}"

# 启动主脚本
bash /app/cfmonitor.sh
bash /app/cloudsbx.sh

# 保持前台运行（防止容器退出）
tail -f /dev/null
