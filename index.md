---
layout: home
title: Home
---

I write here occasionally.

Check out my [résumé](resume) or find me on social media (links in the footer).

## Writings

{% for post in site.posts %}
{% assign currentyear = post.date | date: "%Y" %}
{% if currentyear != prevyear %}
### {{ currentyear }}
{% assign prevyear = currentyear %}{% endif %} * [{{ post.title }}]({{ post.url }}) - {{ post.date | date: '%B %-d' }}
{% endfor %}
