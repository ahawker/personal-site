---
layout: post
title: Snowplow on AWS Fargate - Task Role
date: 2020-02-10 11:26:00-8000
author: me
category: writings
tags: [snowplow, aws, ecs, fargate, task]
keywords: [snowplow, aws, ecs, fargate, task]
---

---

This is part **two** of a blog post series about **Snowplow on AWS Fargate**.

* [Part 1: Snowplow on AWS Fargate]({% post_url /2020-02-09-snowplow-fargate %})
* [Part 3: Snowplow on AWS Fargate - Stream Enrich]({% post_url /2020-02-11-snowplow-fargate-enricher %})
* [Part 4: Snowplow on AWS Fargate - IAM Permissions]({% post_url /2020-02-12-snowplow-fargate-permissions %})

---

### Goal

This post will outline the problem of using the IAM role/policy granted to AWS Fargate tasks so Snowplow components can access AWS resources.

## Using permissions in ECS task role

The first problem you're likely to run into is permission errors related to assuming the [task role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html) in your AWS ECS task definition. Lucky for us, this is just a minor configuration tweak.

If you follow along with the documentation for [configuring the scala stream collector](https://github.com/snowplow/snowplow/wiki/Configure-the-Scala-Stream-Collector) and use start with the default [application.conf](https://raw.githubusercontent.com/snowplow/snowplow/master/2-collectors/scala-stream-collector/examples/config.hocon.sample) you'll run into this problem.

By default, the `application.conf` file uses the value **iam** for its `aws.accessKey` and `aws.secretKey` configuration values. This value works for deployment directly on EC2 instances but **does not** work when running as an ECS Fargate task. For these, you need to use the AWS default credential provider. Thankfully, Snowplow supports this, so just a simple change from **iam** to **default** will get you around this problem.

```
aws {
 -    accessKey = iam
 +    accessKey = default
     accessKey = ${?COLLECTOR_STREAMS_SINK_AWS_ACCESS_KEY}
 -    secretKey = iam
 +    secretKey = default
     secretKey = ${?COLLECTOR_STREAMS_SINK_AWS_SECRET_KEY}
}
```

If you're following along with the Snowplow Wiki setup guide, you'll first run into this with the [Scala Streaming Collector](https://github.com/snowplow/snowplow/wiki/Setting-up-a-collector). However, this change will be required for all components being run as Fargate tasks, e.g. Stream Enrich, S3 Loader, ES Loader, etc.

### Next

Check out the next post in this series, [Snowplow on AWS Fargate - Stream Enrich]({% post_url /2020-02-11-snowplow-fargate-enricher %}), which covers the Stream Enrich process on AWS Fargate.
