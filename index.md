---
layout: home
title: Andrew Hawker
---

I write here occasionally.

Read some, learn more [about me](about), or connect with me on social media.

{% assign prev_year = nil %}
{% assign curr_year = nil %}

{% for post in site.posts %}
{% assign curr_year = post.date | date: "%Y" %}
{% if curr_year != prev_year %}
### {{ curr_year }}
{% assign prev_year = curr_year %}{% endif %} * [{{ post.title }}]({{ post.url }}) - {{ post.date | date: '%B %-d' }}
{% endfor %}
