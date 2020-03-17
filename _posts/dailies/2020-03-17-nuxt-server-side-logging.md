---
layout: post
title: Server side request logging with nuxt.js
date: 2020-03-17 11:58:00-8000
author: me
category: dailies
tags: [nuxt]
keywords: [nuxt]
---

By default, [nuxt.js](https://nuxtjs.org/) does not have server-side request logging out of the box. Thankfully, we can quickly add it using the [connect-logger](https://github.com/geta6/connect-logger) with the following additions.

**Install the connect-logger package**

```sh
$ yarn add connect-logger
```

**Update 'serverMiddleware' in your nuxt.config.js**

```javascript
import logger from "connect-logger";

  serverMiddleware: [
    logger({ format: "%date %status %method %url (%time)" })
  ],
```

**View the requests in stdout**

```
app_1  | 20.03.17 18:26:56 302 GET /healthy (513ms)
app_1  | 20.03.17 18:27:04 302 GET / (114ms)
app_1  | 20.03.17 18:27:05 302 GET / (38ms)
app_1  | 20.03.17 18:27:16 302 GET /workspaces/1234 (42ms)
```