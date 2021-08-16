---
layout: home
title: Andrew Hawker
author: me
---
{% assign author = site.data.authors[page.author] %}
<div class="col-6 float-right">
  <div class="p-2 mr-2">
    <img class="avatar circle" src="{{ author.picture }}">
  </div>
</div>

Welcome to my small corner of the internet where I occasionally write things.

View [long-form]({{ site.baseurl }}/archives/category/writings) writing, [short-form]({{ site.baseurl }}/archives/category/dailies) posts, [coffee + code]({{ site.baseurl }}/archives/category/leetcode) exercises, learn more [about](about) me, view my [resume](assets/resume.pdf) or connect with me on social media.

{% assign prev_year = nil %}
{% assign curr_year = nil %}

{% for post in site.posts %}
{% assign curr_year = post.date | date: "%Y" %}
{% if curr_year != prev_year %}
### [{{ curr_year }}]({{ site.baseurl }}/archives/year/{{ curr_year }})
{% assign prev_year = curr_year %}{% endif %} * [{{ post.title }}]({{ post.url }}) - {{ post.date | date: '%B %-d' }}
{% endfor %}
