---
layout: post
title: Snowplow on AWS Fargate - IAM Permissions
date: 2020-02-12 08:50:00-8000
author: me
category: writings
tags: [snowplow, aws, ecs, fargate, kinesis, iam, kcl]
keywords: [snowplow, aws, ecs, fargate, kinesis, iam, kcl]
---

---

This is part **four** of a blog post series about **Snowplow on AWS Fargate**.

* [Part 1: Snowplow on AWS Fargate]({% post_url /2020-02-09-snowplow-fargate %})
* [Part 2: Snowplow on AWS Fargate - Task Role]({% post_url /2020-02-10-snowplow-fargate-task-role %})
* [Part 3: Snowplow on AWS Fargate - Stream Enrich]({% post_url /2020-02-11-snowplow-fargate-enricher %})

---

### Goal

This post will outline the minimum necessary IAM permissions required to run each Snowplow component in AWS Fargate.

### Investigation

I spent quite some time investigating this issue before writing this post myself. Questions related to this have been asked a number of times but I was unable to find a **definitive** answer.

The following are related topics/questions I found along the way:

* **[[scala] [enrich] exception while sync’ing Kinesis shards and leases](https://discourse.snowplowanalytics.com/t/scala-enrich-exception-while-syncing-kinesis-shards-and-leases/2082)**
* **[Trying to set Stream Enrich with docker image - Caught exception when initializing LeaseCoordinator](https://discourse.snowplowanalytics.com/t/trying-to-set-stream-enrich-with-docker-image-caught-exception-when-initializing-leasecoordinator/2338)**
* **[In Snowplow, is it a compulsory to use DynamoDB in stream enrich process?](https://stackoverflow.com/questions/48302878/in-snowplow-is-it-a-compulsory-to-use-dynamodb-in-stream-enrich-process)**
* **[What IAM permissions does a Kinesis Consumer need when using KCL?](https://stackoverflow.com/questions/58768658/what-iam-permissions-does-a-kinesis-consumer-need-when-using-kcl)**
* **[Amazon Kinesis: Caught exception while sync'ing Kinesis shards and leases](https://stackoverflow.com/questions/48322207/amazon-kinesis-caught-exception-while-syncing-kinesis-shards-and-leases)**

The following are error messages you are likely to see when encountering permission issues:

* `Caught exception while sync'ing Kinesis shards and leases`
* `Could not publish X datums to CloudWatch`

The best information I could find previous was "You need to give it create, read write permissions to Dynamo" and "I just gave it full access". Hopefully this post can do a more thorough job!

### Scala Stream Collector

Collectors in Snowplow are the top of the data funnel. Raw data from the trackers is received over HTTPS and, in the case of streaming deployments, is then written in Thrift to AWS Kinesis data streams. Valid data is written to a "good" stream and invalid data is written to a "bad" stream. I highly recommend checking out the official [technical docs](https://github.com/snowplow/snowplow/wiki/Scala-stream-collector) for more details.

In terms of AWS IAM permissions, this one is relatively straight forward.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:PutRecord"
      ],
      "Resource": [
        "${collector_stream_out_good}",
        "${collector_stream_out_bad}"
      ]
    }
  ]
}
```

### Scala Stream Enricher

Enrichers in Snowplow are second in the data funnel and similar to collectors. Raw data is consumed from AWS Kinesis data streams, modified by all configured "enrichers" and then written back out to a AWS Kinesis data stream.  Valid data is written to a "good" stream and invalid data is written to a "bad" stream. I highly recommend checking out the official [technical docs](https://github.com/snowplow/snowplow/wiki/stream-enrich) for more details about the scala stream enricher.

However, since it uses the AWS Kinesis Client library (KCL), there is more nuance to the IAM permissions required.

Per the AWS [docs](https://docs.aws.amazon.com/streams/latest/dev/kinesis-record-processor-ddb.html), KCL uses an AWS DynamoDB table to manage state of the consumer (leases, checkpoints, etc). This means that our Snowplow enricher also requires all permissions necessary to manage this state table.

KCL also emits metrics to Cloudwatch, so we'll need permissions for that as well.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:GetShardIterator",
        "kinesis:GetRecords",
        "kinesis:ListShards"
      ],
      "Resource": [
        "${collector_stream_out_good}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "kinesis:ListStreams"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:PutRecord",
        "kinesis:PutRecords"
      ],
      "Resource": [
        "${enricher_stream_out_good}",
        "${enricher_stream_out_bad}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:CreateTable",
        "dynamodb:DescribeTable",
        "dynamodb:Scan",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": [
        "${enricher_state_table}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData"
      ],
      "Resource": "*"
    }
  ]
}
```

**Note:**  This example does **not** include a stream for PII data. If you want that, you'll need to include it in the 3rd statement where write permissions to Kinesis data streams are defined.

### S3 Loader

Loaders in Snowplow are third in the data funnel and similar to enrichers. Raw data is consumed from AWS Kinesis data streams and written to a valid data sink, in this case, S3. If records can not be written to the sink, they're written to a "bad" stream. I highly recommend checking out the official [technical docs](https://github.com/snowplow/snowplow/wiki/snowplow-s3-loader-setup) for more details.

Similar to the enricher, the AWS Kinesis Client library (KCL) is also used, so we will need to include permissions for the DynamoDB state table and Cloudwatch permissions as well.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:GetShardIterator",
        "kinesis:GetRecords",
        "kinesis:ListShards"
      ],
      "Resource": [
        "${enricher_stream_out_good}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "kinesis:ListStreams"
      ],
      "Resource": [
          "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:PutRecord",
        "kinesis:PutRecords"
      ],
      "Resource": [
        "${loader_stream_out_bad}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:CreateTable",
        "dynamodb:DescribeTable",
        "dynamodb:Scan",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": [
        "${s3_loader_state_table}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${bucket_id}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${bucket_id}/*"
      ]
    }
  ]
}

```

### Elasticsearch Loader

The ES loader and S3 loaders are nearly identical, expect we trade an S3 bucket sink for an Elasticsearch cluster. I highly recommend checking out the official [technical docs](https://github.com/snowplow/snowplow/wiki/elasticsearch-loader-setup) for more details about the es loader.

Similar to the enricher and S3 loader, the AWS Kinesis Client library (KCL) is also used, so we will need to include permissions for the DynamoDB state table and Cloudwatch permissions as well.


```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:GetShardIterator",
        "kinesis:GetRecords",
        "kinesis:ListShards"
      ],
      "Resource": [
        "${enricher_stream_out_good}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "kinesis:ListStreams"
      ],
      "Resource": [
          "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:PutRecord",
        "kinesis:PutRecords"
      ],
      "Resource": [
        "${loader_stream_out_bad}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:CreateTable",
        "dynamodb:DescribeTable",
        "dynamodb:Scan",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": [
        "${es_loader_state_table}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData"
      ],
      "Resource": "*"
    }
  ]
}
```

If [Amazon Elasticsearch Service (AES)](https://aws.amazon.com/elasticsearch-service/) is being used and you're running it inside a VPC, you'll need to make sure the access policies on the domain are also configured. The **`role`** here should have a policy attached that grants it all of the permissions that are defined above. Check out the official [technical docs](https://aws.amazon.com/blogs/security/how-to-control-access-to-your-amazon-elasticsearch-service-domain/) for more details about AES access policies.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${role}"
        ]
      },
      "Action": [
        "es:ES*"
      ],
      "Resource": [
        "${domain}",
        "${domain}/*"
      ]
    }
  ]
}

```

### To be continued...

The next blog post in this series will discuss the [EmrEtlRunner](https://github.com/snowplow/snowplow/wiki/setting-up-EmrEtlRunner) handling streaming data. Stay tuned!
