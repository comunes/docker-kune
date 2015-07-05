all: build

build:
	@docker build --tag=${USER}/kune .

run:
	@docker run --name=kune -d -p 22001:22 -p 8888:8888 -p 9091:9091 \
	  -p 9090:9090 -p 5222:5222 -p 5223:5223 -p 7777:7777 \
	  -p 7070:7070 -p 7443:7443 -p 5229:5229 -p 5269:5269 \
	${USER}/kune

create:
	@docker create --name=kune -p 22001:22 -p 8888:8888 -p 9091:9091 \
	  -p 9090:9090 -p 5222:5222 -p 5223:5223 -p 7777:7777 \
	  -p 7070:7070 -p 7443:7443 -p 5229:5229 -p 5269:5269 \
	${USER}/kune
