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

### 镜像如何判断 Flarum 是否已安装过

容器启动时，`startup` 脚本通过检查以下两个文件之一是否存在，来判断 Flarum 是否已安装（详见 `rootfs/usr/local/bin/startup`）：

| 标记文件 | 说明 |
| ---- | ---- |
| `/flarum/app/public/assets/rev-manifest.json` | Flarum 安装时生成的前端资源清单 |
| `/flarum/app/public/assets/._flarum-installed.lock` | 首次安装成功时脚本自动创建的空标记文件 |

- **任一文件存在** → 判定为已安装，跳过安装，直接生成 `config.php` 并启动。
- **都不存在** → 判定为首次安装，需要提供 `FLARUM_ADMIN_*` 变量，否则报错退出。

> :warning: **注意挂载空目录的坑**：如果把 `/flarum/app/public/assets` 挂载到一个空的宿主机目录（例如恢复备份、迁移数据卷），标记文件不存在，容器会被误判为首次安装，从而要求管理员变量并反复重启。此时：
> 1. 若数据库已有数据（迁移/恢复场景），手动创建标记文件即可跳过安装：
>    ```bash
>    touch /srv/flarum/assets/._flarum-installed.lock
>    docker compose restart flarum
>    ```
> 2. 若确实是全新安装，则正常填写 `FLARUM_ADMIN_*` 变量即可，安装成功后脚本会自动创建标记文件。

## 变量详解

### FORUM_URL（必填）

论坛对外访问的完整地址，例如 `http://forum.example.com` 或 `https://forum.example.com`。该值会被写入 Flarum 的 `config.php`，用于生成绝对链接。

### 数据库相关变量

- `DB_HOST`：数据库主机名。默认 `mariadb`，与 docker-compose 中 mariadb 服务名一致即可。
- `DB_PASS`：数据库密码，**必填**，需与 MariaDB 容器的 `MYSQL_PASSWORD` 保持一致。
- `DB_PREF`：表前缀，例如 `flarum_`。留空则不使用前缀。
- `DB_PORT`：默认 `3306`。

#### 数据库不在本栈内（外部 MySQL / 独立 mysql 栈）的情况

快速开始中的示例将数据库作为同栈内的 `mariadb` 服务一并部署。如果你的 MySQL 运行在**独立的 compose 栈**或**外部宿主机**上，需要额外注意：

1. **DB_HOST 指向数据库可达地址**，常见三种：
   - 同一台宿主机、独立栈的 MySQL（通过宿主机端口映射暴露 3306）：`DB_HOST=host.docker.internal`，并在 compose 中为 flarum 服务添加 `extra_hosts`：
     ```yml
     services:
       flarum:
         extra_hosts:
           - host.docker.internal:host-gateway
     ```
   - 另一台宿主机 / 远程数据库：`DB_HOST=<该主机的 IP 或域名>`（需保证网络可达、3306 端口已放行）。
   - 两个栈共享同一外部 Docker 网络（如 `sharenet`）：`DB_HOST=mysql`（或对方服务名），并把两个栈都加入该网络。
2. **数据库账号与权限**：`DB_USER` / `DB_PASS` 使用外部 MySQL 中对该库有权限的账号（如 `root` 或专用账号），需与外部库的实际凭据一致。
3. **库与表前缀**：确认外部库中已创建 `DB_NAME` 指定的数据库，且表前缀（`DB_PREF`）与已有数据一致；若是从备份恢复的库，注意表前缀必须匹配（例如备份中表名为 `bbs_posts`，则 `DB_PREF=bbs_`）。
4. **不需要同栈数据库服务**：此时 compose 中只需 flarum 一个服务，无需 `depends_on` 数据库，也不要定义 `mariadb` 服务。
5. **首次启动前**确认外部库已就绪（库已创建、数据已恢复），否则容器可能因连不上库而反复重启。

> 若外部库已有数据（迁移/恢复场景），还需按前文「镜像如何判断 Flarum 是否已安装过」创建标记文件，避免被误判为首次安装。

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
