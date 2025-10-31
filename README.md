
#  monintorsbx 
#  镜像 ghcr.io/gansweet/monintorsbx:latest


# cloudsbx   
## argosbx，填写环境变量，参考下面变量，来选择不同协议,安装对应的proxy。

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

# VPS_monitor. VPS监控面板可以部署到cloudflare上，仓库地址： https://github.com/gansweet/cf-vps-monitor
## Docker Deploy容器所需的环境变量，不填写环境变量，则不安装monitor.
    
---
- 在容器平台的变量界面中填写以下关键环境变量。这些变量会被 entrypoint.sh 读取并用于生成配置文件：

```
- 变量名,描述,示例值,对应 cfmonitor.sh 默认项
- WORKER_URL,必需，数据上报接口。 Cloudflare Worker 的 URL 地址。,https://my-monitor.yourdomain.com/,DEFAULT_WORKER_URL
- SERVER_ID,必需，节点标识。 当前 VPS/服务器的唯一标识符。,my-vps-01,DEFAULT_SERVER_ID
- API_KEY,必需，授权密钥。 用于授权的 API Key 或密钥。,your_secret_api_key_12345,DEFAULT_API_KEY
- INTERVAL  检测间隔秒 上报间隔会自动从服务器获取，无需手动设置
```
## 参数从安装的面板获取。
---
### 一键安装参数:
 - -i, --install           一键安装模式

 - -s, --server-id ID      服务器ID

 - -k, --api-key KEY       API密钥

 - -u, --worker-url URL    Worker地址

### 有些容器启动脚本本身执行完就退出了，而后台进程在容器里独立运行，但容器管理平台会认为主进程已经结束，所以状态可能一直是 starting 或立即 exited。事实已经在日志守护。正常的，就是前台无法监控到。

---
### 守护模式 vs 前台模式

| 特性        | 守护模式 (Daemon)              | 前台模式         |
| --------- | -------------------------- | ------------ |
| 进程位置      | 后台 fork                    | 前台运行         |
| 输出        | 写日志文件                      | 控制台可见        |
| Docker 状态 | 容器可能 `starting` 或 `exited` | 容器 `running` |
| 适用场景      | 长期服务/系统守护                  | 容器运行、调试      |
---


