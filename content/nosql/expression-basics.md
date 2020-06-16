---
title: "DynamoDB的基础表达式"
date: 2020-02-24T12:27:38+06:00
description: "如果你在软件行业（尤其是后端服务的研发）里从业几年，你肯定会听说过与存储和处理数据相关的几个时髦的技术词：NoSQL，大数据，云计算，ServerLess，ACID，CAP，分布式等等。驱动这些技术发展的原因是多样的，主要有以下几点："
type: post
image: images/blog/expression-basics.png
author: Alex
tags: ["NoSQL", "DynamoDB", "Data-Intensive"]
---

本文是关于DynamoDB的表达式。表达式是DynamoDB的内置功能，它又细分为以下几类表达式：

* **条件表达式**用于 are used when manipulating individual items to only change an item when certain conditions are true.
* Projection expressions are used to specify a subset of attributes you want to receive when reading Items. We used these in our GetItem calls in the previous lesson.
* Update expressions are used to update a particular attribute in an existing Item.
* Key condition expressions are used when querying a table with a composite primary key to limit the items selected.
* Filter expressions allow you to filter the results of queries and scans to allow for more efficient responses.

理解这些表达式Understanding these expressions is key to getting the full value from DynamoDB. In this section, we'll look at the basics of expressions, including the use of expression attributes names and values. Then, we'll see how to use condition expressions in the context of our PutItem calls from the previous lesson.