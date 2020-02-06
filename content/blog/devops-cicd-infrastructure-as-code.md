---
title: "企业为何需要在内部推广Devops"
date: 2019-02-21T12:27:38+06:00
description: "企业对外发布产品之前其在内部需要做好各种准备：研发工程师完成产品研发，测试工程师完成产品测试，DevOps工程师部署产品。在这个过程中遇到任何问题，都会影响产品的发布，因此企业在数字化转型的过程中都需要优化这一流程。在软件行业中，优化这个流程的方法论是：DevOps。"
type: post
image: images/blog/digital-transform.jpg
author: 郑思龙
tags: ["DevOps", "CICD", "InfrastructureAsCode"]
---

企业对外发布产品之前其在内部需要做好各种准备：研发工程师完成产品研发，测试工程师完成产品测试，DevOps工程师部署产品。在这个过程中遇到任何问题，都会影响产品的发布，因此企业在数字化转型的过程中都需要优化这一流程。在软件行业中，优化这个流程的方法论是：DevOps。

这篇文章接下来将围绕以下内容来介绍DevOps：

1. DevOps在企业内部推广的现实状况
2. 对企业有价值的DevOps是什么样的？
3. 如何理解：Devops、CICD、Infrastructure as code

## DevOps在企业内部推广的现实状况

DevOps在中国区企业的推广令人堪忧。大多数企业只实现了DevOps的持续集成部分，比如研发人员提交代码会触发服务器自动编译生成软件产品、测试人员的测试脚本会自动执行并验证软件产品的缺陷。很少有企业能够把发布产品这一部分做好，比如DevOps人员运行基础资源脚本来准备环境、部署产品、监控产品、植入安全机制、优化基础资源等。有部分企业甚至都没有这个概念。下面列举了我经历的一些企业遇到的关于DevOps的问题。

1. 大多数企业都没有一个完整DevOps团队
2. 企业对DevOps的理解是不一样的，最终导致没有统一的DevOps方案
3. 企业对产品发布的认知只是停留在“能用就行”的程度，如何优化、监控、保护基础环境并不重视
4. 云计算的使用经验匮乏
5. 缺乏DevOps的实施经验

没有实施DevOps的企业将面临一个问题：产品无法及时推向市场。

## 对企业有价值的DevOps是什么样的？

在企业内部，研发工程师根据产品经理的需求，在自己的电脑上完成编码、测试、Code Review并最终提交代码并完成产品功能的研发。理想情况下，这些功能会第一时间交付到客户，并为其带来价值。DevOps就是为实现这个流程而提出来的。对企业而言，DevOps的价值在于及时为客户输出高质量的产品，最终为客户创造价值。这一简单的目标背后实际上是由一系列相关的活动所支撑的。让我们看看现实世界中，软件从研发到发布所涉及的工作事项。

阶段一：研发团队根据需求研发产品功能，这个过程涉及编码、测试、提交源码；阶段二：测试团队获取研发团队的成果并进行测试，这个过程涉及到准备测试环境、执行各种测试、生成测试报告；阶段三：DevOps团队获取测试团队验证过的产品并发布产品，这个过程涉及到准备运行环境、监测产品运行状态、实施安全机制、优化资源使用情况。

这些工作事项好似被串联到一条流水线上，由不同角色共同在这条流水线上完成产品的研发、测试和交付，最终把产品及时发布到线上，以供客户使用。**因此流水线的流畅性决定了企业响应市场的能力**，在软件行业中，这条流水线就是业内常说的**CICD**。企业开始数字化转型时就应该考虑搭建**CICD**的策略，因为搭建**CICD**是一个漫长的过程，期间需要不断地迭代，同时也会涉及到多个团队。试想想，如果**福特没有汽车生产流水线，那么福特公司也就无法生产大量的汽车了**，同样，在软件行业中，**CICD**也起到了类似的作用，只不过这条虚拟的流水线生成的是高质量的软件产品。

实施**CICD**的基础是自动化。也就是说企业需要为研发和发布产品引入自动化机制，而**Infrastructure as code**是实现自动化的一种方式。它要求研发和发布产品过程中所涉及的工作事项要通过代码的方式驱动。计算机只需要执行这些代码就能完成产品的测试和发布，从而实现自动化。

## 如何理解：Devops、CICD、Infrastructure as code

在软件行业中，Devops, CICD, Infrastructure as code几个词汇经常出现，它们的最终目标是帮助企业提高软件质量同时向市场推出杀手锏产品。以下是来自wiki的定义：

[Devops](https://en.wikipedia.org/wiki/DevOps)的定义

> DevOps is a set of practices that combines software development (Dev) and information-technology operations (Ops) which aims to shorten the systems development life cycle and provide continuous delivery with high software quality.

[CICD](https://en.wikipedia.org/wiki/CI/CD)的定义

> In software engineering, CI/CD or CICD generally refers to the combined practices of continuous integration and either continuous delivery or continuous deployment.

[Infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_code)的定义

> Infrastructure as code (IaC) is the process of managing and provisioning computer data centers through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools.

通过以上定义，**读者可以这么理解它们之间的关系**：企业在内部推广一场持久的devops运动，找出参与devops运动的各个团队。成立devops团队，使用各种工具（比如Terraform），结合各个团队的需求，以Infrastructure as code方式在全公司建立CI/CD流程。重复以上过程以便持续改进devops、CI/CD、Infrastructure as code实践经验。

实现高效CI/CD的一种方式是Infrastructure as code，它的核心思想是以**自动化方式**解析和执行脚本文件，最终驱动基础资源。terraform恰好是一种使用Infrastructure as code方式来运行的工具，其它工具（比如Packer，Go，Python，Docker等等）也是基于Infrastructure as code方式来运行的。这篇文章的重点是**如何在企业中高效使用terraform**，因此接下来的内容将围绕terraform展开。