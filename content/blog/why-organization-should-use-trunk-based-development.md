---
title: "如何提高企业的研发效率--trunk-based development"
date: 2020-03-16T12:21:58+06:00
description : "trunk-based development是指：所有研发人员围绕主分支(也就是我们常常见到的master分支)来共同研发，在研发过程中拒绝创建存活时间较长的分支，并使用Feature Toggles和Branch by Abstraction等技术在主分支上逐步发布耗时的功能。"
type: post
image: images/blog/trunk-based-development-6995662e.png
author: 郑思龙
tags: ["软件研发流程", "trunk-based development", "CI/CD", "云计算", "分支管理"]
---

trunk-based development是指：所有研发人员围绕主分支(也就是我们常常见到的`master`分支)来共同研发，在研发过程中拒绝创建存活时间较长的分支，并使用Feature Toggles和Branch by Abstraction等技术在主分支上逐步发布耗时的功能。

以下概括来自[官方](https://trunkbaseddevelopment.com/#one-line-summary)：

> A source-control branching model, where developers collaborate on code in a single branch called ‘trunk’ *, resist any pressure to create other long-lived development branches by employing documented techniques. They therefore avoid merge hell, do not break the build, and live happily ever after.

以下是采用trunk-based development来进行软件研发时所涉及的一系列活动：

![](https://2cloudlab.com/images/blog/what_is_trunk.jpg)