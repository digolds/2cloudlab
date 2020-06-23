---
title: "如何在DynamoDB中实现排名榜"
date: 2020-03-13T12:27:38+06:00
description: "在互联网的世界里，你通常会看到一些Top 10事件，比如微博里的Top 10热点事件，领英每年发布的某个行业里最具影响力的Top 20行家，一个图片网站里最受欢迎的Top 100图片等等。你不仅能看到Top 10事件，还会购买一些Top 10热销产品，比如说一些电商网站上好评前10的产品，购买量Top 10的产品等。这些事件或商品有一个特征：Top 10。那么如何利用DynamoDB为这类数据建模呢？如何在海量的事件或者商品里快速找到Top 10的事件或商品呢？这些问题的答案将在下文给出！"
type: post
image: images/blog/leaderboard-write-sharding.png
author: Alex
tags: ["NoSQL", "DynamoDB", "Data-Intensive"]
---

在互联网的世界里，你通常会看到一些Top 10事件，比如微博里的Top 10热点事件，领英每年发布的某个行业里最具影响力的Top 20行家，一个图片网站里最受欢迎的Top 100图片等等。你不仅能看到Top 10事件，还会购买一些Top 10热销产品，比如说一些电商网站上好评前10的产品，购买量Top 10的产品等。这些事件或商品有一个特征：**Top 10**。那么如何利用DynamoDB为这类数据建模呢？如何在海量的事件或者商品里快速找到Top 10的事件或商品呢？这些问题的答案将在下文给出！

本文将介绍如何为DynamoDB中的数据集建立和维护一个积分榜。正如前面所提到的，许多应用场景会使用到积分榜。假设，有一个数据集，你不仅想获取这个数据集中的某项数据，还想根据某个属性获取Top N项数据。

文中的示例是一个图片服务，存储了大量图片--类似于[Unsplash](https://unsplash.com/)服务。除了要获取单张图片的详细信息，我们还想查看点击数前几的图片。

在整个过程中，你将学到如何将**write sharding**结合**scatter-gather**在一起实现这种积分榜。

我想脱帽致敬[Chris Shenton](https://twitter.com/Shentonfreude)，起初是他和我讨论了这种实现积分榜的方法。AWS也在[其官方文档里](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GSI.html)提供了一个在游戏行业中使用积分榜的例子。然而，该例子只针对多个游戏使用了多个积分榜，而不是一个积分榜记录了多个游戏。