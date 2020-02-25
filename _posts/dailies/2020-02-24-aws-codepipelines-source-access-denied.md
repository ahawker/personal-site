---
layout: post
title: AWS CodePipeline DOWNLOAD_SOURCE Access Denied
date: 2020-02-24 11:12:00-8000
author: me
category: dailies
tags: [aws, codepipeline, codebuild]
keywords: [aws, codepipeline, codebuild]
---

Creating a fresh AWS CodePipeline through the wizard can result in immediate errors.

In your CodeBuild build logs, you'll see:

![](/assets/images/posts/codebuild-waiting-download-source-error.png)

In your CodeBuild phase details, you'll see:

```
CLIENT_ERROR: AccessDenied: Access Denied status code: 403,
request id: XXX, host id: XXX/XXX= for primary source and
source version arn:aws:s3:::${BUCKET}/${PREFIX}/${ARTIFACT_ID}
```

This happens when you select a non-default S3 bucket location for the Artifact store. In this case, the role/policies automatically created by AWS are not granted access to the Custom S3 bucket location.

In the UI, you'll see:

![](/assets/images/posts/codebuild-custom-location-s3.png)

To fix this, add the following permissions to the CodeBuild policy:

```
{
    "Effect": "Allow",
    "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketAcl",
        "s3:GetBucketLocation"
    ],
    "Resource": [
        "arn:aws:s3:::${BUCKET_NAME}*"
    ]
},
```