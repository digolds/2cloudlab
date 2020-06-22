---
title: "如何在DynamoDB中实现排名榜"
date: 2020-03-13T12:27:38+06:00
description: "在互联网的世界里，你通常会看到一些Top 10事件，比如微博里的Top 10热点事件，领英每年发布的某个行业里最具影响力的Top 20行家，一个图片网站里最受欢迎的Top 100图片等等。你不仅能看到Top 10事件，还会购买一些Top 10热销产品，比如说一些电商网站上好评前10的产品，购买量Top 10的产品等。这些事件或商品有一个特征：Top 10。那么如何利用DynamoDB为这类数据建模呢？如何在海量的事件或者商品里快速找到Top 10的事件或商品呢？这些问题的答案将在下文给出！"
type: post
image: images/blog/leaderboard-write-sharding.png
author: Alex
tags: ["NoSQL", "DynamoDB", "Data-Intensive"]
---

在互联网的世界里，你通常会看到一些Top 10事件，比如微博里的Top 10热点事件，领英每年发布的某个行业里最具影响力的Top 20行家，一个图片网站里最受欢迎的Top 100图片等等。你不仅能看到Top 10事件，还会购买一些Top 10热销产品，比如说一些电商网站上好评前10的产品，购买量Top 10的产品等。这些事件或商品有一个特征：Top 10。那么如何利用DynamoDB为这类数据建模呢？如何在海量的事件或者商品里快速找到Top 10的事件或商品呢？这些问题的答案将在下文给出！

In this example, we'll show how to maintain a global leaderboard with a dataset in DynamoDB. A leaderboard is a common need for data applications. Imagine that you're saving information on individual items that you need for individual lookups, but you also want to be able to find the Top N Items as ranked by a particular attribute.

The guiding example for this is a website that hosts a number of images -- think Unsplash. In addition to retrieving the details on any given image, we also want to find the top-viewed items to show to users.

In this walkthrough you will understand how to use write sharding combined with a scatter-gather query to satisfy the leaderboard use case.

Hat tip to Chris Shenton for initially discussing this use case with me. Also, AWS provides a leaderboard example using game scores in the DynamoDB docs. However, that example uses leaderboards within multiple different games, rather than a global leaderboard as we have here.