---
layout: post
title: Druid Queries
date: 2021-01-20 9:04:00-8000
author: me
category: writings
tags: [druid, olap]
keywords: [druid, olap]
---

## Introduction

Over the past few days, I've been working on re-introducing myself to the [Druid](https://druid.apache.org/) database after a ~2 year hiatus. Back then, there weren't many real-world examples found online using the native query language, which made ramp up a bit cumbersome. The goal of these posts will attempt to address that by adding a few more examples into ether, where hopefully someone finds them useful.

While it looks like the Calcite SQL layer has moved out of beta and taken over as the official query interface (finally), I'm going to cover some more advanced queries using the [Druid Native Query Language (JSON)](https://druid.apache.org/docs/latest/querying/querying.html). I'll plan to amend these posts in the future with SQL versions of these queries (if available) so we can visualize the query translation between the two languages.

I don't plan to dive into any deep details about how Druid works, beyond schema definiton and native query language, so I would recommend checking out some of the [introduction docs](https://druid.apache.org/docs/latest/design/) to (re)-familiarize yourself.

## [Part 1: Data Schema]({% post_url /writings/2021-02-12-druid-queries-data-schema %})

This post walks us through installing Druid, loading our dataset, and examines the basics of our data schema that we will build all future queries on.

## Part 2: Active Users (Coming soon)

This future post will cover queries for counting unique active users over a period of time. These are commonly refered to as Daily Active Users (DAU), Weekly Active Users (WAU), and Monthly Active Users (MAU).

## Part 3: Retention (Coming soon)

This future post will cover queries for counting active users retained over periods of time, e.g. "how many users of my website in January returned to use it in February?"

## Part 4: Popular Times (Coming soon)

This future post will cover queries for determine usage over periods of time, e.g. Google Maps showing the popular times of day/week for a restaurant.
