---
title: "如何使用Serverless来快速推出产品"
type: portfolio
date: 2019-08-12T16:58:55+06:00
description : "当使用AWS作为基础服务为分布式软件产品提供资源时，需要做的事情太多了。有时需要查看使用AWS服务的费用、有时需要在dev环境中测试研发的功能、有时需要在stage环境中模拟prod环境的运行情况、有时需要在prod环境中上线新功能。如果研发团队里有100人都能对AWS进行各种个样的操作，那么后果是非常混乱不堪的：比如，有些成员的操作导致prod环境奔溃了、有些成员完成测试时忘记销毁资源最终导致费用变高、甚至没有察觉外来攻击者使用了企业的AWS资源等。为了杜绝这些情况发生，企业在使用AWS服务之前，需要为研发团队构建一套有效的AWS账号体系。本文将围绕如何构建企业级AWS账号体系展开，最终提供一套可实施的方案。"
caption: Serverless
image: images/portfolio/serverlessComputingBanner.jpg
category: ["AWS","云计算","NOSQL","Serverless"]
liveLink: https://2cloudlab.com
---

## Introduction

AWS Lambda was launched at re:Invent 2014. It was the first implementation of serverless computing where users could upload their code to Lambda. It performs operational and administrative activities on their behalf, including provisioning capacity, monitoring fleet health, applying security patches, deploying their code, and publishing realtime logs and metrics to Amazon CloudWatch.Lambda follows the event-driven architecture. Your code is triggered in response to events and runs in parallel. Every trigger is processed individually. Moreover, you are charged only per execution, while with EC2 you are billed by the hour. Therefore, you benefit from autoscaling and fault-tolerance for your application with low cost and zero upfront infrastructure investment.

![](http://localhost:1313/images/blog/source-events-of-lambda.png)

## Lambda for Web application

**Web applications**: Instead of a maintaining a dedicated instance with a web server to host your static website, you can combine S3 and Lambda to benefit from scalability at a cheaper cost. An example of a serverless website is described in the following diagram:

![](http://localhost:1313/images/blog/web-application-for-lambda.png)

An alias record in Route 53 points to a CloudFront distribution. The CloudFront distribution is built on top of an S3 Bucket where a static website is hosted. CloudFront reduces the response time to static assets (JavaScripts, CSS, fonts, and images), improves webpage load times, and mitigates distributed denial of service (DDoS) attacks. HTTP requests coming from the website then go through API Gateway HTTP endpoints that trigger the right Lambda Function to handle the application logic and persist data to a fully managed database service, such as DynamoDB. 

## Developing a Serverless Function with Lambda

In this chapter, we will finally learn how to write our very first Python-based Lambda function from scratch, followed by how to configure, deploy, and test a Lambda function manually from the AWS Lambda Console. Along the way, you will be given a set of tips on how to grant access to your function so that it can interact with other AWS services in a secure way.

You can run Python code in AWS Lambda. Lambda provides runtimes for Python that execute your code to process events. Your code runs in an environment that includes the SDK for Python (Boto 3), with credentials from an AWS Identity and Access Management (IAM) role that you manage.

Lambda functions use an execution role to get permission to write logs to Amazon CloudWatch Logs, and to access other services and resources. If you don't already have an execution role for function development, create one.