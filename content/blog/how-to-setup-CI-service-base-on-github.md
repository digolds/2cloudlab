---
title: "如何0成本在github上构建CI"
date: 2020-03-17T12:21:58+06:00
description : ""
type: post
image: images/blog/github.jpg
author: 郑思龙
tags: ["软件研发流程", "持续集成", "CI/CD", "云计算", "持续部署", "软件自动化", "Infrastructure as Code"]
---

现代软件的研发流程基本上均会配备一定程度的CI/CD（[这篇文章](https://2cloudlab.com/blog/devops-cicd-infrastructure-as-code/)解释了为何需要在企业里实施CI/CD），整个流程主要分为CI和CD部分，这篇文章将围绕CI部分展开，并通过一个具体的例子解释**如何0成本在github上构建CI**。构建CI的最佳实践离不开Trunk Based Development的分支策略，感兴趣的读者可以通过[这篇文章](https://2cloudlab.com/blog/why-organization-should-use-trunk-based-development/)来了解什么是Trunk Based Development。在github上构建CI有2个好处：**无需任何费用和有大量可以用于构建CI的模块**，借助这2个好处，小规模团队可以快速地搭建还不错的CI流程。接下来，让我们结合一个使用Go编写的Hello World例子以及基于Trunk-Based Development模式来构建这个CI流程。

这篇文章将分为以下几个部分来讲解：

1. 在github上构建CI的基本思路
2. 在github上构建CI的优势
3. 通过一个Go示例在github上构建CI
4. 总结

## 在github上构建CI的基本思路

构建CI有2种方式，一种是组建团队从0开始，另外一种是借助第三方服务开始。在github上构建CI属于后者，其优势在于github提供了许多方便开发者研发的服务，其中有3种服务可用于免费构建CI，它们分别是：免费托管源码，免费存储以及免费构建服务（也就是最近推出的Actions服务）。有了这3种服务，任何一个团队均可以根据自身的情况来构建CI。接下来，我将基于Trunk-Based Development模式提出实践CI的一种方法，这种方法提出了2个独立的流程，并定义了触发这2个流程的条件。

首先，我们需要定义一个流程（master_workflow），这个流程的作用是快速响应`master`分支上的每一次改动。该分支上每一次改动都会自动启动服务器或虚拟机来执行该流程，并将结果反馈（比如通过邮件通知的方式）给研发团队。这个流程的主要作用在于每天都确保`master`分支是健康的，比如语法规则是正确的，编译是成功的和单元测试能通过，因此该流程的一大特点是执行周期通常限制在10~30分钟内。这一要求使得构成该流程的步骤尽可能的少，下面是构成该流程的几个步骤：

* 准备编译环境
* 安装依赖库
* 获取源代码
* 检测代码的合法性
* 编译源代码
* 执行自动化测试（仅仅包括单元测试）
* 生成测试报告

为了缩短这个流程的执行周期，可以考虑这些方法：将准备编译环境和安装依赖库步骤提前合并成一个步骤（通过Docker技术），无需在运行时准备；将检测代码的合法性和编译源代码步骤分布在不同的机器上同时执行；在执行自动化测试的步骤中并发执行单元测试。缩短这个流程的执行周期是为了让整个团队更快地看到每一次修改的结果，如果这个修改阻碍了团队的工作（比如编译失败了），那么提交该修改的研发工作者能够第一时间修复。

其次，我们还需要定义一个集成流程（integration_workflow），这个流程的作用是将所有组件集成在一个完整的压缩包里，并发布到一个共有的存储空间，以便测试团队和DevOps团队展开后续的测试和部署工作。这个流程不仅包括之前流程所定义的步骤，而且还新增了**集成和归档**步骤，如下所示：

* 准备编译环境
* 安装依赖库
* 获取源代码
* 检测代码的合法性
* 编译源代码
* 执行自动化测试（包括单元测试和集成测试）
* 生成测试报告
* 集成和归档

**注：**此时，执行自动化测试包括了集成测试。因此，从总体而言，这个流程的运行周期会更长一点，通常在30~60分钟。

以上就是基于Trunk-Based Development模式，在github上构建CI的基本思路。首先，我们需要为`master`分支定义一个流程，该分支上的每次修改都会触发该流程；其次，我们需要为`release`分支定义另外一个流程，该分支上的每一次修改都会触发该流程，并将集成包发布到一个共有存储空间。为何需要定义这2个流程，读者可以参考[这篇文章](https://2cloudlab.com/blog/why-organization-should-use-trunk-based-development/)。

## 在github上构建CI的优势

你可以选择组建一支团队来打造CI/CD，这种方式需要自己搭建服务器，安装软件（比如Jenkins）和配置，因此所需时间会较长。另外，你也可以选择第三方服务来搭建CI/CD（比如在github上构建CI）。在github上搭建CI有2个好处，它们分别是免费和共享其他人的成果。

github向开发者提供了3种免费的服务来搭建CI，它们分别是源码托管，归档存储和Actions服务。开发者可以免费地将代码发布到github上，世界各地的开发者可以参与进来共同开发；开发者也可以免费地使用github所提供的Actions服务来构建流程；开发者可以将流程输出的集成包发布到github提供的存储服务里，供用户使用。

这3种服务不仅免费，而且其中Actions服务提供了可复用的模块。这些可复用的模块是由全世界的开发者贡献的，因此可以直接将这些模块组合在一起构成适合自己的CI流程。比如这篇文章的示例使用了Go相关的Actions模块来构建上一节提到的2个流程。

github平台存储了开发者的代码，提供了搭建CI的Action服务，拥有大量可复用的模块以及支持存储，此时，开发者只需要使用这些可复用的模块来定义流程，便可以将代码，Actions服务和存储服务联系在一起。而流程的定义是通过`yaml`文件来完成的，比如上一节的2个流程就分别对应着文件`master_workflow.yaml`和`integration_workflow.yaml`。

组建一个团队来搭建CI，需要准备服务器，安装软件，用网线连接服务器等，而借助github，则只需要编写`yaml`文件就能快速构建出一个稳定的CI，这种转变大大地缩短了搭建CI的时间，让开发者专注于软件的功能研发！

接下来让我们看一个具体的例子来实践在github上构建CI

## 通过一个Go示例在github上构建CI

这个例子是由Go语言来编写的，完整的源码可以到[这里](https://github.com/2cloudlab/demo_for_ci)获取，其目录结构如下所示：

```go
mylib
```

其中`.github/workflows`中定义了2个流程，由它们构成这个示例的CI，其余部分是Go相关的源码。

## 总结

研发工作者的每一次提交都会在较短的时间内得到反馈，以便及时修复提交之后产生的问题。每一次提交都会触发一系列活动：准备编译环境、安装依赖库、获取源代码、检测代码的合法性、编译源代码、执行自动化测试、生成测试报告以及归档编译通过的集成安装包。用户只需要下载归档好的安装包，而研发工作者则专注于软件功能的研发，整个过程就是CI

[Building a basic CI/CD pipeline for a Golang application using GitHub Actions](https://brunopaz.dev/blog/building-a-basic-ci-cd-pipeline-for-a-golang-application-using-github-actions)
[Creating a CI/CD pipeline using Github Actions](https://medium.com/@michaelekpang/creating-a-ci-cd-pipeline-using-github-actions-b65bb248edfe)