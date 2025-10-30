#!/bin/bash
set -e

# --- 环境变量列表，用于 cloudsbx.sh 脚本内部使用 ---
CLOUDSBX_PORT_VARS=(
    "vlpt" "vmpt" "hypt" "tupt" "xhpt" "vxpt" "anpt" "arpt" "sspt" "sopt" 
)
CLOUDSBX_CONFIG_VARS=(
    "uuid" "ym_vl_re" "cdnym" "argo" "agn" "agk" "ippz" "warp" "name"
)

# --- 1. 定义 cfmonitor 的必需变量检查 ---
CF_REQUIRED=0
if [[ -n "$CF_WORKER_URL" && -n "$CF_SERVER_ID" && -n "$CF_API_KEY" ]]; then
    CF_REQUIRED=1
fi

# --- 2. 定义 cloudsbx 的必需变量检查 (检查至少一个端口号) ---
CLOUDSBX_REQUIRED=0
for var in "${CLOUDSBX_PORT_VARS[@]}"; do
    if [ -n "${!var}" ]; then
        CLOUDSBX_REQUIRED=1
        break
    fi
done

# --- 3. 自动安装和启动逻辑 ---

if [ "$#" -eq 0 ]; then
    
    SERVICES_STARTED=0
    
    # --- 3.1 自动安装 cfmonitor ---
    if [ "$CF_REQUIRED" -eq 1 ]; then
        echo "--- ⚙️ 发现 cfmonitor 所有关键环境变量，开始自动安装和启动 ---"
        
        CF_INSTALL_FLAGS="-u $CF_WORKER_URL -s $CF_SERVER_ID -k $CF_API_KEY"
        
        if [ -n "$CF_INTERVAL" ]; then 
            CF_INSTALL_FLAGS="$CF_INSTALL_FLAGS -i $CF_INTERVAL"
        fi 
        
        # ⚠️ 修正：调用 /app/cfmonitor.sh
        echo "执行 cfmonitor 安装命令: /app/cfmonitor.sh install $CF_INSTALL_FLAGS"
        /app/cfmonitor.sh install $CF_INSTALL_FLAGS
        
        /app/cfmonitor.sh start
        SERVICES_STARTED=1
    fi
    
    # --- 3.2 自动安装 cloudsbx ---
    if [ "$CLOUDSBX_REQUIRED" -eq 1 ]; then
        echo "--- ⚙️ 发现 cloudsbx 端口配置，开始自动安装 ---"
        
        CLOUDSBX_EXPORT_COMMAND=""
        
        for var in "${CLOUDSBX_PORT_VARS[@]}" "${CLOUDSBX_CONFIG_VARS[@]}"; do
            if [ -n "${!var}" ]; then
                CLOUDSBX_EXPORT_COMMAND="$CLOUDSBX_EXPORT_COMMAND $var=\"${!var}\""
            fi
        done

        echo "执行 cloudsbx 临时 export 并在子 shell中安装..."
        # ⚠️ 修正：调用 /app/cloudsbx.sh
        eval $CLOUDSBX_EXPORT_COMMAND /app/cloudsbx.sh install
        
        SERVICES_STARTED=1
    fi
    
    # --- 3.3 保持容器在前台运行 ---
    if [ "$SERVICES_STARTED" -eq 1 ]; then
        echo "✅ 容器已进入前台运行模式..."
        exec tail -f /dev/null
    fi
fi

# --- 4. 命令行参数处理 ---

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
        # ⚠️ 修正：调用 /app/cfmonitor.sh
        exec /app/cfmonitor.sh "$@"
        ;;
    cloudsbx)
        shift
        exec /app/cloudsbx.sh "$@"
        ;;
    install|uninstall|start|stop|restart|status|logs|config|test|menu)
        # ⚠️ 修正：调用 /app/cfmonitor.sh
        exec /app/cfmonitor.sh "$@"
        ;;
    *)
        echo "Unknown command or script: $1" >&2
        exit 1
        ;;
esac
