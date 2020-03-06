---
layout: post
title: Deploy Jekyll site to GitHub Pages branch
date: 2020-03-05 18:51:00-8000
author: me
category: dailies
tags: [jekyll, github, make]
keywords: [jekyll, github, make]
---

Pushing code and letting GitHub build your Jekyll website is nice and simple. However, you're limited to subset of plugins supported by GitHub, found [here](https://help.github.com/en/github/working-with-github-pages/about-github-pages-and-jekyll#plugins).

It's easy enough to build your website locally or through a CI/CD pipeline. Here is a dead simple example using [make](https://en.wikipedia.org/wiki/Make_(software)).

<figure class="fullwidth">
```
TS      ?= $(shell date -u)
COMMIT  ?= $(shell git rev-parse --short HEAD)
JEKYLL  := bundle exec jekyll

DEPLOY_ORIGIN := $(shell git config remote.origin.url)
DEPLOY_BRANCH := gh-pages
DEPLOY_DIR    := _site

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
```
</figure>

Usage: **`$ make deploy`**.

Take a look at the [gh-pages](https://github.com/ahawker/personal-site/tree/gh-pages) branch or the [Makefile](https://github.com/ahawker/personal-site/blob/master/Makefile) for this website as examples.