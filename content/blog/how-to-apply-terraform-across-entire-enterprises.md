---
title: "一天之内，部署线上服务--高效使用terraform"
date: 2019-07-15T12:29:40+06:00
description : "terraform是一个用go语言编写的跨平台、开源、只有单个运行文件的命令行程序。terraform通过解析和执行terraform configuration文件集合，最终会在短时间内生成分布式软件所运行的环境，避免了手动配置环境，减少出错的可能性。在企业里，要想高效地使用terraform来正确且快速地生成分布式软件所运行的环境，不仅需要掌握terraform知识，还需要结合工程方面的实践经验以及其它工具来共同实现。"
type: post
image: images/blog/terraform-hashicorp.png
author: 郑思龙
tags: ["terraform工具", "企业的数字化转型", "devops", "cicd", "云计算" , "cloudcomputing"]
---

terraform是一个用go语言编写的跨平台、开源、只有单个运行文件的命令行程序。terraform通过解析和执行terraform configuration文件集合，最终会在短时间内生成分布式软件所运行的环境，避免了手动配置环境，减少出错的可能性。在企业里，要想高效地使用terraform来正确且快速地生成分布式软件所运行的环境，不仅需要掌握terraform知识，还需要结合工程方面的实践经验（比如版本控制，模块划分，测试）以及其它工具（比如Packer、Docker、Kubernetes）来共同实现。

这篇文章将通过以下话题来说明**如何在企业中高效使用terraform**：

1. 企业为何使用Terraform？
2. Terraform的运行机制
3. 如何解决多人同时使用Terraform的问题
4. 在企业中建立Devops团队以及Terraform规范
5. 现实世界中DevOps团队一天的工作内容
6. 总结

## 企业为何使用Terraform？

Terraform的主要作用在于基于云服务提供商创建资源和准备运行环境。企业内部需要借助不同工具推行[DevOps](https://2cloudlab.com/blog/devops-cicd-infrastructure-as-code/)，Terraform就是其中之一。软件产品或服务都需要运行在一个特定的环境上，因此企业需要为软件准备这些运行环境，而这些运行环境的准备就是需要工具：Terraform。除此之外还有其它工具（比如CloudFormation），企业之所以使用Terraform工具的原因在于：

1. 拥有强大而且活跃的社区支持、免费和开源
2. 支持大部分云服务提供者（AWS、Azure、GCP以及其它云服务）
3. 只需要一个terraform运行文件和云服务厂商的账号就能在自己的电脑上使用
4. terraform是基于描述型语言（declarative language）来定义资源的最终状态
5. terraform支持一致性部署（immutable infrastructure）,每次更新均是可重现且一致的

随着云计算的普及，企业应该使用云计算带来的好处--降低成本和应用更加先进的技术--来使自己处于行业领先位置。使用Terraform可以以Infrastructure as Code的方式使用云服务，DevOps人员只需要编写脚本、安装Terraform可执行文件、一个云服务商账号以及执行脚本的一台电脑就能远程为软件创建资源和准备环境。这些脚本文件由版本控制系统进行管理，这样一来工程方面的经验便可应用在这些脚本文件上。要想高效使用Terraform，除了要学习Terraform知识，还要解决多人使用的情况。在这之前，以一个简单的示例来了解Terraform的运行机制是一个良好的开端。

## Terraform的运行机制

terraform是单文件命令行程序，它基于infrastructure as code方式来运行的，因此需要给terraform提供脚本文件让其运行。脚本文件的后缀是`.tf`，其中的内容涉及选择云服务提供商、创建何种类型的资源以及定义输入输出变量等等。

在开始运行terraform之前，需要准备以下条件:

1. 一台笔记本电脑
2. 根据操作系统下载对应的terraform可执行性文件，并把该文件所在位置添加到系统的环境变量中
3. 到AWS注册一个根账号，并用根账号创建一个子账号，这个子账号会被terraform使用
4. 将子账号生成的ID和Key提供给terraform

以上步骤准备好之后，接下来编写以下terraform脚本文件:

```terraform
# main.tf

terraform {
    required_version = ">= 0.12, < 0.13"
}

provider "aws" {
  region = "us-east-2"

  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}

resource "aws_instance" "example" {
  ami           = "ami-0d5d9d301c853a04a"
  instance_type = "t2.micro"

  tags = {
    Name = "2cloudlab-example"
  }
}
```

以上例子表明:它期望在AWS上创建一个EC2实例，因此使用terraform运行该脚本文件的最终结果是AWS EC2 Dashboard中启动了一个EC2实例。

这个简单的例子解释了terraform运行过程中所涉及的步骤。企业里也是基于以上过程来使用terraform，但是区别在于:企业内部是由多人同时编写并执行terraform文件。这就引发另外一个问题：如何协调不同人员使用terraform所完成的工作成果以及如何避免文件冲突？解决这个问题最好办法是引入工程管理方面的经验。

## 如何解决多人同时使用Terraform的问题

**CICD**的搭建需要多方团队共同参与，这就意味着Terraform工具需要多人来使用。通过以上简单的示例可知，Terraform是按照以下步骤工作的：

1. DevOps工程师编写`.tf`脚本
2. 为Terraform配置云服务账号
3. 使用Terraform执行`.tf`脚本生成基础资源

如果一切顺利，那么软件所依赖的环境会顺利生成出来，但是现实世界中，有诸多不确定的因素导致无法顺利生成环境。这些因素大部分是人为的，因此需要一套工具和规则来杜绝人为因素所引发的问题。以下清单列举了多人同时使用terraform的最佳实践:

1. 需要准备版本控制工具(git)和源码托管仓库(github)
2. 为每一名员工提供云服务商的账号，这些账号的权限随着员工角色的改变而改变
3. 共享terraform状态

接下来解释企业为何需要具备以上经验。

## 在企业中建立Devops团队以及Terraform规范

**企业需要组建一支DevOps团队来打造CICD**。在企业内部，一般是由devops工程师来使用terraform工具，编写terraform脚本，除此之外devops工程师还需要使用其它工具比如Python、Go、Bash、Packer、Git、Docker、Kubernetes来配合。除了掌握这些工具之外，还需要具备工程学方面的经验和devops方面的经验。拥有这些经验和工具是打造一条**高效CICD流水线**的基本条件。**CICD**分为2个阶段：**持续集成（CI）和持续发布（CD）**，每个阶段都有相对应的任务清单，比如：CI阶段需要解决研发、版本控制、测试等问题，而CD阶段需要解决基础资源创建、部署、配置、监控、安全、规范、优化等问题。根据企业自身情况，每个任务都能细分出更多的小任务。

面对如此多的任务，企业需要组建一个DevOps团队来专门处理这些任务。团队成员由DevOps工程师组成，每位工程师处理不同的任务，有的处理CI部分，有的处理CD部分。DevOps经常需要服务于企业内部(比如根据法规部门的要求引入隐私条款，以便符合当地法律要求)、各部门以及企业外部的客户(比如对外界发布产品)。结合之前多人同时使用terraform的经验，devops工程师便可以通过git来贡献自己的成果，但是如何确保每一次输出的成果是高质量的，那就需要通过规范来约束。这些规范的建立一般是由经验丰富的系统管理员来负责，这个管理员其实就是管理devops团队的leader。接下让我们把注意力集中在如何建立规范，以便devops的输出成果能够方便地应用于各个团队。

**建立适用于企业的DevOps规范是打造高效CICD的基础**。有了规范，DevOps团队的输出得到了保障，其他团队也可以顺利地使用DevOps团队的输出，最终确保了DevOps运动中各工作事项都得以顺利展开。规范分为2个部分：对外的规范和对内的规范。

对外的规范主要针对公司内部其他团队，其约定了外部团队如何使用DevOps团队的成果、如何向DevOps团队提出需求以及如何及时向DevOps团队反馈结果。内部团队主要分为2类:使用DevOps团队的输出成果以及间接使用DevOps团队的输出成果。前者包含的团队有:研发团队、测试团队、安全团队、网络团队等，这些团队的特征是拥有某项技术能力;后者包含的团队有:法务团队、市场团队、销售团队等，这些团队一般脱离了技术。以上所有团队都会向DevOps团队提出需求，并由DevOps团队实现，而拥有技术特征的团队会亲自使用DevOps团队的输出成果，其它团队则需要DevOps团队协助。因此需要建立一套高效的沟通机制、任务管理体系以及详细的使用说明，其中详细的使用说明格式需要统一，以便全公司都能达成共识。

对内的规范则是针对DevOps内部的成员，其约定了如何组织脚本模块、编写使用说明文档、对脚本模块进行测试、如何进行Code Review以及如何使用版本控制系统。对内的规范内容有:

1. [为每个成员分配一个独立的云服务账号](https://2cloudlab.com/portfolio/how-to-construct-enterprise-accounts/)
2. 对于生产环境的操作只能由少数成员管理
3. 使用版本控制系统来跟踪脚本文件
4. 脚本文件分成2类，一类是通用模块，另外一类是应用模块，分别由不同的repository来存放
5. 为脚本文件添加手动测试和自动化测试
6. 添加使用说明文档
7. 禁止使用除了脚本以外的其它方式操作基础设施
8. 建立code review机制
9. 为稳定的脚步文件打上版本号
10. 使用任务管理系统

接下来让我们以一个具体的例子来展开以上规范。

## 现实世界中DevOps团队一天的工作内容

假设公司成立了一个DevOps团队，由三名成员组成，他们分别是：Tony（Team Leader），Jack（DevOps Engineer）和Jane（DevOps Engineer）。他们的工作任务是为公司搭建高效的CICD，以下是他们使用Terraform的规划。

Tony作为DevOps的TeamLeader，他的主要任务是定义规范。首先，针对所有团队成员约定一套规则，并形成文档，分享给每个成员。每个成员按照这套规则进行每日的工作。下面定义了一套规则，这套规则适用大部分公司，另外公司也可以根据自己的情况来更改。

1. 任何团队成员都应该使用git以及对应托管服务来提交Terraform源码
2. Terraform的源码分为2个类，分别是通用模块和应用模块，其中通用模块可以组合使用，并由应用模块调用
3. 为每个模块编写自动化测试脚本、可执行示例和说明文档
4. 如果使用云服务商的云服务，那么应该为每名成员分配不同的云服务账号，这些账号的作用是让每个成员都能独立测试
5. 进行CodeReview
6. 为稳定的模块打上版本号，版本规则按照`MAJOR.MINOR.PATCH (例如：1.0.4)`的方式来维护
7. 定制一些具体的Terraform语法规则，以便使用者和编写者能够轻松对接
8. 定义产品运行环境（比如Dev，Test，Stage和Prod）
9. 定义自动化测试脚本的执行流程，如果使用云服务商的云服务，那么也应该单独为执行测试的机器分配一个账号
10. 选择合适的任务管理工具来进行团队的任务跟踪（比如使用jira）
11. 如果使用云服务商的云服务，制定定期清除资源的策略，以便减少成本

接下来看看他们3人是如何满足以上规则的。假设目前公司要上线一个网站服务，现在要为这个网站准备环境并将其部署，他们是这么协作的：

Tony

这个网站部署在AWS上，支持弹性伸缩、高可用、负载均衡和数据库，因此Tony将运行该网站的环境设计出来，如下图所示：

![](https://2cloudlab.com/images/blog/Web-App-Reference-Architecture.png)

紧接着，他根据上图列出一些工作任务，这些任务由在线项目协作工具(比如Jira)记录和跟踪。随后将任务按照优先级分别指派给不同的成员并开会讨论实施细节。以下是实施细节:

1. 准备3个不同的环境Test、Stage和Product来验证网站运行环境
2. 任何一名成员只能使用Terraform工具来操作以上3个环境的资源，其中Product环境只能由经验丰富的少数几个人操作
3. 团队内常用的工具有:Git、VS Code、Jira、Python、Go和Terraform
4. 依赖的服务有:AWS和Github
5. 项目的结构和文件命名方式如下(其中package_aws_web_service是通用模块，live是不同环境)
6. 在编写模块的过程中，需要考虑单元测试(Unit Test)、集成测试(Integration Test)和端对端测试（End-to-End Test），其数量占比情况如下图所示：

![](https://2cloudlab.com/images/blog/number-of-different-test-types.png)

7. 为每个模块编写手动示例和说明文档
8. 遵守Terraform规范，并用代码检测工具来做静态检查
9. 每次提交都应该进行Code Review
10. 每名成员都拥有不同的AWS账号，不同环境也需要有不同的AWS账号。AWS账号的分配原则应该根据不同目的来划分，原因在于保持相互独立性
11. 输出具有可实施的结果（包括文档、图片和代码等）。比如Tony为这次实施细节输出了如下结果：

![](https://2cloudlab.com/images/blog/file-layout-and-github-repository.png)

Tony要确保以上实施细节都能够被大家理解，并且需要不断地优化。接下来就是分工合作，Tony、Jack和Jane的分工如下：

1. Tony负责live repositoy的研发
2. Jack负责web_cluser的研发
3. Jane负责mysql_database的研发

Jack

Jack根据实施细节编写了模块`web_cluster`，结果如下：

```terraform
# main.tf

terraform {
    required_version = ">= 0.12, < 0.13"
}
```

```terraform
# variables.tf

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "security_group_id" {
  description = "The ID of the Security Group to which all the rules should be attached."
  type        = string
}
```

```terraform
# outputs.tf

output "http_port" {
  value = var.http_port
}
```

Jane

Jane根据实施细节编写了模块`mysql_database`，结果如下：

```terraform
# main.tf

terraform {
    required_version = ">= 0.12, < 0.13"
}
```

```terraform
# variables.tf

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "security_group_id" {
  description = "The ID of the Security Group to which all the rules should be attached."
  type        = string
}
```

```terraform
# outputs.tf

output "http_port" {
  value = var.http_port
}
```

## 总结

Terraform主要解决了创建资源和管理资源的问题，随着云计算的普及，Terraform的优势更加明显！

___[2cloudlab.com](https://2cloudlab.com/)为企业准备产品的运行环境，只需要1天！___