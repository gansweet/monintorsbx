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
  
# argosbx

----------------------------------------------------------

## 一、自定义变量参数说明：

| 变量意义 | 变量名称| 在变量值""之间填写| 删除变量 | 在变量值""之间留空 | 变量要求及说明 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1、启用vless-tcp-reality-v | vlpt | 端口指定 | 关闭vless-tcp-reality-v | 端口随机 | 必选之一 【xray内核：TCP】 |
| 2、启用vless-xhttp-reality-v | xhpt | 端口指定 | 关闭vless-xhttp-reality-v | 端口随机 | 必选之一 【xray内核：TCP】 |
| 3、启用vless-xhttp-v | vxpt | 端口指定 | 关闭vless-xhttp-v | 端口随机 | 必选之一 【xray内核：TCP】 |
| 4、启用shadowsocks-2022 | sspt | 端口指定 | 关闭shadowsocks-2022 | 端口随机 | 必选之一 【singbox内核：TCP】 |
| 5、启用anytls | anpt | 端口指定 | 关闭anytls | 端口随机 | 必选之一 【singbox内核：TCP】 |
| 6、启用any-reality | arpt | 端口指定 | 关闭any-reality | 端口随机 | 必选之一 【singbox内核：TCP】 |
| 7、启用vmess-ws | vmpt | 端口指定 | 关闭vmess-ws | 端口随机 | 必选之一 【xray/singbox内核：TCP】 |
| 8、启用socks5 | sopt | 端口指定 | 关闭socks5 | 端口随机 | 必选之一 【xray/singbox内核：TCP】 |
| 9、启用hysteria2 | hypt | 端口指定 | 关闭hy2 | 端口随机 | 必选之一 【singbox内核：UDP】 |
| 10、启用tuic | tupt | 端口指定 | 关闭tuic | 端口随机 | 必选之一 【singbox内核：UDP】 |
| 11、warp开关 | warp | 详见下方15种warp出站模式图 | 关闭warp | singbox与xray内核协议都启用warp全局V4+V6 | 可选，详见下方15种warp出站模式图 |
| 12、argo开关 | argo | 填写y | 关闭argo隧道 | 关闭argo隧道 | 可选，填写y时，vmess变量vmpt必须启用，且固定隧道必须填写vmpt端口 |
| 13、argo固定隧道域名 | agn | 托管在CF上的域名 | 使用临时隧道 | 使用临时隧道 | 可选，argo填写y才可激活固定隧道|
| 14、argo固定隧道token | agk | CF获取的ey开头的token | 使用临时隧道 | 使用临时隧道 | 可选，argo填写y才可激活固定隧道 |
| 15、uuid密码 | uuid | 符合uuid规定格式 | 随机生成 | 随机生成 | 可选 |
| 16、reality域名（仅支持reality类协议） | reym | 符合reality域名规定 | amd官网 | amd官网 | 可选，使用CF类域名时：服务器ip:节点端口的组合，可作为ProxyIP/客户端地址反代IP（建议高位端口或纯IPV6下使用，以防被扫泄露）|
| 17、vmess-ws/vless-xhttp-v在客户端的host地址 | cdnym | CF解析IP的域名 | vmess-ws/vless-xhttp-v为直连 | vmess-ws/vless-xhttp-v为直连 | 可选，使用80系CDN或者回源CDN时可设置，否则客户端host地址需手动更改为CF解析IP的域名|
| 18、切换ipv4或ipv6配置 | ippz | 填写4或者6 | 自动识别IP配置 | 自动识别IP配置 | 可选，4表示IPV4配置输出，6表示IPV6配置输出 |
| 19、添加所有节点名称前缀 | name | 任意字符 | 默认协议名前缀 | 默认协议名前缀 | 可选 |
| 20、【仅容器类docker】监听端口，网页查询 | PORT | 端口指定 | 3000 | 3000 | 可选 |
| 21、【仅容器类docker】启用vless-ws-tls | DOMAIN | 服务器域名 | 关闭vless-ws-tls | 关闭vless-ws-tls | 可选，vless-ws-tls可独立存在，uuid变量必须启用 |

------------------------------------------------------------------
