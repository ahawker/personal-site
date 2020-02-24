---
layout: post
title: Edit git commit message during interactive rebase
date: 2020-02-24 11:12:00-8000
author: me
category: dailies
tags: [git, rebase, commit]
keywords: [git, rebase, commit]
---

Previously, this is how I would edit `git` commit messages beyond `HEAD` within the history.

```bash
$ git rebase -i ${HASH}^1
...Mark commits with `edit` command
$ git commit --amend
...Update message
$ git rebase --continue
```

Thankfully there is a shortcut for this flow as it's a bit cumbersome.

```bash
$ git rebase -i ${HASH}^1
...Mark commits with `reword` command
...Update message
```

More info in the git docs [here](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History).
