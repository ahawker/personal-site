---
layout: home
title: Andrew Hawker
---

[^photo]

My small corner of the internet where I write occasionally.

Read [long-form](#writings) or [short-form](#dailies), learn more [about](about) me, or connect with me on social media.

[^photo]: {-}
  ![Me](/assets/images/pages/resume-me.jpg){ .about-img }

{% assign writings_prev_year = nil %}
{% assign writings_curr_year = nil %}

## [Writings]({{ site.baseurl }}/archives/category/writings)

_These are long-form style posts that dive deeper._

{% for post in site.categories.writings %}
{% assign writings_curr_year = post.date | date: "%Y" %}
{% if writings_curr_year != writings_prev_year %}
### [{{ writings_curr_year }}]({{ site.baseurl }}/archives/year/{{ writings_curr_year }})
{% assign writings_prev_year = writings_curr_year %}{% endif %} * [{{ post.title }}]({{ post.url }}) - {{ post.date | date: '%B %-d' }}
{% endfor %}

{% capture this_year %}{{ post.date | date: "%Y" }}{% endcapture %}
{% capture this_year %}{{ post.date | date: "%Y" }}{% endcapture %}

## [Dailies]({{ site.baseurl }}/archives/category/dailies)

_These are short-form/bite-sized/TIL style posts that are concise and to the point._

{% assign dailies_prev_year = nil %}
{% assign dailies_curr_year = nil %}

{% for post in site.categories.dailies %}
{% assign dailies_curr_year = post.date | date: "%Y" %}
{% if dailies_curr_year != dailies_prev_year %}
### [{{ dailies_curr_year }}]({{ site.baseurl }}/archives/year/{{ dailies_curr_year }})
{% assign dailies_prev_year = dailies_curr_year %}{% endif %} * [{{ post.title }}]({{ post.url }}) - {{ post.date | date: '%B %-d' }}
{% endfor %}
