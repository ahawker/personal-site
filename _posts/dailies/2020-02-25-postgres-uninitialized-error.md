---
layout: post
title: Database is uninitialized and superuser password is not specified
date: 2020-02-25 08:55:00-8000
author: me
category: dailies
tags: [postgres, docker]
keywords: [postgres, docker]
---

Pulling down and running the latest Postgres images from Docker Hub now results in errors.

<figure class="fullwidth">
```bash
postgres_1_33777e03d7d8 | Error: Database is uninitialized and superuser password is not specified.
postgres_1_33777e03d7d8 |        You must specify POSTGRES_PASSWORD for the superuser. Use
postgres_1_33777e03d7d8 |        "-e POSTGRES_PASSWORD=password" to set it in "docker run".
postgres_1_33777e03d7d8 | 
postgres_1_33777e03d7d8 |        You may also use POSTGRES_HOST_AUTH_METHOD=trust to allow all connections
postgres_1_33777e03d7d8 |        without a password. This is *not* recommended. See PostgreSQL
postgres_1_33777e03d7d8 |        documentation about "trust":
postgres_1_33777e03d7d8 |        https://www.postgresql.org/docs/current/auth-trust.html
```
</figure>

Turns out there was a backwards compatibility breaking change added [here](https://github.com/docker-library/postgres/pull/658).

Update your `docker-compose.yml` or corresponding configuration with the **`POSTGRES_HOST_AUTH_METHOD`** environment variable to revert back to previous behavior or implement a proper password.

```yaml
    image: library/postgres:11-alpine
    environment:
      POSTGRES_HOST_AUTH_METHOD: trust
```
