ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PYTHON3=python3
VENV_DIR=$(ROOT_DIR)/venv3
NAME=$(shell basename $(ROOT_DIR))
ECHO=@echo
RM=rm -rf

NOTEBOOKS=$(wildcard $(ROOT_DIR)/*.ipynb)

.PHONY: help

help:
	$(ECHO) "$(NAME)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m=> %s\n", $$1, $$2}'

$(VENV_DIR):
	$(PYTHON3) -m venv $(VENV_DIR)
	$(VENV_DIR)/bin/pip install --upgrade pip
	$(VENV_DIR)/bin/pip install -Ur requirements.txt
	$(VENV_DIR)/bin/python -m bash_kernel.install

install: $(VENV_DIR) ## install dependencies
	which curl || sudo apt-get install --no-install-recommends curl
	
run: install  ## run
	$(VENV_DIR)/bin/jupyter notebook $(ROOT_DIR)/index.ipynb

%.clean: %.ipynb
	$(VENV_DIR)/bin/jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace $<

clean: $(NOTEBOOKS:.ipynb=.clean)
	$(RM) config.*
	$(RM) gravitee-kubernetes-*
	$(RM) docs

docs: $(NOTEBOOKS:.ipynb=.clean)
	mkdir $(ROOT_DIR)/docs || true
	$(VENV_DIR)/bin/jupyter nbconvert --to markdown --output-dir=docs $(ROOT_DIR)/*.ipynb
	sed -i 's/\.ipynb/\.html/g' docs/*.md # hack to fix link to other notebook
	sed -i 's/docs\/images\//images\//g' docs/*.md # hack to fix links to images
