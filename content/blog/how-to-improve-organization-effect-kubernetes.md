---
title: "如何提高企业的研发效率--Kubernetes的最佳实践"
date: 2020-03-18T12:21:58+06:00
description : ""
type: post
image: images/blog/Kubernetes-logo-1.png
author: 郑思龙
tags: ["Kubernetes", "Docker", "CI/CD", "云计算", "软件研发效率"]
---

## 什么是Kubernetes(K8S)
Kubernetes (K8S)是一套管理容器资源的开源系统，它提供了以下功能:

* 分配资源

它会根据资源的使用情况(这些资源包括数据中心，服务器，CPU，内存，端口等)，在一族服务器上，以最优的方式，创建和运行容器。

* 部署

它支持多种在线逐步更新策略，这些策略有rolling deployment， blue-green deployment以及 canary deployment。如果在更新过程中产生错误，它会自动恢复到上一次可用的状态，从而确保服务7*24小时可用。

自带修复功能

它会一直监控资源的运行状态，自动将可用的资源替换不可使用的资源。

弹性伸缩

它支持横向和纵向伸缩。负载增多或减少时，它可以自动增加或减少适度的资源来响应负载。它也可以升级或降级资源的处理能力来支持纵向扩展，比如提高CPU的处理能力或者增加内存。

负载均衡

它能使外部访问内部资源(常见的资源有container)，并将外部请求均匀地分配给不同的资源。

发现服务

它有内置的DNS服务，并提供Service资源，使得容器能够找到彼此来进行通信。

配置和授权

它允许你设置不同的环境变量来区分不同的环境，这些环境有stage、test和prod。也允许你为资源设置不同的访问权限。

## 为什么选择K8S

K8S作为其容器化应用的编排系统，已经广泛应用于大多数企业。它之所以流行的原因有以下几点：

* 丰富的功能
Kubernetes offers a huge range of functionality for managing containers, including auto scaling, auto healing, rolling deployments, service discovery, secrets management, configuration management, bin packing, storage orchestration, batch execution, access controls, log aggregation, SSH access, batch processing, and much more.

* 庞大的社区
Kubernetes has the biggest community of any orchestration tool, with more than 50,000 stars and 2,500 contributors on GitHub, thousands of blog posts, numerous books, hundreds of meetup groups, several dedicated conferences, and a huge ecosystem of frameworks, tools, plugins, integrations, and service providers.

* 可用于传统的数据中心或者云服务提供商
You can run Kubernetes on-premise, in the cloud (with 1st class support from the cloud provider, e.g.,: AWS offers EKS, Google Cloud offers GKE, Azure offers AKS), and on your own computer (it’s built directly into the Docker desktop app). This reduces lock-in and makes multi-cloud and hybrid-cloud more manageable, as both the containers themselves and the way you manage them are portable.

* 技术得到了验证
Kubernetes was originally designed by Google, based on years of experience with their internal container management systems (Borg and Omega), and is now maintained by the Cloud Native Computing Foundation. It’s designed for massive scale and resiliency (Google runs billions of containers per week) and with a huge community behind it, it’s continuously getting better.

## K8S的基本概念

## 参考

1. [Kubernetes Liveness and Readiness Probes: How to Avoid Shooting Yourself in the Foot](https://blog.colinbreck.com/kubernetes-liveness-and-readiness-probes-how-to-avoid-shooting-yourself-in-the-foot/)

*[2cloudlab.com](https://2cloudlab.com/)为企业准备产品的运行环境，只需要1天！*