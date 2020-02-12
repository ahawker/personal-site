---
layout: post
title: Snowplow Stream Enricher on AWS Fargate
date: 2020-02-11 21:32:00-8000
author: me
category: writings
tags: [snowplow, aws, ecs, fargate]
keywords: [snowplow, aws, ecs, fargate]
---

Over the past few days, I've been working on deploying [Snowplow](https://github.com/snowplow/snowplow) on [AWS Fargate](https://aws.amazon.com/fargate/) for my company [Routegy](https://routegy.com).

I'm deploying the _streaming_ version of Snowplow, using the [Scala Stream Collector](https://github.com/ snowplow/snowplow/wiki/Setting-up-the-Scala-Stream-Collector) and [Stream Enricher](https://github.com/ snowplow/snowplow/wiki/setting-up-stream-enrich) using slightly modified versions of the official [dockerfiles](https://github.com/snowplow/snowplow-docker).

However, AWS ECS/Fargate is an undocumented platform on the [Snowplow Wiki](https://github.com/snowplow/snowplow) so there have been some growing pains. This post outlines the ones encountered with the Stream Enricher.

### Name does not resolve

The is a common problem with ECS agent not properly setting up the `/etc/hosts` file and appears as well on AWS Fargate.

Example stack trace:

```java
02:58:45 Exception in thread "main" java.net.UnknownHostException: 3b76b684dc30: 3b76b684dc30: Name does not resolve
02:58:45 at java.net.InetAddress.getLocalHost(InetAddress.java:1505)
02:58:45 at com.snowplowanalytics.snowplow.enrich.stream.sources.KinesisSource.run(KinesisSource.scala:117)
02:58:45 at com.snowplowanalytics.snowplow.enrich.stream.KinesisEnrich$.main(KinesisEnrich.scala:81)
02:58:45 at com.snowplowanalytics.snowplow.enrich.stream.KinesisEnrich.main(KinesisEnrich.scala)
02:58:45 Caused by: java.net.UnknownHostException: 3b76b684dc30: Name does not resolve
02:58:45 at java.net.Inet4AddressImpl.lookupAllHostAddr(Native Method)
02:58:45 at java.net.InetAddress$2.lookupAllHostAddr(InetAddress.java:928)
02:58:45 at java.net.InetAddress.getAddressesFromNameService(InetAddress.java:1323)
02:58:45 at java.net.InetAddress.getLocalHost(InetAddress.java:1500)
```

After some investigation, [this](https://stackoverflow.com/questions/49592709/aws-fargate-hostname-not-doable) Stack Overflow post got me going in the correct direction with some slight modifications required.

First, the ethernet interface in AWS Fargate is going to be `eth0`.
Second, if you're using the official snowplow docker images, they already define an `ENTRYPOINT` instruction, so you'll need to override this. Write your own and call the original.

```bash
⇒  cat entrypoint.sh
#!/usr/bin/dumb-init /bin/sh
set -e

echo "$(ip a | grep -A2 eth0 | grep inet | awk '{print $2}' | sed 's#/.*##g' ) $(hostname)" >> /etc/hosts

exec docker-entrypoint.sh $*
```

### Bucket not found

This is a problem related to the "enrichment" configuration files and the defaults defined [here](https://github.com/snowplow/snowplow/tree/master/3-enrich/config/enrichments/).

The problem can crop up in a number of ways (based on your config) but may look something like these:

```
NonEmptyList(The bucket is in this region: eu-west-1. Please use this region to retry the request (Service: Amazon S3; Status Code: 301

NonEmptyList(Access Denied (Service: Amazon S3; Status Code: 403; Error Code: AccessDenied; Request ID: xxx; S3 Extended Request ID: sjCFZle+xxx/xxx=), Access Denied (Service: Amazon S3; Status Code: 403; Error Code: AccessDenied; Request ID: xxx; S3 Extended Request ID: xxx/xxx/xxx/xxx=))

02:18:58 Exception in thread "Thread-6" java.net.UnknownHostException: snowplow-hosted-assets-us-west-2
02:18:58 at java.net.AbstractPlainSocketImpl.connect(AbstractPlainSocketImpl.java:184)
02:18:58 at java.net.SocksSocketImpl.connect(SocksSocketImpl.java:392)
02:18:58 at java.net.Socket.connect(Socket.java:589)
02:18:58 at java.net.Socket.connect(Socket.java:538)
```

The [UA Parser](https://github.com/snowplow/snowplow/wiki/ua-parser-enrichment) and [Geolite IP Lookups](https://github.com/snowplow/snowplow/wiki/IP-lookups-enrichment) enrichments can both be configured to pull resources down from S3 buckets, however they use slightly different syntax. The [ip_lookups.json](https://github.com/snowplow/snowplow/blob/master/3-enrich/config/enrichments/ip_lookups.json) file uses a `http://` URI scheme to a file in an S3 bucket while the [us_parser_config.json](https://github.com/snowplow/snowplow/blob/master/3-enrich/config/enrichments/ua_parser_config.json) uses `s3://`.

I switched both of mine to `http://` URI schemes to work around the problem, e.g.

```
"uri": "http://snowplow-hosted-assets.s3.amazonaws.com/third-party/maxmind"

"uri": "http://snowplow-hosted-assets.s3.amazonaws.com/third-party/ua-parser"
```

## To be continued...

The next blog post in this series will discuss IAM permissions required for all of the Snowplow containers. Stay tuned!
