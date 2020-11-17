---
layout: post
title: Django Activity Stream with Django REST Framework
date: 2020-11-16 14:46:00-8000
author: me
category: writings
tags: [django, django-rest-framework, django-activity-stream]
keywords: [django, django-rest-framework, django-activity-stream]
---

## Introduction

This post is a quick walkthrough of [Django Activity Stream](https://github.com/justquick/django-activity-stream), [Django REST Framework](https://www.django-rest-framework.org/), and some code snippets for getting them to work together.

Django Activity Stream allows you to add "social network" style activity streams to your Django application. Individual events of a stream (actions) are categorized by four main components:

* **Actor**. The object that performed the activity.
* **Verb**. The verb phrase that identifies the action of the activity.
* **Action Object**. (Optional) The object linked to the action itself.
* **Target**. (Optional) The object to which the activity was performed.

GitHub is a great example of this.

![Screenshot of GitHub activity stream](/assets/images/posts/github-activity-stream.jpg)

Let's break this screenshot down into the components outlined above.

* **Actor**: Users or bots
* **Verb**: Pushed or starred
* **Action Object**: Commits, pull requests, or nothing
* **Target:** Repository or organization

As we can see, the activity stream is a heterogeneous collection of actions, where the components can be different types.

How does Django Activity Stream model this? The `Actor`, `Action Object` and `Target` are generic foreign keys to any arbitrary Django model using the Django content framework. There's a bit of a performance hit for this (additional queries) but is extremely flexible and can be extended to any time of new Django models you define.

Since these actions make the activity stream heterogeneous, we need to be able to have serializers for any/all types used, depending on the type of model linked through the generic foreign keys. How do we handle this with Django REST Framework?

## Solution

First, we define a generic serializer for the `Action` models that uses a custom field serializer for the `actor`, `action_object` and `target` fields.

```python
class ActionSerializer(Serializer):
    """
    DRF serializer for :class:`~activity.models.Action`.
    """
    actor = fields.ActivityGenericRelatedField(read_only=True)
    action_object = fields.ActivityGenericRelatedField(read_only=True)
    target = fields.ActivityGenericRelatedField(read_only=True)

    class Meta(Serializer.Meta):
        model = Action
        fields = ('id', 'actor', 'verb', 'action_object', 'target', 'public', 'description', 'timestamp')
```

This custom field serializer chooses the appropriate registered serializer based on the type of model it's attempting to serialize through the generic foreign key. Let's take a look at an example that uses some serializers that map to GitHub types.

```python
# Registry of GFK serializers used in activity stream.
GFK_MODEL_SERIALIZER_MAPPING = {
    User: UserActionSerializer,
    Bot: BotActionSerializer,
    Team: TeamActionSerializer,
    Commit: CommitActionSerializer,
    Star: FunctionActionSerializer,
    Push: PushActionSerializer,
    PullRequest: PullRequestActionSerializer,
    Organization: OrganizationActionSerializer,
    Repository: RepositoryActionSerializer
}

class ActivityGenericRelatedField(serializers.Field):
    """
    DRF Serializer field that serializers GenericForeignKey fields on the :class:`~activity.models.Action`
    of known model types to their respective ActionSerializer implementation.
    """

    def to_representation(self, value):
        serializer_cls = GFK_MODEL_SERIALIZER_MAPPING.get(type(value), None)
        return serializer_cls(value, context=self.context).data if serializer_cls else str(value)
```

An example of a simple action serializer could be imagined as:

```python
class OrganizationActionSerializer(ModelSerializer):
    """
    DRF model serializer for :class:`~organizations.models.Organization` when referenced
    from an action.
    """

    class Meta:
        fields = ('id', 'url', 'model_type', 'name', 'slug')
        read_only_fields = ('id', 'url', 'model_type', 'name', 'slug')
```

With serializers like that, we can add a simple model mixin that allows us to query the activity stream items for a specific model instance.

```python
class ActorModel(Model):
    """
    Mixin to add activity related functionality to activity 'actor' model types.
    """

    def activity_stream(self, limit=25):
        """
        Returns queryset that yields back :class:`~activity.models.Action` instances
        where the current model instance was any part (actor, target, or action_object) of the action.
        """
        return Action.objects.any(self, _limit=limit)

    class Meta:
        abstract = True
```

If our models use a mixin like that, we can make a simple call in our viewset:

```python
class ActivityViewSetMixin:
    def activity(self, request, *args, **kwargs):
        """
        Get activity stream for the current object.
        """
        obj = self.get_object()
        queryset = obj.activity_stream()
        return responses.serialized_list_response(self, queryset)
```

With all of that hooked up and a URL route defined, we can easily query the activity stream for any object. For example, the above GitHub activities queried from a theoretical endpoint.

```python
user_activity = viewsets.UserView.as_view({'get': 'activity'})

urlpatterns = [
    path('users/<uuid:user_pk>/', include([
        path('activity', user_activity, name='user-activity')
    ]))
]
```

```bash
⇒  curl -X GET \
        -H 'Content-type: application/json' \
        -H "Authorization: Bearer ${API_KEY}" \
        https://api.example.org/users/8E4F9AF6-BCF7-44DC-B071-A68FC9A7E39F/activity | python -m json.tool
{
    "next": null,
    "prev": null,
    "results": [
        {
            "actor": {
                "id": "5D006EEC-86D1-42DC-A963-BC8708A7F6D0",
                "model_type": "bot",
                "name": "dependabot-preview",
                "email": "dependabot-preview@github.no-reply.com"
            },
            "action_object": {
                "id": "385ACEA5-DE9E-4EE8-813B-A5ACC47A9716",
                "url": "https://api.example.org/repositories/8E4F9AF6-BCF7-44DC-B071-A68FC9A7E39F/tree/385ACEA5-DE9E-4EE8-813B-A5ACC47A9716",
                "model_type": "branch",
                "name": "dependabot/pip/sphinx-rtd-theme-0.5.0",
                "slug": "dependabot/pip/sphinx-rtd-theme-0.5.0"
            },
            "target": {
                "id": "0aeedbdd-dc07-4218-9c1f-ccbf782925c4",
                "url": "https://api.example.org/repositories/8E4F9AF6-BCF7-44DC-B071-A68FC9A7E39F",
                "model_type": "repository",
                "name": "transport-protocol",
                "slug": "adbpy/transport-protocol"
            },
            "verb": "pushed",
            "timestamp": "2020-06-12T15:01:41+0000"
        },
        {
            "actor": {
                "id": "383D4A7C-CF39-45C6-B024-EC7F524DA42C",
                "model_type": "user",
                "name": "Pawel Wojnarowicz",
                "email": "pawel@example.org"
            },
            "action_object": {
                "id": "15BEBE88-CA5A-47D5-A413-DA7B67154667",
                "url": "https://api.example.org/repositories/8E4F9AF6-BCF7-44DC-B071-A68FC9A7E39F/tree/385ACEA5-DE9E-4EE8-813B-A5ACC47A9716",
                "model_type": "commit",
                "name": "master",
                "slug": "master"
            },
            "target": {
                "id": "16561C6E-7EC8-41FA-AD9F-261484FE58F4",
                "url": "https://api.example.org/repositories/8E4F9AF6-BCF7-44DC-B071-A68FC9A7E39F/tree/385ACEA5-DE9E-4EE8-813B-A5ACC47A9716",
                "model_type": "repository",
                "name": "routegy-touch-web-app",
                "slug": "routegy/routegy-touch-web-app"
            },
            "verb": "pushed",
            "timestamp": "2020-06-11T16:50:23+0000"
        },
        {
            "actor": {
                "id": "B5371262-CEF7-4E24-B2DF-792E71666B7C",
                "model_type": "user",
                "name": "wywly",
                "email": "wywly@example.org"
            },
            "action_object": null,
            "target": {
                "id": "16561C6E-7EC8-41FA-AD9F-261484FE58F4",
                "url": "https://api.example.org/repositories/8E4F9AF6-BCF7-44DC-B071-A68FC9A7E39F/tree/385ACEA5-DE9E-4EE8-813B-A5ACC47A9716",
                "model_type": "repository",
                "name": "crython",
                "slug": "ahawker/crython"
            },
            "verb": "starred",
            "timestamp": "2020-05-31T16:26:48+0000"
        }
    ]
}
```

## Following/Followers

Django Activity Streams also has support for following and followers. This flag can also be customized so we could implement following and a "stars/stargazers" mechanism like GitHub.

We can extend our previous model/viewset mixins to support these as well.

```python
class Flags:
    """
    Contains common used follow flags.
    """
    Following = 'following'



class ActorModel(Model):
    """
    Mixin to add activity related functionality to activity 'actor' model types.
    """

    def activity_stream(self, limit=25):
        """
        Returns queryset that yields back :class:`~activity.models.Action` instances
        where the current model instance was any part (actor, target, or action_object) of the action.
        """
        return Action.objects.any(self, _limit=limit)

    def followers(self, limit=25):
        """
        Returns queryset that yields back :class:`~activity.models.Follow` instances
        that contain references to users following this instance.
        """
        return Follow.objects.followers_qs(self, flag=actions.Flags.Following)[:limit]

    class Meta:
        abstract = True


class UserModel(ActorModel):
    """
    Mixin to add activity related functionality to activity user model types.
    """

    def user_stream(self, limit=25):
        """
        Returns queryset that yields back :class:`~activity.models.Action` instances
        related to actors this user is following.
        """
        return Action.objects.user(self, follow_flag=actions.Flags.Following, _limit=limit)

    def following(self, limit=25):
        """
        Returns queryset that yields back :class:`~activity.models.Follow` instances
        that contain references to users the current user is following.
        """
        return Follow.objects.following_qs(self, flag=actions.Flags.Following)[:limit]

    class Meta:
        abstract = True
```

```python
class FeedViewSetMixin:
    """
    Mixin that adds a 'feed' action to the viewset.

    This requires that the model being served by the viewset has the
    :class:`~activity.models.UserMixin`.
    """
    feed_serializer_class = serializers.ActionListSerializer

    def feed(self, request, *args, **kwargs):
        """
        Get user stream for the current object.
        """
        obj = request.user
        queryset = obj.user_stream()
        return responses.serialized_list_response(self, queryset)


class FollowViewSetMixin:
    """
    Mixin that adds 'follow' action to ViewSet.
    """

    def follow(self, request, *args, **kwargs):
        """
        Configure authenticated user to follow object stream.
        """
        user, obj = request.user, self.get_object()

        with transaction.atomic():
            signals.pre_follow.send(sender=obj.__class__, instance=obj, user=user)
            actions.follow(user, obj)
            signals.post_follow.send(sender=obj.__class__, instance=obj, user=user)

        return responses.NoContent()


class UnfollowViewSetMixin:
    """
    Mixin that adds 'unfollow' action to the ViewSet.
    """

    def unfollow(self, request, *args, **kwargs):
        """
        Configure authenticated user to unfollow object stream.
        """
        user, obj = request.user, self.get_object()

        with transaction.atomic():
            signals.pre_unfollow.send(sender=obj.__class__, instance=obj, user=user)
            actions.unfollow(user, obj)
            signals.post_unfollow.send(sender=obj.__class__, instance=obj, user=user)

        return responses.NoContent()


class FollowersViewSetMixin:
    """
    Mixin that adds 'followers' action to the ViewSet.
    """
    followers_serializer_class = serializers.FollowersSerializer

    def followers(self, request, *args, **kwargs):
        """
        Get list of users that are following the current actor.
        """
        obj = self.get_object()
        queryset = obj.followers()
        return responses.serialized_list_response(self, queryset)


class FollowingViewSetMixin:
    """
    Mixin that adds 'following' action to the ViewSet.
    """
    following_serializer_class = serializers.FollowingSerializer

    def following(self, request, *args, **kwargs):
        """
        Get list of actors the current user is following.
        """
        obj = request.user
        queryset = obj.following()
        return responses.serialized_list_response(self, queryset)
```

Update your urlpatterns to include the new routes.

```python
user_activity = viewsets.UserViewSet.as_view({'get': 'activity'})
user_followers = viewsets.UserViewSet.as_view({'get': 'followers'})
user_follow = viewsets.UserViewSet.as_view({'post': 'follow'})
user_unfollow = viewsets.UserViewSet.as_view({'delete': 'unfollow'})

urlpatterns = [
    path('users/<uuid:user_pk>/', include([
        path('activity', user_activity, name='user-activity'),
        path('followers', user_followers, name='user-followers'),
        path('follow', user_follow, name='user-follow'),
        path('unfollow', user_unfollow, name='user-unfollow')
    ]))
]
```

We can make POST requests to `follow`, `unfollow`, and simple GET requests to see what users are following an individual repository, another user, or any specific Django model instance you want.

```bash
⇒  curl -X GET \
        -H 'Content-type: application/json' \
        -H "Authorization: Bearer ${AUTH0_TOKEN}" \
        https://api.example.org/users/B8810FEF-1CC6-4647-ABFD-A8E9211F4918/followers | python -m json.tool
{
    "next": null,
    "prev": null,
    "results": [
        {
            "started": "2020-02-02T23:29:44+0000",
            "user": {
                "id": "A96A8499-9D39-4F75-99E7-33A876981CD1",
                "model_type": "user",
                "name": "Andrew Hawker",
                "email": "hawker@example.org"
            }
        }
    ]
}
```