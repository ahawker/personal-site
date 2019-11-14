---
layout: home
title: Andrew Hawker
---

I write here occasionally.

Check out my [résumé](resume) or connect with me on social media.

{% for post in site.posts %}
{% assign currentyear = post.date | date: "%Y" %}
{% if currentyear != prevyear %}
### {{ currentyear }}
{% assign prevyear = currentyear %}{% endif %} * [{{ post.title }}]({{ post.url }}) - {{ post.date | date: '%B %-d' }}
{% endfor %}