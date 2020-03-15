---
title: "如何为产品提供可信度较高的运行环境"
date: 2019-11-15T12:21:58+06:00
description : "在企业中经常会发生此类事情：临近产品新功能发布的日子，企业上下忙的不可开交，甚至有些研发人员被半夜叫醒解决新功能无法使用的问题，大家急急忙忙将遇到的问题解决了却又引发了其它问题，最终导致产品新功能无法及时发布或者产品运行在一个容易奔溃的环境。这类事件反复发生，使得研发人员害怕产品新功能的每一次发布。这种害怕将导致企业延长新功能的发布周期，本来一周一次的发布计划改成了一个月一次发布。更长的发布周期将会积累和隐藏更多的风险和不确定因素，因此这类事件变得更加常见，问题变得更加糟糕！面对这个问题所带来的挑战，企业需要缩短发布周期来及早暴露和解决问题，而缩短发布周期的关键点在于如何在短时间内发现更多的缺陷！自动化测试是实现这个关键点的因素之一。"
type: post
image: images/blog/provide-stable-running-environment-for-products.jpg
author: 郑思龙
tags: ["2cloudlab.com", "云计算", "devops", "terraform", "自动化测试"]
---

在企业中经常会发生此类事情：临近产品新功能发布的日子，企业上下忙的不可开交，甚至有些研发人员被半夜叫醒解决新功能无法使用的问题，大家急急忙忙将遇到的问题解决了却又引发了其它问题，最终导致产品新功能无法及时发布或者产品运行在一个容易奔溃的环境。这类事件反复发生，使得研发人员害怕产品新功能的每一次发布。这种害怕将导致企业延长新功能的发布周期，本来一周一次的发布计划改成了一个月一次发布。更长的发布周期将会积累和隐藏更多的风险和不确定因素，因此这类事件变得更加常见，问题变得更加糟糕！面对这个问题所带来的挑战，企业需要缩短发布周期来及早暴露和解决问题，而缩短发布周期的关键点在于如何在短时间内发现更多的缺陷！自动化测试是实现这个关键点的因素之一。

自动化测试在产品的研发过程中无处不在。研发团队在研发产品时需要为其编写单元测试；测试团队在测试产品时要为其编写手动测试、集成测试和UI测试；DevOps团队需要为产品的运行环境编写自动化测试用例，确保生成的环境是稳定且支持产品的。为产品研发实施自动化测试的目的在于短时间内发现和解决更多的缺陷，从而增强产品对外发布的信心！本文将通过以下方面来介绍如何对产品的运行环境进行自动化测试，企业可以根据自身情况，引入本文所提到的自动化测试经验来确保产品的运行环境是可信的。

1. 2cloudlab模块的自动化测试
2. 静态检测Terraform的编码
3. 针对Terraform模块编写单元测试（Unit Test）
4. 针对Terraform模块编写集成测试（Integration Test）
5. 针对Terraform模块编写端到端的测试（End-to-End Test）
6. 为测试环境中的资源定制清除策略
7. 总结

其中单元测试、集成测试和End-to-End测试需要使用`Go`语言来编写大量测试代码，产品运行环境的质量主要由它们来保证。这些测试的难易程度、数量占比和运行时间由下图所示：

![](https://2cloudlab.com/images/blog/number-of-different-test-types.png)

## 2cloudlab模块的自动化测试

2cloudlab的模块都会包含一些自动化测试用例。每一个Terraform模块都会有对应的测试用例，这些测试用例会放在一个`test`目录下（目录结构如下所示），每一个测试用例所验证的场景是不同的。由于这些自动化测试用例都是用`Go`语言来编写的，因此需要使用`Go`语言的运行时环境来运行。除此之外，为了能够高效地编写自动化测试用例，需要引入第三方工具[Terratest](https://github.com/gruntwork-io/terratest)，该工具像一把瑞士军刀，提供了大量通用的基础操作。

```terraform
.
|____examples
| |____iam_across_account_assistant
| | |____main.tf
| | |____outputs.tf
| | |____README.md
| | |____terraform.tfstate
| | |____terraform.tfstate.backup
| | |____variables.tf
|____modules
| |____iam_across_account_assistant
| | |____main.tf
| | |____outputs.tf
| | |____README.md
| | |____variables.tf
|____test
| |____dep-install.sh
| |____iam_across_account_assistant_test.go
| |____README.md
```

其中`test`目录下的测试用例`iam_across_account_assistant_test.go`会调用`examples`下的手动测试例子来验证目录`modules`下的Terraform模块`iam_across_account_assistant`。

2cloudlab根据以上目录结构编写了大量的单元测试以及少量的集成测试。这些测试是遵守了以下原则来编写的:

1. 每一个测试用例都会基于真实环境来执行
2. 每一个测试用例执行结束后都会销毁已创建的资源
3. 为每一个资源指定一个独立的命名空间，以免发生名称冲突
4. 每一个测试用例都会在独立的临时目录下下运行
5. 为每一个集成测试添加可配置stage步骤
6. 测试用例之间是相互独立且可并发执行

在编写测试用例之前，有一步关键的验证：静态检测。为Terraform模块实施静态检测只需要花费几分钟，但是确能够避免一些常见的错误，接下来让我们从静态检测开始来一步一步提高产品运行环境的稳定性！

## 静态检测Terraform的编码

静态检测的主要作用在于分析Terraform模块是否遵守了Terraform的语法规则。为Terraform实施静态检测是非常有必要的，这种检测能够捕获常见的错误（比如`{}`没有成对出现，拼写错误）。实施静态检测只需要花费几分钟就能做到，因此在提高Terraform模块的质量的过程中，企业应该将静态检测实施起来。

Terraform自身提供了实施静态检测的命令：`terraform validate`。这个命令会在验证当前目录下所有后缀为`.tf`的文件，如果某些文件包含了一些编码错误，那么这些错误会被Terraform暴露出来。比如当`{}`没有成对出现的时，执行命令`terraform validate`会曝出以下提示：

```terraform
Error: Argument or block definition required

  on main.tf line 18, in module "iam_across_account_assistant":

An argument or block definition is required here.
```

除了Terraform自身提供的检测机制，还有一些工具（[tflint](https://github.com/terraform-linters/tflint)和[HashiCorp Sentinel](https://www.hashicorp.com/sentinel/)）也能提供静态检测的功能。

静态检测虽然能够捕获语法上的错误，但是它无法捕获运行时环境上的错误。运行时环境是现实世界中真实的环境，这些环境中的资源都是动态运行的。语法上的错误是比较容易发现并解决的，而运行时环境中的错误是难以察觉且不好解决，因此需要编写Unit Test、Integration Test和End-to-End Test来捕捉运行时环境中的缺陷。如果你已经花了几分钟实施静态检测，那么下一步就需要考虑如何实施单元测试。

## 针对Terraform模块编写单元测试（Unit Test）

编写单元测试的主要作用是：验证独立模块的可靠性。2cloudlab使用Terraform编写了大量的独立模块，这些模块相互独立，部署每一个模块所需的时间大约在1～5分钟。编写大量小而独立的模块有许多好处。首先，可以组合这些模块来完成复杂的部署;其次，独立的模块可以由不同的团队成员同步研发;最后，独立的模块方便测试。小而独立的模块为测试带来以下好处:

* 可并发执行单元测试用例
* 执行所有单元测试所需的时间变得更短
* 可以执行部分单元测试

这些好处能够缩短单元测试运行的时间，使得团队能够及时得到测试报告，进而根据测试报告修复检测到的缺陷。

## 针对Terraform模块编写集成测试（Integration Test）

敬请期待...

## 针对Terraform模块编写端到端的测试（End-to-End Test）

敬请期待...

## 为测试环境中的资源定制清除策略

敬请期待...

## 总结

敬请期待...