---
layout: post
title: Snowplow on AWS Fargate
date: 2020-02-09 18:33:00-8000
author: me
category: writings
tags: [snowplow, aws, ecs, fargate]
keywords: [snowplow, aws, ecs, fargate]
---

Over the past few days, I've been working on deploying [Snowplow](https://github.com/snowplow/snowplow) on [AWS Fargate](https://aws.amazon.com/fargate/) for my company [Routegy](https://routegy.com).

I'm deploying the _streaming_ version of Snowplow, using the [Scala Stream Collector](https://github.com/ snowplow/snowplow/wiki/Setting-up-the-Scala-Stream-Collector) and [Stream Enricher](https://github.com/ snowplow/snowplow/wiki/setting-up-stream-enrich) using slightly modified versions of the official [dockerfiles](https://github.com/snowplow/snowplow-docker).

However, AWS ECS/Fargate is an undocumented platform on the [Snowplow Wiki](https://github.com/snowplow/snowplow) so there have been some growing pains. This blog series will cover some of the gotchas, problems, and solutions I found along the way.

## Part 1: Using ECS Task Role Permissions

**[Snowplow on AWS Fargate - Task Role]({% post_url /2020-02-10-snowplow-fargate-task-role %})** outlines how to configure your Snowplow components properly to give them access to the ECS task role.

## Part 2: Stream Enricher Gotchas

**[Snowplow on AWS Fargate - Stream Enricher]({% post_url /2020-02-11-snowplow-fargate-enricher %})** contains more information for running the [Snowplow Stream Enrich](https://github.com/snowplow/snowplow/wiki/setting-up-stream-enrich) component.

## Part 3: IAM Permissions

**[Snowplow on AWS Fargate - IAM Permissions]({% post_url /2020-02-12-snowplow-fargate-permissions %})** contains IAM policy document examples for each Snowplow component to give it the minimum required security access.
