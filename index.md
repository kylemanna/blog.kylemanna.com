---
layout: page
title: booting system...
tagline: standby
---

## Overview

This is my simple blog. My intention is to ramble about things that amuse me. One day it might develop some structure, until then...

## Posts

<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>


{% for post in site.posts limit:1 %}
## {{ post.title }}

<span>{{ post.date | date: '%B' }} {{ post.date | date: '%e' }}, {{ post.date | date: '%Y' }}</span>
<p> {{ post.content }} </p>
{% endfor %}
