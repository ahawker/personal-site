.DEFAULT_GOAL := help

TS      := $(shell date -u)
JEKYLL  := bundle exec jekyll

DEPLOY_ORIGIN := $(shell git config remote.origin.url)
DEPLOY_BRANCH := gh-pages
DEPLOY_DIR    := _site

.PHONY: build
build:  ## Build site.
	@$(JEKYLL) build

.PHONY: clean
clean:  ## Clean local compiled site.
	@$(JEKYLL) clean

.PHONY: gh-pages
deploy: clean  ## Build and deploy site.
	@(git clone -b $(DEPLOY_BRANCH) $(DEPLOY_ORIGIN) $(DEPLOY_DIR) && \
		bundle exec jekyll build && \
		cd _site && \
		git add -A && \
		git commit -am "Deployed at $(TS)" && \
		git push origin $(DEPLOY_BRANCH))

.PHONY: serve
serve: ## Serve locally at http://localhost:4000.
	@$(JEKYLL) serve

.phony: help
help: ## Print Makefile usage.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
