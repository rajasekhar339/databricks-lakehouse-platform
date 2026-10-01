ENV ?= dev

install:
	pip install -e ".[dev]"

test:
	pytest -q

lint:
	ruff check src tests

deploy:
	databricks bundle deploy -t $(ENV)
