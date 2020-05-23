---
title: "如何0成本在github上构建CI"
date: 2020-03-17T12:21:58+06:00
description : ""
type: post
image: images/blog/github.jpg
author: 郑思龙
tags: ["软件研发流程", "持续集成", "CI/CD", "云计算", "持续部署", "软件自动化", "Infrastructure as Code"]
---

现代软件的研发流程基本上均会配备一定程度的CI/CD（[这篇文章](https://2cloudlab.com/blog/devops-cicd-infrastructure-as-code/)解释了为何需要在企业里实施CI/CD），整个流程主要分为CI和CD部分，这篇文章将围绕CI部分展开，并通过一个具体的例子解释**如何0成本在github上构建CI**。构建CI的最佳实践离不开Trunk Based Development的分支策略，感兴趣的读者可以通过[这篇文章](https://2cloudlab.com/blog/why-organization-should-use-trunk-based-development/)来了解什么是Trunk Based Development。在github上构建CI有2个好处：**无需任何费用和有大量可以用于构建CI的模块**，借助这2个好处，小规模团队可以快速地搭建还不错的CI流程。接下来，让我们结合一个使用Go编写的Hello World例子以及基于Trunk Based Development模式来构建这个CI流程。

这篇文章将分为以下几个部分来讲解：

1. 构建CI的基本思路
2. Go例子介绍
3. 基于github Actions构建CI

## 构建CI的基本思路

本篇文章的CI是基于Trunk-Based Development来展开的，因此这个CI的一个特点就是能够快速响应每一次修改。为了能够让CI及时响应，则需要定义一个workflow，这个workflow是针对master分支而设计的。每一名研发成员提交或PR到master分支均会触发这个workflow，它的运行时长将决定研发团队能否及时看到结果，因此这个workflow只需要定义以下步骤：

* 准备编译环境
* 安装依赖库
* 获取源代码
* 检测代码的合法性
* 编译源代码
* 执行自动化测试（仅仅包括单元测试）
* 生成测试报告

当某一阶段的功能研发完成之后，则需要拉取release分支来进行后续的发布。为了能够保证release分支的质量，则需要定义另外一个workflow，该workflow的作用是确保新功能集成在一起是正常的工作的，并将集成好的功能归档到公共网络上。这个workflow需要定义以下步骤：

* 准备编译环境
* 安装依赖库
* 获取源代码
* 检测代码的合法性
* 编译源代码
* 执行自动化测试（包括单元测试和集成测试）
* 生成测试报告
* 集成和归档

## Go例子介绍
## 基于github Actions构建CI

研发工作者的每一次提交都会在较短的时间内得到反馈，以便及时修复提交之后产生的问题。每一次提交都会触发一系列活动：准备编译环境、安装依赖库、获取源代码、检测代码的合法性、编译源代码、执行自动化测试、生成测试报告以及归档编译通过的集成安装包。用户只需要下载归档好的安装包，而研发工作者则专注于软件功能的研发，整个过程就是CI

[Building a basic CI/CD pipeline for a Golang application using GitHub Actions](https://brunopaz.dev/blog/building-a-basic-ci-cd-pipeline-for-a-golang-application-using-github-actions)
[Creating a CI/CD pipeline using Github Actions](https://medium.com/@michaelekpang/creating-a-ci-cd-pipeline-using-github-actions-b65bb248edfe)