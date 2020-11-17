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

Read [long-form]({{ site.baseurl }}/archives/category/writings) or [short-form]({{ site.baseurl }}/archives/category/dailies), learn more [about](about) me, view my [resume](assets/resume.pdf) or connect with me on social media.

{% assign writings_prev_year = nil %}
{% assign writings_curr_year = nil %}

<span class="h2">[Writings]({{ site.baseurl }}/archives/category/writings)</span>

_These are long-form style posts that dive deeper._

{% for post in site.categories.writings %}
{% assign writings_curr_year = post.date | date: "%Y" %}
{% if writings_curr_year != writings_prev_year %}
### [{{ writings_curr_year }}]({{ site.baseurl }}/archives/year/{{ writings_curr_year }})
{% assign writings_prev_year = writings_curr_year %}{% endif %} * [{{ post.title }}]({{ post.url }}) - {{ post.date | date: '%B %-d' }}
{% endfor %}

{% capture this_year %}{{ post.date | date: "%Y" }}{% endcapture %}
{% capture this_year %}{{ post.date | date: "%Y" }}{% endcapture %}

<span class="h2">[Dailies]({{ site.baseurl }}/archives/category/dailies)</span>

_These are short-form/bite-sized/TIL style posts that are concise and to the point._

{% assign dailies_prev_year = nil %}
{% assign dailies_curr_year = nil %}

{% for post in site.categories.dailies %}
{% assign dailies_curr_year = post.date | date: "%Y" %}
{% if dailies_curr_year != dailies_prev_year %}
### [{{ dailies_curr_year }}]({{ site.baseurl }}/archives/year/{{ dailies_curr_year }})
{% assign dailies_prev_year = dailies_curr_year %}{% endif %} * [{{ post.title }}]({{ post.url }}) - {{ post.date | date: '%B %-d' }}
{% endfor %}

<span class="h2">[Morning Coffee & Code]({{ site.baseurl }}/archives/category/leetcode)</span>

_Solving simple coding exercises with my morning coffee._

{% assign leetcode_prev_year = nil %}
{% assign leetcode_curr_year = nil %}

{% for post in site.categories.leetcode %}
{% assign leetcode_curr_year = post.date | date: "%Y" %}
{% if leetcode_curr_year != leetcode_prev_year %}
### [{{ leetcode_curr_year }}]({{ site.baseurl }}/archives/year/{{ leetcode_curr_year }})
{% assign leetcode_prev_year = leetcode_curr_year %}{% endif %} * [{{ post.title }}]({{ post.url }}) - {{ post.date | date: '%B %-d' }}
{% endfor %}
