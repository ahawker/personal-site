---
layout: post
title: Django Activity Stream Prefetch Generic Foreign Keys
date: 2020-11-18 9:46:00-8000
author: me
category: writings
tags: [django, django-activity-stream]
keywords: [django, django-activity-stream]
---

## Introduction

If you use [Django Activity Stream](https://github.com/justquick/django-activity-stream), you're likely to run into query performance problems when querying `Action` instances when implementing a "most recent activity" style stream.

The reason for this performance hit is because the `Action` model has `actor`, `action_object` and `target` generic foreign keys. For each `action` queried, you'll also end up querying the `User` table (Actor), the `ContentType` table for the GFK types (`action_object` and `target`) and then their respective tables. This isn't an `N+1` query, it's closer to an `(N + 1) * (K + 1)` query, where `N` is the number of `Action` instances and `K` is the number of distinct `ContentType` used.

With some prefetching, we should be able to get this down to `K + 1` query.

## Solution

> This is a solution derived from this old [Django snippet](https://djangosnippets.org/snippets/2492/), specifically for Django Activity Stream.

First off, let's start with an implementation to prefetch relations for all Generic Foreign Keys of a queryset. This process goes as follows:

1. Find all GFK fields on a queryset model
2. Fetch `ContentType` information for distinct types through the GFK fields
3. Recursively prefetch the related objects through the GFK (if the related model itself has)
4. Set prefetch value to the model instance after its loaded

```python
import collections

from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType

def prefetch_relations(queryset):
    """
    Prefetch content type relations for GenericForeignKeys to reduce N+1 queries.
    """
    # Get all GenericForeignKey fields on all models of the queryset.
    gfks = _queryset_generic_foreign_keys(queryset)

    # Get mapping of GFK content_type -> list of GFK object_pks for all GFK's on the queryset.
    gfks_data = _content_type_to_content_mapping_for_gfks(queryset, gfks)

    for content_type, object_pks in gfks_data.items():
        # Get all model instances referenced through a GFK.
        gfk_models = prefetch_relations(
            content_type.model_class().objects.filter(pk__in=object_pks).select_related()
        )
        for gfk_model in gfk_models:
            for gfk in _queryset_gfk_content_generator(queryset, gfks):
                qs_model, gfk_field_name, gfk_content_type, gfk_object_pk = gfk

                if gfk_content_type != content_type:
                    continue
                if gfk_object_pk != str(gfk_model.pk):  # str compare otherwise UUID PK's puke. :(
                    continue

                setattr(qs_model, gfk_field_name, gfk_model)

    return queryset

def _queryset_generic_foreign_keys(queryset):
    """
    Build mapping of name -> field for GenericForeignKey fields on the queryset.
    """
    gfks = {}
    for name, field in queryset.model.__dict__.items():
        if not isinstance(field, GenericForeignKey):
            continue
        gfks[name] = field
    return gfks


def _queryset_gfk_content_generator(queryset, gfks):
    """
    Generator function that yields information about all GenericForeignKey fields for all models of a queryset.
    """
    for model in queryset:
        for field_name, field in gfks.items():
            content_type_id = getattr(model, field.model._meta.get_field(field.ct_field).get_attname())
            if not content_type_id:
                continue

            content_type = ContentType.objects.get_for_id(content_type_id)
            object_pk = str(getattr(model, field.fk_field))

            yield (model, field_name, content_type, object_pk)


def _content_type_to_content_mapping_for_gfks(queryset, gfks):
    """
    Build mapping of content_type -> [content_pk] for the given queryset and its generic foreign keys.
    """
    data = collections.defaultdict(list)

    for model, field_name, content_type, object_pk in _queryset_gfk_content_generator(queryset, gfks):
        data[content_type].append(object_pk)

    return data
```

Now that we can functionality for prefetching generic relation values, we need to modify the `QuerySet` and `Manager`
implementations we use for the Django Activity Stream models.

```python
from actstream import gfk, managers

from .prefetch import prefetch_relations

class PrefetchGFKQuerySet(gfk.GFKQuerySet):
    """
    QuerySet that extends :class:`~actstream.gfk.GFKQuerySet` to use
    :func:`~activity.prefetch.prefetch_relations` instead of the default implementation.
    """
    def fetch_generic_relations(self, *args):
        return prefetch_relations(self)


class ActionManager(managers.ActionManager):
    """
    Manager for :class:`~activity.models.Action`.
    """
    def get_queryset(self):
        return PrefetchGFKQuerySet(self.model)


class FollowManager(managers.FollowManager):
    """
    Manager for :class:`~activity.models.Follow`.
    """
    def get_queryset(self):
        return PrefetchGFKQuerySet(self.model)
```

Now we'll just setup some proxy models for the activity stream base models so we can override the default manager.

```python
from actstream import models

class Action(models.Action):
    """
    Proxy object to activity stream action model.
    """
    objects = managers.ActionManager()

    class Meta:
        proxy = True


class Follow(models.Follow):
    """
    Proxy object to activity stream action model.
    """
    objects = managers.FollowManager()

    class Meta:
        proxy = True
```

Now queries like `Action.objects.any`, `Action.objects.user`, and `Follow.objects.followers_qs` will all prefetch objects through their generic foreign keys.