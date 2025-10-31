#!/bin/bash
set -e

echo ">>> 启动容器，检查环境变量..."

for script in /app/*.sh; do
    # 从脚本中提取配置
    var_name=$(grep -E '^VAR_NAME=' "$script" | cut -d'=' -f2 | tr -d '"')
    arg_mode=$(grep -E '^ARG_MODE=' "$script" | cut -d'=' -f2 | tr -d '"')
    arg_value=$(grep -E '^ARG_VALUE=' "$script" | cut -d'=' -f2- | tr -d '"')

    # 检查环境变量是否为 true
    value=$(printenv "$var_name" || echo "")
    if [ "$value" = "true" ]; then
        echo ">>> 检测到 $var_name=true"

        # 根据模式决定调用方式
        if [ "$arg_mode" = "front" ]; then
            echo "执行: bash $arg_value $script"
            bash $arg_value "$script"
        elif [ "$arg_mode" = "back" ]; then
            echo "执行: bash $script $arg_value"
            bash "$script" $arg_value
        else
            echo "执行: bash $script"
            bash "$script"
        fi
    fi
done

echo ">>> 所有任务完成。"
exec "$@"
