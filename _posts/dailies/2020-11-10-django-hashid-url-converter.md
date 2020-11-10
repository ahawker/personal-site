---
layout: post
title: Django HashID URL Converter
date: 2020-11-10 09:04:00-8000
author: me
category: dailies
tags: [django, django-rest-framework, hashid]
keywords: [django, django-rest-framework, hashid]
---

HashID's allow you to convert an integer into a "[unique](https://carnage.github.io/2015/08/cryptanalysis-of-hashids)" short string.

If you [Django HashID Field](https://github.com/nshafer/django-hashid-field), you'll want to create a custom path converter so you can accept them in URL's.

[^factory]

[^factory]: {-}
  You can skip the factory function and just define a normal class with your own `min_length/alphabet` values for simplicity.

```python
from hashids import Hashids

def hashid_converter_factory(min_length=0, alphabet=Hashids.ALPHABET)
    """
    Factory function to create a Django URL path converter for HashID's using a
    specific min_length and alphabet.
    """
    class HashIdConverter:
        {% raw %}regex = r'[{}]{{}}'.format(min_length, alphabet){% endraw %}

        def to_python(self, value):
            return value

        def to_url(self, value):
            return value.hashid

    return HashIdConverter
```

With that defined, you can simply register the converter and use it in your urlpatterns.

```python
from django.urls import include, path, register_converter

register_converter(hashid_converter_factory(min_length=7), 'hashid')

urlpatterns = [
    path('codes/<hashid:pk>/', ...)
]
```
