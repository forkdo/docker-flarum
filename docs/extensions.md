# 安装 / 升级 / 移除 Flarum 扩展

本镜像内置了一个 **`extension` 包装脚本**（`/usr/local/bin/extension`），专门用于通过 Composer 管理 Flarum 扩展。推荐使用它而不是直接调用 `composer`，因为它会自动处理容器内的权限（以 UID/GID 运行）并在操作后清理 Flarum 缓存。

Flarum 扩展列表可在这里查找：[https://flarum.org/extensions](https://flarum.org/extensions)

## 安装扩展

在运行中的容器里执行：

```sh
docker exec -ti flarum extension require flarum/mentions
```

将 `flarum/mentions` 替换为你要安装的扩展包名。脚本会自动：

1. 以容器用户身份执行 `composer require`
2. 将扩展包名记录到 `/flarum/app/extensions/list` 文件
3. 清理 Flarum 缓存

## 移除扩展

```sh
docker exec -ti flarum extension remove flarum/mentions
```

脚本会执行 `composer remove`，并从 `list` 文件移除该扩展。

## 列出已安装扩展

```sh
docker exec -ti flarum extension list
```

输出 `/flarum/app/extensions/list` 中记录的扩展列表。

## 升级扩展

`extension` 脚本会把未知命令透传给 Composer，因此可以直接：

```sh
# 升级所有扩展
docker exec -ti flarum extension update

# 升级指定扩展到指定版本
docker exec -ti flarum extension require vendor/package:^2.0
```

也可以先查看已安装的扩展及版本：

```sh
docker exec -ti flarum extension show
```

## 扩展的持久化与自动重装

关键机制：脚本会把安装的扩展记录到 **`/flarum/app/extensions/list`** 文件。由于该路径位于数据卷 `/flarum/app/extensions` 中，**容器重建后扩展列表不会丢失**。

容器启动时，`startup` 脚本会读取 `list` 文件，并自动重新 `composer require` 所有已记录的扩展（详见 `rootfs/usr/local/bin/startup`）。

因此：

- 只要挂载了 `/flarum/app/extensions` 卷，扩展列表就能跨容器重建保留。
- 升级镜像后重启容器，已安装的扩展会自动恢复。

## 直接使用 Composer

如果确实需要直接调用 Composer，可以（注意以正确的用户运行，避免权限问题）：

```sh
docker exec -u 991:991 -ti flarum composer require flarum/mentions
```

但官方推荐使用 `extension` 脚本，因为它已处理权限和缓存目录（`COMPOSER_CACHE_DIR=/flarum/app/extensions/.cache`）。

## 安装 PHP 运行时扩展（非 Flarum 扩展）

如果你需要的是 PHP 运行时扩展（如 `php85-gmp`、`php85-session`），请在 compose 中通过 `PHP_EXTENSIONS` 环境变量指定（见[进阶教程](./advanced.md)），而不是用 `extension` 脚本。

---

下一步：[升级 Flarum 容器](./upgrade.md)
