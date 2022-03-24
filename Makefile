up: docker-up
down: docker-down
restart: docker-down docker-up
init: docker-down-clear docker-pull docker-build docker-up slim-init
test: slim-test

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down --remove-orphans

docker-down-clear:
	docker-compose down -v --remove-orphans

docker-pull:
	docker-compose pull

docker-build:
	docker-compose build

slim-init: slim-composer-install

slim-composer-install:
	docker-compose run --rm slim-php-cli composer install

slim-wait-db:
	until docker-compose exec -T slim-postgres pg_isready --timeout=0 --dbname=app ; do sleep 1 ; done

slim-migrations:
	docker run --rm -v ${PWD}:/app --workdir=/app alpine cp ./config/db_example.php ./config/db.php
	docker run --rm -v ${PWD}:/app --workdir=/app alpine cp ./config/params_example.php ./config/params.php
	docker-compose run --rm slim-php-cli php yii migrate --migrationPath=@yii/rbac/migrations --interactive=0
	docker-compose run --rm slim-php-cli php yii migrate --interactive=0

slim-fixtures:
	docker-compose run --rm slim-php-cli php yii fixture "*" --interactive=0

slim-test:
	docker-compose run --rm slim-php-cli php bin/phpunit