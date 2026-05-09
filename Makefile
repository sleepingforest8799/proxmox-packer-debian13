.PHONY: build

build:
	packer init .
	packer build .
