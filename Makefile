PROJECT_PATH := $(shell pwd)
ARGS := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
SPLIT_LINE := "\033[44;32m >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> \033[0m "

export PROJECT_PATH
.PHONY: $(ARGS)

service:
	@echo -e $(SPLIT_LINE)"\033[33m$@\033[0m"
	cd src/app && GOOS=linux GOARCH=amd64 go build -o $(PROJECT_PATH)/bin/service .

.PHONY: protos
protos:
	@echo -e $(SPLIT_LINE)"\033[33m$@\033[0m"
	./tools/build_proto_go.sh