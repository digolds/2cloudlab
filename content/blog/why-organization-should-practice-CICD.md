---
title: "如何提高企业的研发效率--CI/CD"
date: 2020-03-18T12:21:58+06:00
description : ""
type: post
image: images/blog/pipeline.jpg
author: 郑思龙
tags: ["软件研发流程", "持续集成", "CI/CD", "云计算", "持续部署", "软件自动化", "Infrastructure as Code"]
---

CI/CD是现代软件研发过程中必不可少的基础设施。类似于福特流水线，它能够帮助企业提高软件的研发效率，提高软件的质量以及对外发布新功能。CI/CD能够帮助企业的研发团队提高研发效率。CI/CD将企业中的所有研发人员，包括研发团队，测试团队，DevOps团队，串联在一起，使得上一个团队的输出都可以顺利地流转到下一个团队。CI/CD能够帮助企业提高软件质量。研发团队借助CI/CD能够快速看到修改产品之后的结果，从而能够及时解决因修改不当而引起的问题；测试团队将UI测试，集成测试接入到CI/CD中，使得软件产品对外发布之前，都有足够的自动化测试来验证其功能。CI/CD能够帮助企业及时对外发布产品的新功能。DevOps团队只需要执行一个命令，就能将研发团队所研发的新功能通过机器自动地部署到生产环境中，有时还能支持线上实时更新！CI/CD分为2部分，它们分别是CI和CD。每个部分都需要借助一些工具和经验来实现，其中[<如何0成本在github上构建CI>](https://2cloudlab.com/blog/how-to-setup-ci-service-base-on-github/)通过一个例子来构建CI，而本文将围绕CD来展开，包括Continue Test，Continue Monitor，Continue Security，Continue Deployment等。

*[2cloudlab.com](https://2cloudlab.com/)为企业准备产品的运行环境，只需要1天！*