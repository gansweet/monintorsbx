#!/bin/bash
set -e

# --- 环境变量列表，用于 cloudsbx.sh 脚本内部使用 ---
# 必须使用 CLOUDSBX_ENV 数组来列出所有可能的配置变量，以便进行检查和导出
CLOUDSBX_ENV=(
    "uuid" "port_vl_re" "port_vm_ws" "port_hy2" "port_tu" "port_xh" "port_vx" 
    "port_an" "port_ar" "port_ss" "port_so" "ym_vl_re" "cdnym" "argo" 
    "ARGO_DOMAIN" "ARGO_AUTH" "ippz" "warp" "name"
)
# 针对脚本内部的简写变量 (如 vlpt, vmpt)，我们使用它们作为 Docker 环境变量名
CLOUDSBX_PORT_VARS=(
    "vlpt" "vmpt" "hypt" "tupt" "xhpt" "vxpt" "anpt" "arpt" "sspt" "sopt" 
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
    # 检查 Docker 传入的端口变量（例如 $VLPT）
    if [ -n "${!var}" ]; then
        CLOUDSBX_REQUIRED=1
        break # 只要找到一个端口，即满足安装条件
    fi
done

# --- 3. 自动安装和启动逻辑 ---

# 只有在用户没有指定任何 Docker 命令时，才进行自动安装
if [ "$#" -eq 0 ]; then
    
    SERVICES_STARTED=0 # 用于判断是否需要保持容器运行
    
    # --- 3.1 自动安装 cfmonitor ---
    if [ "$CF_REQUIRED" -eq 1 ]; then
        echo "--- ⚙️ 发现 cfmonitor 所有关键环境变量，开始自动安装和启动 ---"
        
        # 构造 cfmonitor 的安装参数
        CF_INSTALL_FLAGS="-u $CF_WORKER_URL -s $CF_SERVER_ID -k $CF_API_KEY"
        
        # 可选参数
        if [ -n "$CF_INTERVAL" ]; then 
            CF_INSTALL_FLAGS="$CF_INSTALL_FLAGS -i $CF_INTERVAL"
        fi 
        
        # 执行 cfmonitor 安装
        /usr/local/bin/cfmonitor.sh install $CF_INSTALL_FLAGS
        /usr/local/bin/cfmonitor.sh start
        SERVICES_STARTED=1
    fi
    
    # --- 3.2 自动安装 cloudsbx ---
    if [ "$CLOUDSBX_REQUIRED" -eq 1 ]; then
        echo "--- ⚙️ 发现 cloudsbx 端口配置，开始自动安装 ---"
        
        # cloudsbx.sh 依赖于其内部变量被 export。我们必须在执行它之前，先 export 对应的端口变量。
        # ⚠️ 注意：我们不能在这里 export 所有 CLOUDSBX_ENV 列表中的变量，因为它们是脚本内部变量名。
        # 我们必须使用 Docker 传入的变量名（如 vlpt）进行 export。
        
        CLOUDSBX_EXPORT_COMMAND=""
        
        # 遍历所有端口和配置变量，如果设置了，就 export 给 cloudsbx.sh
        # 为了兼容性，我们使用用户传入的名称（如 vlpt, agn）来设置 export
        # 注意：这里我们假设用户传入的变量名与 cloudsbx.sh 内部期望的变量名一致 (如 vlpt, agn, agk)
        
        # 由于 Bash 无法可靠地动态获取所有可能的配置变量名，我们依赖用户在 docker run 时传入
        # 最稳妥的方式是：检查所有已知的端口变量，并构造一个临时的执行命令
        
        for var in "${CLOUDSBX_PORT_VARS[@]}"; do
            if [ -n "${!var}" ]; then
                CLOUDSBX_EXPORT_COMMAND="$CLOUDSBX_EXPORT_COMMAND $var=\"${!var}\""
            fi
        done
        # 额外检查 uuid, cdnym, agn, agk, name 等配置变量
        for var in uuid cdnym agn agk name; do
            if [ -n "${!var}" ]; then
                CLOUDSBX_EXPORT_COMMAND="$CLOUDSBX_EXPORT_COMMAND $var=\"${!var}\""
            fi
        done

        # 执行 cloudsbx 安装 (使用 'install' 命令)
        echo "执行 cloudsbx 临时 export 并在子 shell中安装..."
        # 使用 env -i 确保隔离，然后使用 export 变量执行脚本
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
    echo "Required ENV for cloudsbx (Auto-Install): At least one port variable must be set (e.g., vlpt, vmpt, hypt, etc.)"
    echo "cloudsbx port variables: ${CLOUDSBX_PORT_VARS[*]}"
    echo "cloudsbx config variables: uuid, cdnym, agn (ARGO_DOMAIN), agk (ARGO_AUTH), name, etc."
    echo ""
    echo "Usage: docker run [IMAGE] [COMMAND] [ARGS...]"
    echo "  cfmonitor [install|start|status|...]"
    echo "  cloudsbx [rep|install|...]"
    exit 0
fi

# 确保在执行 cloudsbx 命令时，所有相关的环境变量都被传递
if [ "$1" = "cloudsbx" ]; then
    # 构造 export 命令，确保所有 cloudsbx 配置变量被导出
    CLOUDSBX_EXPORT_COMMAND=""
    # 导出所有可能的变量给子进程
    for var in "${CLOUDSBX_PORT_VARS[@]}" uuid cdnym agn agk name; do
        if [ -n "${!var}" ]; then
            export $var="${!var}"
        fi
    done
fi

# 根据第一个参数决定执行哪个脚本
case "$1" in
    cfmonitor)
        shift
        exec /usr/local/bin/cfmonitor.sh "$@"
        ;;
    cloudsbx)
        shift
        exec /usr/local/bin/cloudsbx.sh "$@"
        ;;
    install|uninstall|start|stop|restart|status|logs|config|test|menu)
        # 默认执行 cfmonitor.sh 的服务管理命令
        exec /usr/local/bin/cfmonitor.sh "$@"
        ;;
    *)
        echo "Unknown command or script: $1" >&2
        exit 1
        ;;
esac
