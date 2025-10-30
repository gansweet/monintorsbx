# monintorsbx
## 安装argosb和cf_monitor的镜像。

# 📜 操作步骤和环境变量列表
 1. 环境变量列表（可用于网页设置）
    您在网页界面上需要设置以下变量来配置 cfmonitor.sh 自动启动：
    
    ```
    环境变量名,是否必需（自动启动）,示例值,描述
    CF_WORKER_URL,是,https://your-worker.your-domain.workers.dev,Cloudflare Worker 的 URL
    CF_SERVER_ID,是,MyVps-01,您的服务器ID
    CF_INTERVAL,否,60,监控数据上传间隔（秒）
    CF_API_KEY,否,your_api_key_if_needed,额外的 API 密钥
   ```

  2. 部署和运行示例
    现在，用户可以直接通过环境变量来配置并启动服务，无需进入容器执行交互式命令。
    A. 自动配置并启动 cfmonitor 服务
    在 Docker 启动命令中传入环境变量：

   ```
   docker run -d \
  --name cf-monitor-service \
  -e CF_WORKER_URL="https://my-worker.example.com" \
  -e CF_SERVER_ID="Home-VPS-01" \
  ghcr.io/gansweet/monintorsbx:latest 
  # 因为没有 COMMAND，entrypoint.sh 会自动 install & start
  ```

  B. 手动执行 cloudsbx.sh 的命令
  ```
  docker run --rm ghcr.io/gansweet/monintorsbx:latest cloudsbx rep
  ```

  C. 默认显示菜单/帮助
  如果未传入任何参数或环境变量，容器将退出并显示帮助信息：
  ```
  docker run --rm ghcr.io/gansweet/monintorsbx:latest
  ```
  
