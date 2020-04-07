---
title: "如何提高企业的研发效率--trunk-based development"
date: 2020-03-16T12:21:58+06:00
description : "企业的研发团队在研发产品功能时通常会选择2种分支管理策略，它们分别是Feature Branches Development和Trunk-based Development。2种分支管理策略都有它们适用的场景，比如在github上研发开源软件时，经常会使用Feature Branches Development模式，而Google，Facebook，LinkedIn，微软常常会使用Trunk-based Development模式。企业在实施CI（持续集成）时通常需要Trunk-based Development方面的实践，原因在于这种模式能够快速输出集成的结果。本文将围绕Trunk-based Development展开，并提供一些可实施该模式的操作步骤。"
type: post
image: images/blog/trunk-based-development-6995662e.png
author: 郑思龙
tags: ["软件研发流程", "trunk-based development", "CI/CD", "云计算", "分支管理"]
---

企业的研发团队在研发产品功能时通常会选择2种分支管理策略，它们分别是Feature Branches Development和Trunk-based Development。2种分支管理策略都有它们适用的场景，比如在github上研发开源软件时，经常会使用Feature Branches Development模式，而Google，Facebook，LinkedIn，微软常常会使用Trunk-based Development模式。企业在实施CI（持续集成）时通常需要Trunk-based Development方面的实践，原因在于这种模式能够快速输出集成的结果。本文将围绕Trunk-based Development展开，并提供一些可实施该模式的操作步骤。

1. 什么是Trunk-based Development？
2. 团队需要掌握哪些技巧来实践Trunk-based Development？
3. 为Trunk-Based Development配套CI服务
4. Trunk-Based Development的实施细节
5. 结论和参考

## 什么是Trunk-based Development？

Trunk-based Development是指：所有研发人员围绕主分支(也就是我们常常见到的`master`分支)来共同研发，在研发过程中拒绝创建存活时间较长的分支，并使用Feature Toggles和Branch by Abstraction等技术在主分支上逐步发布需要长时间（通常是1周）才能研发完成的功能。[官方](https://trunkbaseddevelopment.com/#one-line-summary)对Trunk-based Development的概括如下所示：

> A source-control branching model, where developers collaborate on code in a single branch called ‘trunk’ *, resist any pressure to create other long-lived development branches by employing documented techniques. They therefore avoid merge hell, do not break the build, and live happily ever after.

上面这段描述说明了Trunk-based Development的目的在于解决合并和持续构建的问题。为了理解Trunk-based Development是如何解决以上2个问题的，需要从下面这张图说起。下图展示了：采用Trunk-based development来进行软件研发时所涉及的一系列活动：

![](https://2cloudlab.com/images/blog/what_is_trunk.jpg)

上图规定了以下规则：

1. 所有研发人员直接在`trunk`上提交代码
2. 对外发布产品的时候需要从`trunk`上拉取`release`分支（比如1.1.x和1.2.x），并基于`release`分支来发布(比如1.1.0和1.1.1)
3. `release`分支中出现的bug或者需要性能优化时，则需要在`trunk`上完成，并通过*cherry-pick*的方式在`trunk`中挑选对应的*commits*合并到`release`分支，此时的小版本号从1.1.`0`变成1.1.`1`
4. 对外发布新功能时，需要基于`trunk`分支，重新拉取`release`分支，版本号从1.`1`.x变成1.`2`.x，同时1.1.x的`release`分支将被废弃
5. 在`trunk`分支上，每个commit之间的提交间隔很短，通常在一天之内提交好几次，甚至更多次

在这些规则之下，研发者可以持续地在`trunk`分支中提交代码，而且期间没有合并。为了能够使得每一次提交都能够顺利地在`trunk`分支中通过，则需要一些技巧和CI服务器。接下来让我们看看都有哪些技巧能够使得企业成功地实施Trunk-based Development。

## 团队需要掌握哪些技巧来实践Trunk-based Development？

为了使Trunk-based Development能够在研发团队中顺利开展起来，需要团队成员掌握以下技巧，并且达成共识。

1. 将任务划分成许多可以在1天以内完成的小模块

快速验证想法的第一步就是将一个任务分解成多个可测试的子任务，并逐步实现。完成这些子任务所需的时间不应该超过一天，这么做的原因是每次完成子任务所需要的改动影响范围较小，而且这些改动被提交之后，其他团队成员能够及时看到，从而使得团队作为整体，清楚产品的研发状况。

2. 针对研发的功能编写自动化测试用例，并在本地验证

团队中的每一名研发人员都应该针对自己的研发任务来编写对应的单元测试，并在研发结束之后，在本地运行这些单元测试来验证正在研发的功能。除此之外，在开始研发时需要从`trunk`获取最新代码，并在本地运行已有的单元测试，确保拿到的代码是正常的。在设计单元测试时，须遵守的原则是每一个单元测试能够独立运行并且能够在短时间内运行结束（通常在本地执行所有单元测试所需的时间不应该超过5分钟）。在获取或提交代码时，在本地运行单元测试的原因是确保拿到的或者即将提交的代码能够正常工作，从而降低了破坏`trunk`的风险（`trunk`分支不稳定将会阻碍在这个分支上工作的所有人）。

3. 执行实时Code Review

当你研发的功能在本地验证通过之后，下一步就是寻找团队中其他人帮忙Code Review。通常大家习惯发起一个Pull Request，然后等待团队中的其他人进行Code Review。由于各种原因（比如没有及时看到这个Pull Request），这个Code Review的过程将变得漫长起来。因此，在实践Trunk-based Development时，需要实时进行Code Review，以便缩短Code Review所需的时间，进而能够及时将改动推送到`trunk`分支。这种实时Code Review的做法有很多种，比如让你身后的团队成员到你的电脑前帮忙Code Review，同时你可以给他解释为什么要这么做。

4. 使用[branch by abstraction](https://martinfowler.com/bliki/BranchByAbstraction.html)或者[feature flags](https://martinfowler.com/bliki/FeatureToggle.html)等技术来逐步提交还在研发中的功能

团队在研发的日常中，总是会遇到一些复杂且耗时的任务，完成这些任务需要一周或是更长的时间。因此在处理这些任务时不仅需要将其分解成多个子任务，而且每次完成子任务的研发时都需要将其提交到`trunk`分支中并且通过branch by abstraction或者feature flags等技术禁用这些子功能。直到所有子功能完成并且放在一起能够工作时才将这个任务开放出来。应用branch by abstraction或者feature flags等技术时应该遵守简单的原则，比如可以在代码中为该任务编写一个入口函数，但是这个入口函数没有被调用。

5. 每次向`trunk`提交代码时，都应该自动地触发编译和测试

为了能够自动化编译和测试新的提交，需要借助CI服务器。通过CI服务器构建编译和测试2个阶段（如下图所示）。这么做的目的是确保每一次提交都能够被机器自动化的验证，从而确保每一次提交都没有破坏`trunk`。

![](https://2cloudlab.com/images/blog/pipelines1.png)

6. 如果某一次提交破坏了`trunk`分支，那么应该停下手中的任务，优先恢复`trunk`分支

团队在日常的研发事务中总是会犯错，如果一次疏忽导致`trunk`分支无法通过测试，那么需要第一时间解决这个问题。如果这个问题无法快速解决，那么需要将此次提交撤销，并回退到上一次提交。这么做就是要确保`trunk`分支随时可用。

Trunk-Based Development自身并无没有给团队带来任何好处。为团队带来好处的是在Trunk-Based Development中应用了以上6点技巧。因此在企业研发部门实施Trunk-Based Development时，需要团队中的每一名成员都要掌握以上技巧，最终养成习惯。从这个角度来看，Trunk-Based Development更多的是依赖于人的行为，在一致的行为下应用自动化工具能够从整体上提高企业的研发效率！

当研发人员都掌握了以上技巧，同时，企业的研发部门已经决定使用Trunk-Based Development来研发产品，那么接下来就需要搭建一些自动化基础设施来辅助整个研发团队，其中CI服务就是构建现代化高效软件研发流程的初始环节。

## 为Trunk-Based Development配套CI服务

CI（Continues Integration）是指将各个研发团队的研发成果正确且快速地集成在一起，并提供给其他团队（测试团队、DevOps团队等）使用。为了将Trunk-Based Development向整个研发部门推广，则需要一个好的CI服务。每一个提交到`trunk`上的改动，都会自动地触发CI服务，并由该服务获取`trunk`上的源码并顺序执行自定义的一些步骤。这些步骤有编译该源码和执行单元测试，每一步执行结束后都会输出一些结果，这些结果有成功或者失败，如果失败则会出现失败的信息。为了能够让团队成员及时看到失败的结果，一种做法是将在团队周围放置一台大电视，用于显示CI服务的执行结果。

除了要搭建CI服务，还需要应用一些发布策略。比如上图从`trunk`分支中拉出`release`分支，这么做是为了基于`release`分支对外发布产品，同时团队的其他成员依然能够在`trunk`上提交代码。由于`release`分支主要是为了对外发布产品，因此它不仅需要CI的支持，还需要CD（Continuous Delivery）的支持，2者结合就是CI/CD。与`trunk`不同，CI服务不仅需要监测`release`分支的变化并自动地编译源码、执行单元测试，而且还需要将编译的结果归档到团队内部共享的存储服务上，并自动地触发CD服务，使得CD服务能够将编译结果从存储服务中自动地部署到研发环境（dev）、测试环境（test）、预生产环境（stage）和生产环境（prod）。环境越多，实施自动化部署将任务也将增多，因此企业需要结合自身的现实状况来决定哪些环境是需要的（比如大多数企业只需要stage和prod环境就足够了）。

## Trunk-Based Development的实施细节

不同企业在研发团队中实施Trunk-Based Development都会有一些细微的差别，对于大多数需要**研发软件产品**的企业，可以参考以下步骤在研发团队中实施Trunk-Based Development。

* 将产品相关的代码放到一个repository里，并且严格要求这个repository的分支数量每天不能超过研发人数（比如该研发团队有5个研发，2个测试，1个PO，1个UX，1个SM以及1个架构师，一共11个人）
* 该repository有一个长期存在的分支`trunk`或者`master`。当需要对外发布的时候则需要拉出`release`分支，当有新的功能要发布的时候，将该分支删除并拉取新的`release`分支。研发人员可以直接在`trunk`或`master`分支上提交代码，当然也可以拉取`feature`分支，但是`feature`分支的生命周期应该在1天之内
* 搭建CI服务，比如可以考虑使用Jenkins或者使用github的Actions。前者需要自己搭建，工作量大，服务器可以是自建，也可以使用云服务提供商的服务器（比如阿里云或AWS）。后者只需要编写`.yaml`文件就可以构建CI服务，服务器是github提供的
* CI服务器会检测`trunk`和`release`分支，每个次提交，都会触发CI服务器，构建代码和执行自动化测试。`trunk`分支所对应的CI构建流程，其运行一次所需要的时间需要控制在30分钟之内，其目的是为了检测每次提交都是正常的。`release`分支所对应的CI构建流程，其运行一次所需要的时间也需要控制在30分钟之内并归档编译出来的结果，除此之外还需为该分支搭建CD服务。CD服务能够将编译出来的结果自动部署到其它环境（比如stage和prod）
* 为团队的每一个研发人员预留时间学习和掌握之前提到的技巧，使得团队成员达成共识
* 每次发布只能通过`release`分支，修复bug和性能优化的改动应该提交到`trunk`分支，最终通过cherry-pick的方式将这些提交merge到`release`分支。当有新功能对外发布时，需要删除原来的`release`分支，并从`trunk`分支拉取新的`release`分支

## 结论和参考

Trunk-based Development已经被各大公司成功实践了很十几年，这些公司有Google、Facebook、LinkedIn等。企业在研发**产品**时，想要在研发部门中顺利地实施Trunk-based Development，还需要掌握一些技巧和搭建自动化基础设施。这些技巧需要所有研发人员达成共识，并养成习惯。当习惯形成之后，则需要借助一些自动化基础设施来加速研发流程，这个研发流程就是CI/CD。当研发流程搭建起来之后，则需要应用一些发布策略。一切就绪之后，整个研发团队的研发效率将会达到一个质的飞跃。在研发团队中实施Trunk-based Development以及为其搭建CI服务只是构建企业级软件研发流程的第一步。当新功能完成研发，并准备好发布的时候，也需要一套基础设施将研发好的功能及时高效地发布到用户现场，这就是Continuous Delivery(CD)。企业要想搭建完整的CI/CD流程，除了实施本文提到CI部分，还需要参考这篇文章[<如何提高企业的研发效率--CI/CD>](https://2cloudlab.com/blog/why-organization-should-practice-cicd/)来实施CD部分。

本文的内容参考了大量国外的资料，这些资料可以进一步加深读者对Trunk-based development的理解，读者可以根据自身的实际情况进一步学习国外最新的技术，并将其应用到自己的项目当中。

1. [Trunk-Based Development](https://trunkbaseddevelopment.com/)
2. [Feature Toggles](https://martinfowler.com/bliki/FeatureToggle.html)
3. [Branch By Abstraction](https://martinfowler.com/bliki/BranchByAbstraction.html)
4. [Why I love Trunk Based Development](https://medium.com/@mattia.battiston/why-i-love-trunk-based-development-641fcf0b94a0)
5. [Enabling Trunk Based Development with Deployment Pipelines](https://www.thoughtworks.com/insights/blog/enabling-trunk-based-development-deployment-pipelines)
6. [Google DevOps tech](https://cloud.google.com/solutions/devops/devops-tech-trunk-based-development)
7. [The best branching model to work with Git](https://medium.com/@grazibonizi/the-best-branching-model-to-work-with-git-4008a8098e6a)
8. [What is Trunk-Based Development?](https://paulhammant.com/2013/04/05/what-is-trunk-based-development/)

*[2cloudlab.com](https://2cloudlab.com/)为企业准备产品的运行环境，只需要1天！*