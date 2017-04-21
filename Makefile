.DEFAULT_GOAL := help

.PHONY: clean
clean: ## Clean local compiled site.
	bundle exec jekyll clean

.PHONY: serve
serve: ## Serve locally at http://localhost:4000.
	bundle exec jekyll serve

.phony: help
help: ## Print Makefile usage.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
