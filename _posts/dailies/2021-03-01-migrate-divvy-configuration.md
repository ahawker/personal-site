---
layout: post
title: Migrate Divvy Window Manager Configuration
date: 2021-03-01 19:33:00-8000
author: me
category: dailies
tags: [osx, mac os, divvy, defaults]
keywords: [osx, mac os, divvy, defaults]
---

I've been working to migrate to a new laptop and have run into a problem with configuration for [Divvy](https://mizage.com/divvy/), my window manager.

If you're also trying to figure this out, your first google search will take you to a [blog post from 2013](http://alexeymk.com/2013/06/18/migrating-divvy-configurations-between-computers.html) which just says to copy the preferences file at `~/Library/Preferences/com.mizage.direct.Divvy.plist` to your new machine.

This doesn't work. Once you copy the config and re-launch Divvy, it immediately just overwrites the file.

The blog post also links to a [native guide (2016)](http://mizage.clarify-it.com/d/nxr9qg) from Divvy but the link is dead.

Fun.

Long story short, you can do this with an `export` + `import` using OSX [defaults](https://en.wikipedia.org/wiki/Defaults_(software)).

On your old machine, export your settings into `com.mizage.direct.Divvy.plist` with:

```bash
defaults export com.mizage.direct.Divvy com.mizage.direct.Divvy.plist
```

Copy this binary plist to your new machine and import your settings with:

```bash
defaults import com.mizage.direct.Divvy com.mizage.direct.Divvy.plist
```

**Note:** These settings contain your Divvy license key so be sure to treat it as a secret.
