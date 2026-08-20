# forkdo/flarum 使用教程

[`forkdo/flarum`](https://github.com/forkdo/docker-flarum) 是一个基于 Alpine Linux 的轻量、安全的 Flarum 论坛 Docker 镜像，内置 nginx 与 PHP-FPM，支持多平台（`linux/amd64`、`linux/arm64`），开箱即用。

本教程涵盖了从快速开始到进阶配置的完整内容。

## 目录

- [快速开始（docker compose + .env）](./quickstart.md)
- [从零部署完整示例](./example.md)
- [环境变量与配置详解](./configuration.md)
- [安装 / 升级 / 移除 Flarum 扩展](./extensions.md)
- [升级 Flarum 容器](./upgrade.md)
- [进阶：自定义 nginx、composer 仓库、PHP 扩展等](./advanced.md)

## 特性概览

- 多平台镜像：`linux/amd64`、`linux/arm64`
- 轻量且安全
- 基于 Alpine Linux
- 内置 **nginx** 与 **PHP 8.5**
- 最新 [Flarum Framework](https://github.com/flarum/framework)（v1.8.x / v2.x）
- MySQL / MariaDB 驱动
- 已配置 OPCache 扩展

## 可用的镜像标签

| 标签 | 说明 |
| ---- | ---- |
| `forkdo/flarum:latest` | 最新稳定版（v1.8.x） |
| `forkdo/flarum:1.8` | v1.8 稳定版 |
| `forkdo/flarum:2.0` | v2.0 版本 |
| `forkdo/flarum:edge` | v2.0 edge 版本 |
| `forkdo/flarum:dev` | dev 分支构建的 v1.8 |
| `forkdo/flarum:dev-edge` | dev 分支构建的 v2.0 |

> 镜像同时发布到 [Docker Hub](https://hub.docker.com/r/forkdo/flarum)（`forkdo/flarum`）与 [GHCR](https://github.com/orgs/forkdo/packages)（`ghcr.io/forkdo/flarum`）。

## 端口

- 默认：**80**（可通过 `FLARUM_PORT` 配置）

## 数据卷

| 卷路径 | 说明 |
| ------ | ---- |
| `/flarum/app/extensions` | Flarum 扩展目录 |
| `/flarum/app/public/assets` | Flarum 静态资源目录 |
| `/flarum/app/storage/logs` | Flarum 日志目录 |
| `/etc/nginx/flarum` | nginx 自定义 location 目录 |

---

下一步：[快速开始](./quickstart.md)
