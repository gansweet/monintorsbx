#!/bin/bash
set -e

echo ">>> 启动容器，检查环境变量..."

# 遍历镜像内的所有 *.sh 文件
for script in /app/*.sh; do
    # 从脚本中提取 VAR_NAME 的值
    var_name=$(grep -E '^VAR_NAME=' "$script" | cut -d'=' -f2 | tr -d '"')
    
    # 检查该环境变量是否存在且为 true
    if [ -n "$var_name" ]; then
        value=$(printenv "$var_name" || echo "")
        if [ "$value" = "true" ]; then
            echo ">>> 检测到环境变量 $var_name=true, 执行脚本: $script"
            bash "$script"
        fi
    fi
done

echo ">>> 所有检测完成。"
exec "$@"
