# 进阶：自定义 nginx、composer 仓库、PHP 扩展等

本教程涵盖镜像的高级用法，包括自定义 nginx 配置、安装额外 PHP 扩展、使用私有 composer 仓库等。

## 安装额外的 PHP 扩展

镜像基于 Alpine Linux，可通过 `PHP_EXTENSIONS` 环境变量在**容器启动时**用 `apk` 安装额外的 PHP 扩展。

```yml
services:
  flarum:
    image: forkdo/flarum:latest
    container_name: flarum
    environment:
      - PHP_EXTENSIONS=gmp session brotli
    volumes:
      - /mnt/docker/flarum/assets:/flarum/app/public/assets
      - /mnt/docker/flarum/extensions:/flarum/app/extensions
      - /mnt/docker/flarum/storage/logs:/flarum/app/storage/logs
      - /mnt/docker/flarum/nginx:/etc/nginx/flarum
```

上面的例子会安装 `php85-gmp`、`php85-session`、`php85-brotli`。

你可以在 Alpine 包仓库查找可用的 PHP 扩展：

[https://pkgs.alpinelinux.org/packages?name=php85-*&branch=v3.21&arch=x86_64](https://pkgs.alpinelinux.org/packages?name=php85-*&branch=v3.21&arch=x86_64)

> 注意：`PHP_EXTENSIONS` 是**启动时**安装的，修改后需要重建/重启容器才生效。它安装的是 PHP 运行时扩展，与 Flarum 扩展（通过 `extension` 脚本安装）是两回事。

## 自定义 nginx vhost

镜像默认的 nginx 配置已可直接运行 Flarum。如需自定义 location 规则，可挂载 `/etc/nginx/flarum` 卷，并在其中创建 `custom-vhost-flarum.conf` 文件。

在宿主机创建 `/mnt/docker/flarum/nginx/custom-vhost-flarum.conf`：

```nginx
# 自定义 nginx vhost 示例
# 修复 fof/sitemap 扩展的 nginx 问题 (https://github.com/FriendsOfFlarum/sitemap)

location = /sitemap.xml {
  try_files $uri $uri/ /index.php?$query_string;
}
```

并确保 compose 中已挂载该目录：

```yml
volumes:
  - /mnt/docker/flarum/nginx:/etc/nginx/flarum
```

修改后重启容器即可生效。

## 自定义 composer 仓库

镜像支持通过文件方式配置额外的 composer 仓库，适用于安装私有或本地扩展。

在数据卷 `/mnt/docker/flarum/extensions/composer.repositories.txt` 中，按 `仓库名|JSON` 格式写入：

```
my_private_repo|{"type":"path","url":"extensions/*/"}
my_public_repo|{"type":"vcs","url":"https://github.com/my/repo"}
```

容器启动时会自动将这些仓库加入 composer 配置（详见 `rootfs/usr/local/bin/startup`）。

### 示例：安装 GitHub 私有仓库扩展

1. 在 `/mnt/docker/flarum/extensions/composer.repositories.txt` 中添加：

```
username|{"type":"vcs","url":"https://github.com/username/my-private-repo"}
```

2. 在 GitHub 创建一个拥有私有仓库读取权限的 token：

[https://github.com/settings/tokens](https://github.com/settings/tokens)

3. 通过环境变量 `GITHUB_TOKEN_AUTH` 设置该 token：

```
GITHUB_TOKEN_AUTH=XXXXXXXXXXXXXXX
```

容器启动时会自动配置 composer 的 GitHub OAuth 认证。

4. 在 `/mnt/docker/flarum/extensions/list` 文件中添加要安装的扩展：

```
username/my-private-repo:0.1.0
```

重启容器后，该私有扩展会被自动安装。

> 参考：[Composer 修改仓库文档](https://getcomposer.org/doc/03-cli.md#modifying-repositories)

## 本地开发 / 手动构建

如需本地构建镜像进行开发：

```bash
docker buildx bake \
  -f ./docker-bake.hcl \
  --push=false \
  --no-cache \
  dev
```

`docker-bake.hcl` 定义了 `dev`、`main`、`all` 三组构建目标，分别对应不同分支与镜像标签（详见[首页](./index.md)）。

## 反向代理

生产环境通常需要反向代理（Traefik、Nginx、Caddy、HAProxy、H2O 等）提供 HTTPS 与域名解析。本镜像本身只监听 `FLARUM_PORT`（默认 80），反向代理将请求转发到该端口即可。反向代理的配置不在本教程范围内。

---

返回[首页](./index.md)
