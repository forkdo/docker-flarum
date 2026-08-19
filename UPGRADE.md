# Guide for upgrade your flarum container

### Upgrade

:warning: Backup your database, config.php, composer.lock and assets folder  
:warning: Disable all 3rd party extensions prior to upgrading in panel admin.

1 - Update your docker composefile, see an example [here](#2---docker-composeyml)

```yml
services:
  flarum:
    image: forkdo/flarum:1.8.14
    ...
```

2 - Pull the last docker images

```sh
docker pull forkdo/flarum:1.8.14
docker composestop flarum
docker composerm flarum
docker composeup -d flarum
```

3 - Updating your database and removing old assets & extensions

```sh
docker exec -ti flarum php /flarum/app/flarum migrate
docker exec -ti flarum php /flarum/app/flarum cache:clear
```

After that your upgrade is finish. :tada: :tada:
