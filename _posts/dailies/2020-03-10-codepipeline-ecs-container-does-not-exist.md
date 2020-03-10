---
layout: post
title: The AWS ECS container does not exist
date: 2020-03-10 12:17:00-8000
author: me
category: dailies
tags: [aws, codepipeline, ecs, fargate]
keywords: [aws, codepipeline, ecs, fargate]
---

## Problem

Your CodePipeline ECS deployment is failing with a **`The AWS ECS container ${container} does not exist`** message.

## Scenario

[^container-definitions]

This problem can occur in a number of situations but let's just imagine we have a task definition contains a single entry in its `container definitions`. Now we want to add another container to the task, say a sidecar container like the [datadog agent](https://docs.datadoghq.com/integrations/ecs_fargate/).

[^container-definitions]: {-}
  Check out the official AWS documentation for the [container definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definitions) for more details

First, you add it to your ECS task definition and push a new revision.

```json
[
  ...
  ...
  {
    "name": "${datadog_name}",
    "image": "${datadog_image}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/aws/ecs/${cluster_name}/${datadog_name}",
        "awslogs-region": "us-west-2",
        "awslogs-stream-prefix": "${datadog_name}"
      }
    },
    "secrets": [
      { "name": "DD_API_KEY",  "valueFrom": "${DD_API_KEY}" }
    ],
    "environment": [
      { "name": "ECS_FARGATE", "value": "true" }
    ]
  }
]
```

Second, you add it to your `imagedefinitions.json` generated in your CodePipeline build stage.

```json 
[
	{
		"name": "${your_container_name}",
		"imageUri":"${your_container_image}"
	}
	{
		"name": "${datadog_agent_name}",
		"imageUri":"${datadog_agent_image}"
	}
]
```

After that, you run a new CodePipeline and run into the following error: **`The AWS ECS container datadog-agent does not exist`**.

![](/assets/images/posts/container-does-not-exist.png)

What the heck?

The ECS service being updated with a new task definition from CodePipeline **MUST** have the container defined in it. This means that you must add the container definition, create a new task revision, **AND** force a new service deployment _prior_ to doing an ECS deployment via CodePipeline.
