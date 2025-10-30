#!/bin/bash
set -e

# 如果没有参数传入，显示帮助/菜单
if [ "$#" -eq 0 ]; then
    echo "--- Dockerized Multi-Tool ---"
    echo "Usage: docker run [IMAGE] [COMMAND] [ARGS...]"
    echo ""
    echo "Commands for cfmonitor.sh:"
    echo "  cfmonitor [start|stop|install|status|logs|config|menu]"
    echo ""
    echo "Commands for cloudsbx.sh:"
    echo "  cloudsbx [install|rep|...]" # 根据 cloudsbx.sh 的功能补充
    echo ""
    exit 0
fi

# 根据第一个参数决定执行哪个脚本
# 示例: docker run my-image cfmonitor install
# 示例: docker run my-image cloudsbx rep
case "$1" in
    cfmonitor)
        # 移除第一个参数 'cfmonitor'，然后将剩余参数传递给脚本
        shift
        exec /usr/local/bin/cfmonitor.sh "$@"
        ;;
    cloudsbx)
        # 移除第一个参数 'cloudsbx'，然后将剩余参数传递给脚本
        shift
        exec /usr/local/bin/cloudsbx.sh "$@"
        ;;
    # 也可以直接执行原始脚本的命令，例如 docker run my-image install
    install|uninstall|start|stop|restart|status|logs|config|test|menu)
        # 默认执行 cfmonitor.sh 的命令 (因为 cfmonitor.sh 看起来是一个服务管理工具)
        exec /usr/local/bin/cfmonitor.sh "$@"
        ;;
    *)
        echo "Unknown command or script: $1" >&2
        exit 1
        ;;
esac
