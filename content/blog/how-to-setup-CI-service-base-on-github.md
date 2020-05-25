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
.
|____.github
| |____workflows
| | |____integration_workflow.yaml
| | |____master_workflow.yaml
|____go.mod
|____main.go
|____main_integration_test.go
|____main_test.go
|____Makefile
|____mylib
| |____external_lib.go
| |____external_lib_test.go
```

其中`.github/workflows`目录下有2个文件`master_workflow.yaml`和`integration_workflow.yaml`，由它们构成这个示例的CI，其余部分是Go相关的源码。github的Actions服务会根据这2个文件中的内容来启动虚拟机并执行其中定义的步骤。接下来让我们看看这2个文件的区别。

首先，让我们看看`master_workflow.yaml`中的内容:
```yaml
name: Daily routines
on:
  push:
    branches:
      - master
  pull_request:

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - name: Set up Go
        uses: actions/setup-go@v1
        with:
          go-version: 1.13

      - name: Check out code
        uses: actions/checkout@v1

      - name: Lint Go Code
        run: |
          export PATH=$PATH:$(go env GOPATH)/bin # temporary fix. See https://github.com/actions/setup-go/issues/14
          go get -u golang.org/x/lint/golint 
          make lint

  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - name: Set up Go
        uses: actions/setup-go@v1
        with:
          go-version: 1.13

      - name: Check out code
        uses: actions/checkout@v1

      - name: Run Unit tests.
        run: make test-coverage
```

以上内容主要分为以下2部分：

* `on`定义了触发条件

这部分的含义是如果有修改推送或者PR到`master`分支，那么Actions服务将会根据`jobs`中定义的内容来启动虚拟机并执行相关的步骤

* `jobs`定义了执行步骤

这部分定义了2个job，它们分别是`lint`和`test`。每一个job运行在一台虚拟机或者容器里，上面运行着Ubuntu操作系统，job之间是相互独立同时运行的。这些job可以引用一些可复用的Actions模块（比如`lint`中的`actions/setup-go@v1`和`actions/checkout@v1`），每个模块定义了一些执行步骤（比如准备Go环境和拉取该Go示例的源码)。

当研发人员向`master`分支提交代码，Actions就会根据该`yaml`文件，创建2台虚拟机或者容器，同时执行`lint`和`test`。`lint`的作用是检查Go的语法问题，而`test`的作用是运行单元测试并生成测试报告。如果其中有一个job失败了，那么整个流程是失败的，研发工作者可以及时看到整个流程的结果，如下图所示：

![](https://2cloudlab.com/images/blog/master-workflow-partial-fail.png)

其次，让我们看看`integration_workflow.yaml`中的内容：
```yaml
name: Package routines
on:
  create:
    tags:
      - v*

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - name: Set up Go
        uses: actions/setup-go@v1
        with:
          go-version: 1.13

      - name: Check out code
        uses: actions/checkout@v1

      - name: Lint Go Code
        run: |
          export PATH=$PATH:$(go env GOPATH)/bin # temporary fix. See https://github.com/actions/setup-go/issues/14
          go get -u golang.org/x/lint/golint 
          make lint

  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - name: Set up Go
        uses: actions/setup-go@v1
        with:
          go-version: 1.13

      - name: Check out code
        uses: actions/checkout@v1

      - name: Run all tests.
        run: make all-tests-coverage

  build:
    name: Integration
    runs-on: ubuntu-latest
    needs: [lint, test]
    steps:
      - name: Check out code
        uses: actions/checkout@v1

      - name: Validates GO releaser config
        uses: docker://goreleaser/goreleaser:latest
        with:
          args: check

      - name: Create package on GitHub
        uses: docker://goreleaser/goreleaser:latest
        with:
          args: release
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```

以上内容新增了`build`任务，这个任务需要等待`lint`和`test`任务成功之后才会执行。它使用了`docker://goreleaser/goreleaser:latest`来制作集成包，并发布到github的存储服务（如下图所示）。除此之外，这个workflow的`test`任务执行了单元测试和集成测试，之所以执行集成测试，是因为在这个阶段需要将各个模块集成到一起测试，确保软件整体是正常工作的，同时也确保了下游团队拿到的集成包是可信的。由于添加了集成测试，因此执行该过程所需的时间会比前面另外一个过程所需的时间长，从而使得团队无法及时看到结果。这也就是为什么我们不希望将集成测试放在`master_workflow.yaml`中执行。

![](https://2cloudlab.com/images/blog/integration-workflow-success.png)

有了以上2个文件，研发工作者只需要专注于软件功能的研发。在新功能的研发阶段，研发工作者只需要修改`master`分支，其对应的master_workflow流程会及时响应每一次修改。在准备发布新功能的阶段，发布工作者只需要拉取新的分支（比如`integration`）并为其打上类似`v0.0.2`的tag，对应的integration_workflow流程将生成打包结果并归档到github的免费存储服务，供其他团队使用。

## 总结

构建现代CI的方式有很多种，其中github提供了一些免费的服务来解决这个问题，这些服务分别是源码托管服务、Actions服务和存储服务。开发者只需要定义`yaml`文件就可以将这3个服务串联在一起创建出一个可靠的CI。在github上构建CI的优势有2个：**免费**和**共享其他开发者的成果**。任何团队都可以免费地使用这3种服务，除此之外，CI的构建者可以使用其他人制作好的可复用模块来快速搭建CI。

本文通过一个Go示例来解释了基于Trunk-Based Development，在github上构建CI。这个示例定义了2个`yaml`文件，它们分别是：`master_workflow.yaml`和`integration_workflow.yaml`。每个文件对应一个分支，并作用于不同的研发阶段，比如master_worflow流程的主要作用在于确保`master`分支一直处于健康状态，而integration_workflow流程则确保对外发布一个可信度较高的集成包。

虽然通过github能够轻松地构建CI，但是它也是有局限的。首先，它的Actions服务的免费套餐是有时间限制的（2,000 minutes/month），超出了这个限制则需要升级为付费用户。其次，通过中国区访问它的存储服务的延时较大，从而导致用户下载集成包的过程变慢了。最后，如果要集成CD，那么需要设置访问凭证，从而暴露了风险。

关于Actions服务的了解，读者可以参考以下文章

* [Building a basic CI/CD pipeline for a Golang application using GitHub Actions](https://brunopaz.dev/blog/building-a-basic-ci-cd-pipeline-for-a-golang-application-using-github-actions)
* [Creating a CI/CD pipeline using Github Actions](https://medium.com/@michaelekpang/creating-a-ci-cd-pipeline-using-github-actions-b65bb248edfe)

*[2cloudlab.com](https://2cloudlab.com/)为企业准备产品的运行环境，只需要1天！*