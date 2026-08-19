# 快速开始

本教程将带你通过 `docker compose` 在几分钟内启动一个 Flarum 论坛，包含数据库（MariaDB）与论坛服务。

## 1. 准备工作

- 已安装 [Docker](https://docs.docker.com/get-docker/) 与 [Docker Compose](https://docs.docker.com/compose/install/)（新版 Docker 自带 `docker compose` 插件）。
- 一个可访问的域名（或本机 IP），用于访问论坛。本教程示例使用 `http://domain.tld`，请替换为你自己的地址。

## 2. 创建目录结构

```bash
mkdir -p /mnt/docker/flarum/{assets,extensions,storage/logs,nginx}
mkdir -p /mnt/docker/mysql/db
```

这些目录分别对应 Flarum 的静态资源、扩展、日志、nginx 配置以及 MySQL 数据卷。

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

> 说明：
> - `env_file` 指向 `.env` 文件，用于集中管理 Flarum 的环境变量（见下一步）。
> - 若使用 `docker compose` 插件，`env_file` 也可以直接使用 `flarum.env` 相对路径。
> - 端口 `80:80` 将容器内 80 端口映射到宿主机。如果宿主机 80 端口被占用，可改为 `8080:80` 等。

## 4. 编写环境变量文件 flarum.env

创建 `flarum.env`：

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

> 请务必修改所有 `change_me_*` 占位符为强密码。

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

如果页面出现 500 错误，请将 `flarum.env` 中的 `DEBUG` 改为 `true`，重启容器后在浏览器中即可看到具体错误信息，便于排查。

```bash
docker compose restart flarum
```

排查完成后记得改回 `DEBUG=false`。

### 访问不到论坛

- 检查端口映射是否正确（`docker compose ps`）。
- 确认 `FORUM_URL` 与访问地址一致。
- 生产环境通常需要反向代理（Traefik、Nginx、Caddy 等）来提供 HTTPS 与域名解析，本教程未覆盖反向代理配置。

---

下一步：[环境变量与配置详解](./configuration.md)
