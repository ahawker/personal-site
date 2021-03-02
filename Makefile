.DEFAULT_GOAL := help

TS      ?= $(shell date -u)
COMMIT  ?= $(shell git rev-parse --short HEAD)
JEKYLL  := bundle exec jekyll

DEPLOY_ORIGIN := $(shell git config remote.origin.url)
DEPLOY_BRANCH := gh-pages
DEPLOY_DIR    := _site

.PHONY: build
build:  ## Build site.
	@$(JEKYLL) build --drafts

.PHONY: clean
clean:  ## Clean local compiled site.
	@$(JEKYLL) clean

.PHONY: deploy
deploy: clean  ## Build and deploy site.
	@(git clone -b $(DEPLOY_BRANCH) $(DEPLOY_ORIGIN) $(DEPLOY_DIR) && \
		JEKYLL_ENV=production $(JEKYLL) build && \
		cd $(DEPLOY_DIR) && \
		git add -A && \
		git commit -am "Deployed $(COMMIT) at $(TS)" && \
		git push origin $(DEPLOY_BRANCH))

.PHONY: install
install: ## Install dependencies necessary to run site.
	@bundle install --path vendor/bundle && yarn install && yarn run primer-sync

.PHONY: serve
serve:  ## Serve locally at http://localhost:4000.
	@$(JEKYLL) serve --drafts

.phony: help
help: ## Print Makefile usage.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
