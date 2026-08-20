# 从零部署完整示例

本教程提供一个**从零开始**部署 Flarum 论坛的完整示例：从拉取镜像、创建目录结构，到编写 `docker-compose.yml` 与 `.env` 文件，最后启动并访问论坛。所有文件内容均为完整可直接复制的版本。

> 如果你更希望按步骤逐步了解每一步的含义，请阅读[快速开始](./quickstart.md)；本页侧重于"完整示例"，所有命令与文件可直接复制运行。

## 1. 拉取镜像

```bash
# 从 Docker Hub 拉取
docker pull forkdo/flarum:latest

# 或从 GHCR 拉取
docker pull ghcr.io/forkdo/flarum:latest

# 或直接由源码构建
docker build -t forkdo/flarum:latest https://github.com/forkdo/docker-flarum.git
```

## 2. 创建目录结构

```bash
mkdir -p /mnt/docker/flarum/{assets,extensions,storage/logs,nginx}
mkdir -p /mnt/docker/mysql/db
```

目录用途：

| 宿主目录 | 容器内卷路径 | 用途 |
| -------- | ------------ | ---- |
| `/mnt/docker/flarum/assets` | `/flarum/app/public/assets` | Flarum 静态资源 |
| `/mnt/docker/flarum/extensions` | `/flarum/app/extensions` | Flarum 扩展目录 |
| `/mnt/docker/flarum/storage/logs` | `/flarum/app/storage/logs` | Flarum 日志 |
| `/mnt/docker/flarum/nginx` | `/etc/nginx/flarum` | nginx 自定义 location |
| `/mnt/docker/mysql/db` | `/var/lib/mysql` | MariaDB 数据 |

## 3. 编写 docker-compose.yml

创建 `docker-compose.yml`：

```yml
services:
  flarum:
    image: forkdo/flarum:latest
    container_name: flarum
    env_file:
      - ./flarum.env
    volumes:
      - /mnt/docker/flarum/assets:/flarum/app/public/assets
      - /mnt/docker/flarum/extensions:/flarum/app/extensions
      - /mnt/docker/flarum/storage/logs:/flarum/app/storage/logs
      - /mnt/docker/flarum/nginx:/etc/nginx/flarum
    ports:
      - "80:80"
    depends_on:
      - mariadb

  mariadb:
    image: mariadb:10.5
    container_name: mariadb
    environment:
      - MYSQL_ROOT_PASSWORD=change_me_root_password
      - MYSQL_DATABASE=flarum
      - MYSQL_USER=flarum
      - MYSQL_PASSWORD=change_me_db_password
    volumes:
      - /mnt/docker/mysql/db:/var/lib/mysql
```

## 4. 编写环境变量文件 flarum.env

创建 `flarum.env`（与 compose 同目录）：

```
# 调试模式（生产环境保持 false）
DEBUG=false

# 论坛访问地址（必填）
FORUM_URL=http://domain.tld

# 数据库配置
DB_HOST=mariadb
DB_NAME=flarum
DB_USER=flarum
DB_PASS=change_me_db_password
DB_PREF=flarum_
DB_PORT=3306

# 首次安装的管理员账号（仅首次安装需要）
# /!\ 管理员密码至少 8 个字符 /!\
FLARUM_ADMIN_USER=admin
FLARUM_ADMIN_PASS=change_me_admin_password
FLARUM_ADMIN_MAIL=admin@domain.tld
FLARUM_TITLE=My Flarum Forum
```

> 请务必修改所有 `change_me_*` 占位符为强密码，尤其是 `DB_PASS` 需与 compose 中 MariaDB 的 `MYSQL_PASSWORD` 保持一致。

## 5. 启动服务

```bash
# 先启动数据库，等待其初始化完成
docker compose up -d mariadb

# 稍等片刻，等数据库创建完成后再启动 flarum
docker compose up -d flarum
```

查看日志：

```bash
docker compose logs -f flarum
```

## 6. 访问论坛

启动完成后，在浏览器中访问：

```
http://domain.tld
```

使用 `FLARUM_ADMIN_USER` / `FLARUM_ADMIN_PASS` 登录后台。

## 常见问题

### 500 错误 "Something went wrong"

将 `flarum.env` 中的 `DEBUG` 改为 `true`，重启容器后在浏览器中即可看到具体错误信息：

```bash
docker compose restart flarum
```

排查完成后记得改回 `DEBUG=false`。

### 访问不到论坛

- 检查端口映射是否正确（`docker compose ps`）。
- 确认 `FORUM_URL` 与访问地址一致。
- 生产环境通常需要反向代理（Traefik、Nginx、Caddy 等）来提供 HTTPS 与域名解析，请将请求转发到容器的 80 端口。

---

下一步：[环境变量与配置详解](./configuration.md)
