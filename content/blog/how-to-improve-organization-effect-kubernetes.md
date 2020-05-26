---
title: "如何提高企业的研发效率--Kubernetes的最佳实践"
date: 2020-03-18T12:21:58+06:00
description : ""
type: post
image: images/blog/Kubernetes-logo-1.png
author: 郑思龙
tags: ["Kubernetes", "Docker", "CI/CD", "云计算", "软件研发效率"]
---

* 什么是Kubernetes(K8S)
* 为什么选择K8S
* K8S的基本概念

## 什么是Kubernetes(K8S)
Kubernetes (K8S)是一套管理容器资源的开源系统，它提供了以下功能:

* 分配资源

它会根据资源的使用情况(这些资源包括数据中心，服务器，CPU，内存，端口等)，在一族服务器上，以最优的方式，创建和运行容器。

* 部署

它支持多种在线逐步更新策略，这些策略有rolling deployment， blue-green deployment以及 canary deployment。如果在更新过程中产生错误，它会自动恢复到上一次可用的状态，从而确保服务7*24小时可用。

* 自带修复功能

它会一直监控资源的运行状态，自动将可用的资源替换不可使用的资源。

* 弹性伸缩

它支持横向和纵向伸缩。负载增多或减少时，它可以自动增加或减少适度的资源来响应负载。它也可以升级或降级资源的处理能力来支持纵向扩展，比如提高CPU的处理能力或者增加内存。

* 负载均衡

它能使外部访问内部资源(常见的资源有container)，并将外部请求均匀地分配给不同的资源。

* 发现服务

它有内置的DNS服务，并提供Service资源，使得容器能够找到彼此来进行通信。

* 配置和授权

它允许你设置不同的环境变量来区分不同的环境，这些环境有stage、test和prod。也允许你为资源设置不同的访问权限。

## 为什么选择K8S

K8S作为容器化应用的编排系统，已经广泛应用于大多数企业。它之所以流行的原因有以下几点：

* 丰富的功能

它为管理容器提供了大量功能，这些功能包括弹性伸缩，自动修复，在线部署，服务发现，秘钥管理，配置管理，bin packing, storage orchestration, batch execution, access controls, log aggregation, SSH access, batch processing, and much more.

* 庞大的社区

K8S拥有庞大的社群，在github上拥有超过66,000颗星以及2544个贡献者。网络上有大量的博客文章来介绍K8S（包括你正在读的），也有几本写的不错的书籍（比如Kubernetes In Action）来介绍K8S。它的生态系统非常丰富，有专门提供K8S服务的提供商（比如AWS的EKS），有大量开发人员为K8S研发插件和工具。

* 可用于传统的数据中心或者云服务提供商

K8S能够应用在传统的数据中心。在传统的数据中心使用K8S的麻烦之处在于需要有专门的人准备服务器，用网线连接这些服务器，在服务器上安装K8S以及容器等等。因此在传统的数据中心搭建K8S服务不是一件容易的事情。除此之外，许多云服务商已经开始提供K8S服务（比如AWS提供了EKS，Google Cloud提供了GKE，Azure提供了AKS），使用云服务商提供的K8S服务的好处是能够直接使用，而无需关心背后的软件和硬件资源。当然你也可以将K8S部署在个人电脑上，但是会失去一些功能，比如K8S的Worker节点只有一个。

* 技术得到了验证

K8S期初是由Google研发的，并在内部管理里了十几万台服务器。经过多年的实践以及改进最终对外发布了K8S。Google有大量互联网服务（比如Google Doc，Google Email，Google Search等等），这些服务的背后由成千上百万的容器支撑，因此为了高效管理这些容器，支持大规模伸缩以及提高可靠性，那么K8S在问世的时候就已经考虑这些特性了。

## K8S的基本概念

## 参考

1. [Kubernetes Liveness and Readiness Probes: How to Avoid Shooting Yourself in the Foot](https://blog.colinbreck.com/kubernetes-liveness-and-readiness-probes-how-to-avoid-shooting-yourself-in-the-foot/)

*[2cloudlab.com](https://2cloudlab.com/)为企业准备产品的运行环境，只需要1天！*