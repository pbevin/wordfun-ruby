.PHONY: run
run:
	docker-compose up --build

.PHONY: docker
docker:
	docker-compose build

# docker-shell:
# 	docker run --rm -it -p 5199:80 -e PGUSER=pbevin -e PGHOST=docker.for.mac.localhost --name wordfun pbevin/wordfun sh

.PHONY: release
release: docker
	docker push pbevin/wordfun

.PHONY: live
live: release
	ssh docker "cd docker/wordfun && docker-compose pull && docker-compose up -d"
