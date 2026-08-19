# 环境变量与配置详解

本镜像通过环境变量控制 Flarum 的几乎所有配置。理解这些变量是正确部署的关键。

## 通用环境变量

| 变量 | 说明 | 类型 | 默认值 |
| ---- | ---- | ---- | ------ |
| **UID** | Flarum 用户 ID | *可选* | 991 |
| **GID** | Flarum 组 ID | *可选* | 991 |
| **DEBUG** | Flarum 调试模式 | *可选* | false |
| **FORUM_URL** | 论坛访问地址 | **必填** | 无 |
| **DB_HOST** | MariaDB 实例 IP / 主机名 | *可选* | mariadb |
| **DB_USER** | MariaDB 数据库用户名 | *可选* | flarum |
| **DB_NAME** | MariaDB 数据库名 | *可选* | flarum |
| **DB_PASS** | MariaDB 数据库密码 | **必填** | 无 |
| **DB_PREF** | Flarum 表前缀 | *可选* | 无 |
| **DB_PORT** | MariaDB 数据库端口 | *可选* | 3306 |
| **FLARUM_PORT** | 容器内 Flarum 运行端口 | *可选* | 80 |
| **UPLOAD_MAX_SIZE** | 上传文件大小上限 | *可选* | 50M |
| **PHP_MEMORY_LIMIT** | PHP 内存上限 | *可选* | 128M |
| **OPCACHE_MEMORY_LIMIT** | OPcache 内存大小（MB） | *可选* | 128 |
| **LOG_TO_STDOUT** | 将 nginx / php 错误日志输出到 stdout | *可选* | false |
| **GITHUB_TOKEN_AUTH** | 用于下载私有扩展的 GitHub token | *可选* | false |
| **PHP_EXTENSIONS** | 额外安装的 PHP 扩展 | *可选* | 无 |

## 首次安装必填变量

以下变量**仅在首次安装**（容器内尚无已安装的 Flarum）时需要：

| 变量 | 说明 | 类型 | 默认值 |
| ---- | ---- | ---- | ------ |
| **FLARUM_ADMIN_USER** | 管理员用户名 | **必填** | 无 |
| **FLARUM_ADMIN_PASS** | 管理员密码 | **必填** | 无 |
| **FLARUM_ADMIN_MAIL** | 管理员邮箱 | **必填** | 无 |
| **FLARUM_TITLE** | 论坛名称 | *可选* | Docker-Flarum |

> :warning: 管理员密码（`FLARUM_ADMIN_PASS`）**至少需要 8 个字符**，否则首次安装会失败。

## 变量详解

### FORUM_URL（必填）

论坛对外访问的完整地址，例如 `http://forum.example.com` 或 `https://forum.example.com`。该值会被写入 Flarum 的 `config.php`，用于生成绝对链接。

### 数据库相关变量

- `DB_HOST`：数据库主机名。默认 `mariadb`，与 docker-compose 中 mariadb 服务名一致即可。
- `DB_PASS`：数据库密码，**必填**，需与 MariaDB 容器的 `MYSQL_PASSWORD` 保持一致。
- `DB_PREF`：表前缀，例如 `flarum_`。留空则不使用前缀。
- `DB_PORT`：默认 `3306`。

### 性能相关变量

- `UPLOAD_MAX_SIZE`：上传文件大小上限，例如 `50M`。会同时写入 nginx 与 PHP-FPM 配置。
- `PHP_MEMORY_LIMIT`：PHP `memory_limit`，例如 `128M`。
- `OPCACHE_MEMORY_LIMIT`：OPcache 内存大小（单位 MB），例如 `128`。

### 日志

- `LOG_TO_STDOUT`：设为 `true` 时，将 nginx 和 PHP 的错误日志输出到容器 stdout，便于 `docker compose logs` 查看。

### 调试

- `DEBUG`：设为 `true` 时开启 Flarum 调试模式，浏览器中会显示具体错误信息（适合排查问题）。生产环境务必保持 `false`。

### UID / GID

容器内 Flarum 进程默认以 `991:991` 运行。如果你需要与宿主机共享文件权限，可调整这两个值，但需保证数据卷目录的属主与之匹配。

## 通过 .env 文件管理

推荐使用 `env_file` 将所有变量集中到一个 `.env` 文件中（见[快速开始](./quickstart.md)）：

```yml
services:
  flarum:
    image: forkdo/flarum:latest
    env_file:
      - ./flarum.env
```

也可以直接在 compose 中通过 `environment` 定义：

```yml
services:
  flarum:
    image: forkdo/flarum:latest
    environment:
      - DEBUG=false
      - FORUM_URL=http://domain.tld
      - DB_HOST=mariadb
      - DB_NAME=flarum
      - DB_USER=flarum
      - DB_PASS=change_me
      - FLARUM_ADMIN_USER=admin
      - FLARUM_ADMIN_PASS=change_me
      - FLARUM_ADMIN_MAIL=admin@domain.tld
```

---

下一步：[安装 / 升级 / 移除 Flarum 扩展](./extensions.md)
