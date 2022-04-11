---
layout: home
title: Andrew Hawker
author: me
---
{% assign author = site.data.authors[page.author] %}
<div class="col-6 float-right">
  <div class="p-2 mr-2">
    <a href="about" ><img class="avatar circle" src="{{ author.picture }}"></a>
  </div>
</div>

Welcome to my small corner of the internet.

{% assign prev_year = nil %}
{% assign curr_year = nil %}

{% for post in site.posts %}
{% assign curr_year = post.date | date: "%Y" %}
{% if curr_year != prev_year %}
#### [{{ curr_year }}]({{ site.baseurl }}/archives/year/{{ curr_year }})
{% assign prev_year = curr_year %}{% endif %} * _{{ post.date | date:"%b %d %Y" }}_ » [{{ post.title }}]({{ post.url }})
{% endfor %}
