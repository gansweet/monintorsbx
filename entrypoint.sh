#!/bin/bash
set -e

# --- 环境变量列表，用于 cloudsbx.sh 脚本内部使用 ---
# 仅保留用户需要设置的简写变量名，与 cloudsbx.sh 脚本片段中的变量保持一致
CLOUDSBX_PORT_VARS=(
    "vlpt" "vmpt" "hypt" "tupt" "xhpt" "vxpt" "anpt" "arpt" "sspt" "sopt" 
)
# 额外配置变量，也使用用户需设置的简写或常用名
CLOUDSBX_CONFIG_VARS=(
    "uuid" "ym_vl_re" "cdnym" "argo" "agn" "agk" "ippz" "warp" "name"
)

# --- 1. 定义 cfmonitor 的必需变量检查 ---
# 检查 CF_WORKER_URL, CF_SERVER_ID, 和 CF_API_KEY 三个变量是否全部设置
CF_REQUIRED=0
if [[ -n "$CF_WORKER_URL" && -n "$CF_SERVER_ID" && -n "$CF_API_KEY" ]]; then
    CF_REQUIRED=1
fi

# --- 2. 定义 cloudsbx 的必需变量检查 (检查至少一个端口号) ---
CLOUDSBX_REQUIRED=0
for var in "${CLOUDSBX_PORT_VARS[@]}"; do
    # 检查 Docker 传入的端口变量
    if [ -n "${!var}" ]; then
        CLOUDSBX_REQUIRED=1
        break # 只要找到一个端口，即满足安装条件
    fi
done

# --- 3. 自动安装和启动逻辑 ---

# 只有在用户没有指定任何 Docker 命令时，才进行自动安装
if [ "$#" -eq 0 ]; then
    
    SERVICES_STARTED=0
    
    # --- 3.1 自动安装 cfmonitor ---
    if [ "$CF_REQUIRED" -eq 1 ]; then
        echo "--- ⚙️ 发现 cfmonitor 所有关键环境变量，开始自动安装和启动 ---"
        
        # 构造 cfmonitor 的安装参数
        CF_INSTALL_FLAGS="-u $CF_WORKER_URL -s $CF_SERVER_ID -k $CF_API_KEY"
        
        # 可选参数
        if [ -n "$CF_INTERVAL" ]; then 
            CF_INSTALL_FLAGS="$CF_INSTALL_FLAGS -i $CF_INTERVAL"
        fi 
        
        # ⚠️ 修正：调用 cf-vps-monitor.sh
        echo "执行 cfmonitor 安装命令: /usr/local/bin/cf-vps-monitor.sh install $CF_INSTALL_FLAGS"
        /usr/local/bin/cf-vps-monitor.sh install $CF_INSTALL_FLAGS
        
        /usr/local/bin/cf-vps-monitor.sh start
        SERVICES_STARTED=1
    fi
    
    # --- 3.2 自动安装 cloudsbx ---
    if [ "$CLOUDSBX_REQUIRED" -eq 1 ]; then
        echo "--- ⚙️ 发现 cloudsbx 端口配置，开始自动安装 ---"
        
        # 构造 export 变量列表
        CLOUDSBX_EXPORT_COMMAND=""
        
        # 导出端口变量
        for var in "${CLOUDSBX_PORT_VARS[@]}"; do
            if [ -n "${!var}" ]; then
                CLOUDSBX_EXPORT_COMMAND="$CLOUDSBX_EXPORT_COMMAND $var=\"${!var}\""
            fi
        done
        # 导出其他配置变量
        for var in "${CLOUDSBX_CONFIG_VARS[@]}"; do
            if [ -n "${!var}" ]; then
                CLOUDSBX_EXPORT_COMMAND="$CLOUDSBX_EXPORT_COMMAND $var=\"${!var}\""
            fi
        done

        # 执行 cloudsbx 安装 (使用 'install' 命令)
        echo "执行 cloudsbx 临时 export 并在子 shell中安装..."
        # 使用 eval 配合变量执行脚本
        eval $CLOUDSBX_EXPORT_COMMAND /usr/local/bin/cloudsbx.sh install
        
        SERVICES_STARTED=1
    fi
    
    # --- 3.3 保持容器在前台运行 ---
    if [ "$SERVICES_STARTED" -eq 1 ]; then
        echo "✅ 容器已进入前台运行模式..."
        exec tail -f /dev/null
    fi
fi

# --- 4. 命令行参数处理 (核心逻辑不变) ---

# 如果没有参数传入，且没有自动启动，显示帮助/菜单
if [ "$#" -eq 0 ]; then
    echo "--- 📦 Dockerized Multi-Tool (Headless Configuration via ENV) ---"
    echo "Required ENV for cfmonitor (Auto-Install): CF_WORKER_URL, CF_SERVER_ID, CF_API_KEY"
    echo "Required ENV for cloudsbx (Auto-Install): At least one port variable must be set (e.g., ${CLOUDSBX_PORT_VARS[*]})"
    echo "cloudsbx config variables: ${CLOUDSBX_CONFIG_VARS[*]}"
    echo ""
    echo "Usage: docker run [IMAGE] [COMMAND] [ARGS...]"
    echo "  cfmonitor [install|start|status|...]"
    echo "  cloudsbx [rep|install|...]"
    exit 0
fi

# 确保在执行 cloudsbx 命令时，所有相关的环境变量都被传递
if [ "$1" = "cloudsbx" ]; then
    # 导出所有可能的变量给子进程
    for var in "${CLOUDSBX_PORT_VARS[@]}" "${CLOUDSBX_CONFIG_VARS[@]}"; do
        if [ -n "${!var}" ]; then
            export $var="${!var}"
        fi
    done
fi

# 根据第一个参数决定执行哪个脚本
case "$1" in
    cfmonitor)
        shift
        # ⚠️ 修正：调用 cf-vps-monitor.sh
        exec /usr/local/bin/cf-vps-monitor.sh "$@"
        ;;
    cloudsbx)
        shift
        exec /usr/local/bin/cloudsbx.sh "$@"
        ;;
    install|uninstall|start|stop|restart|status|logs|config|test|menu)
        # ⚠️ 修正：默认执行 cf-vps-monitor.sh 的服务管理命令
        exec /usr/local/bin/cf-vps-monitor.sh "$@"
        ;;
    *)
        echo "Unknown command or script: $1" >&2
        exit 1
        ;;
esac
