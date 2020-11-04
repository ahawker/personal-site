---
layout: post
title: Hostname versioning + ngrok in Django REST Framework
date: 2020-11-03 15:51:00-8000
author: me
category: dailies
tags: [django, django-rest-framework, ngrok]
keywords: [django, django-rest-framework, ngrok]
---

By default, [Django REST Framework](https://www.django-rest-framework.org/) contains an [implementation](https://www.django-rest-framework.org/api-guide/versioning/#hostnameversioning) for managing API versions via hostname, e.g. `v1.example.org`. The downside of this implementation is that it doesn't support `N` level nesting of subdomains to parse the version value, e.g. `v1.api.example.org` or running local instances behind proxies like [ngrok](https://ngrok.com/).

Thankfully, we can easily write a simple implementation to do so.

```python
import re

from django.conf import settings
from rest_framework import exceptions, versioning

class HostNameVersioning(versioning.HostNameVersioning):
    """
    Capture version via hostname in the request. This versioning scheme supports subdomains
    of 'N' levels deep.

    * {default_subdomain}.foobar.com -> Uses default version
    * v1.{default_subdomain}.foobar.com -> Uses v1
    * v1.{default_subdomain}.foo.bar.baz.com -> Uses v1

    If running behind a service like ngrok, calls to your public domain,
    e.g. http://7zz979551271.ngrok.io will use the default version value.
    """
    allow_ngrok = settings.DEBUG
    allowed_versions = ('v1',)
    default_subdomain = settings.VERSIONING_DEFAULT_SUBDOMAIN
    default_version = 'v1'
    version_param = 'version'

    ip_address_regex = re.compile(r'(^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.)'
                                  r'{3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$)')
    hostname_regex = re.compile(r'([a-zA-Z0-9]+)\.(?:[a-zA-Z0-9]+\.)+')
    ngrok_regex = re.compile(r'([a-zA-Z0-9]+)\.ngrok.io')

    def determine_version(self, request, *args, **kwargs):
        hostname, separator, port = request.get_host().partition(':')

        # Check ngrok requests for local environment proxy.
        if self.allow_ngrok:
            match = self.ngrok_regex.match(hostname)
            if match:
                return self.default_version

        # Check requests to IP address.
        match = self.ip_address_regex.match(hostname)
        if match:
            return self.default_version

        # Check requests to hostname.
        match = self.hostname_regex.match(hostname)
        if not match:
            return self.default_version

        # Check for version subdomain.
        version = match.group(1)
        if version == self.default_subdomain:
            return self.default_version
        if not self.is_allowed_version(version):
            raise exceptions.NotFound(self.invalid_version_message)
        return version
```

You can set this versioning strategy per view or globally in your `REST_FRAMEWORK` settings within `settings.py`.
```python
    REST_FRAMEWORK = {
        'DEFAULT_VERSIONING_CLASS': 'common.versioning.HostNameVersioning',
        ...
        ...
    }
```