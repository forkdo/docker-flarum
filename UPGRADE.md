# Guide for upgrade your flarum container

### Upgrade

:warning: Backup your database, config.php, composer.lock and assets folder  
:warning: Disable all 3rd party extensions prior to upgrading in panel admin.

1 - Update your docker-compose file, see an example [here](#2---docker-composeyml)

```yml
services:
  flarum:
    image: idevsig/flarum:1.8.9
    ...
```

2 - Pull the last docker images

```sh
docker pull idevsig/flarum:1.8.9
docker-compose stop flarum
docker-compose rm flarum
docker-compose up -d flarum
```

3 - Updating your database and removing old assets & extensions

```sh
docker exec -ti flarum php /flarum/app/flarum migrate
docker exec -ti flarum php /flarum/app/flarum cache:clear
```

After that your upgrade is finish. :tada: :tada:
