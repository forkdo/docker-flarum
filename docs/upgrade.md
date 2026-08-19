# 升级 Flarum 容器

升级 Flarum 容器（即更换镜像版本）时，请遵循以下步骤。核心原则是：**先备份，再升级，后迁移数据库与缓存**。

## 升级前准备

:warning: 备份你的数据库、`config.php`、`composer.lock` 以及 assets 目录。

:warning: 在后台管理面板中**先禁用所有第三方扩展**，再执行升级。

## 1. 更新 docker-compose 中的镜像版本

编辑 `docker-compose.yml`，将 `image` 改为目标版本：

```yml
services:
  flarum:
    image: forkdo/flarum:1.8.14
    # ... 其余配置保持不变
```

## 2. 拉取新镜像并重建容器

```sh
# 拉取新镜像
docker pull forkdo/flarum:1.8.14

# 停止并移除旧容器
docker compose stop flarum
docker compose rm flarum

# 用新镜像启动容器
docker compose up -d flarum
```

> 由于扩展列表位于数据卷 `/flarum/app/extensions` 中，容器重建后已安装的扩展会自动恢复（见[扩展教程](./extensions.md)）。

## 3. 迁移数据库并清理缓存

```sh
# 执行数据库迁移
docker exec -ti flarum php /flarum/app/flarum migrate

# 清理缓存
docker exec -ti flarum php /flarum/app/flarum cache:clear
```

## 4. 完成

升级完成后，重新启用之前禁用的第三方扩展，并在浏览器中验证论坛功能正常。🎉 🎉

## 版本选择建议

- 升级前请查阅 [Flarum 官方升级文档](https://docs.flarum.org/extend/update/) 了解各版本间的破坏性变更。
- 若从 v1.8 升级到 v2.0，请特别注意扩展兼容性，许多第三方扩展可能尚未支持 v2.0。
- 建议先在测试环境验证，再在生产环境操作。

---

下一步：[进阶：自定义 nginx、composer 仓库、PHP 扩展等](./advanced.md)
