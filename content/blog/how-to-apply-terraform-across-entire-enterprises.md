---
title: "企业如何在一天之内部署线上服务--高效使用terraform"
date: 2019-07-15T12:29:40+06:00
description : "terraform是一个用go语言编写的跨平台、开源、只有单个运行文件的命令行程序。terraform通过解析和执行terraform configuration文件集合，最终会在短时间内生成分布式软件所运行的环境，避免了手动配置环境，减少出错的可能性。在企业里，要想高效地使用terraform来正确且快速地生成分布式软件所运行的环境，不仅需要掌握terraform知识，还需要结合软件工程方面的实践经验和借助多种工具。"
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
5. 现实世界中DevOps团队的工作内容
6. 总结

## 企业为何使用Terraform？

Terraform的主要作用在于基于云服务提供商创建资源和准备运行环境。企业内部需要借助不同工具推行[DevOps](https://2cloudlab.com/blog/devops-cicd-infrastructure-as-code/)，Terraform就是其中之一。软件产品或服务都需要运行在一个特定的环境上，因此企业需要为软件准备这些运行环境，而这些运行环境的准备就是需要工具：Terraform。除此之外还有其它工具（比如CloudFormation），企业之所以使用Terraform工具的原因在于：

1. 拥有强大而且活跃的社区支持、免费和开源
2. 支持大部分云服务提供者（AWS、Azure、GCP以及其它云服务）
3. 只需要一个terraform运行文件和云服务厂商的账号就能在自己的电脑上使用
4. terraform是基于描述型语言（declarative language）来定义资源的最终状态
5. terraform支持一致性部署（immutable infrastructure）,每次更新均是可重现且一致的

随着云计算的普及，企业应该使用云计算带来的好处--降低成本和应用更加先进的技术--来使自己处于行业领先位置。使用Terraform可以以Infrastructure as Code的方式使用云服务，DevOps人员只需要编写脚本、安装Terraform可执行文件、一个云服务商账号以及执行脚本的一台电脑就能远程为软件创建资源和准备环境。这些脚本文件由版本控制系统进行管理，这样一来软件工程方面的经验便可应用在这些脚本文件上。要想高效使用Terraform，除了要学习Terraform知识，还要解决多人使用的情况。在这之前，以一个简单的示例来了解Terraform的运行机制是一个良好的开端。

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

以上例子表明:它期望在AWS上创建一个EC2实例，因此使用terraform运行该脚本文件的最终结果是AWS EC2 Dashboard中启动了一个EC2实例,如下图所示：

![](https://2cloudlab.com/images/blog/ec2-dashboard.png)

这个简单的例子解释了terraform运行过程中所涉及的步骤。企业里也是基于以上过程来使用terraform，但是区别在于:企业内部是由多人同时编写并执行terraform文件。这就引发另外一个问题：如何协调不同人员使用terraform所完成的工作成果以及如何避免文件冲突？解决这个问题最好办法是引入软件工程管理方面的经验。

## 如何解决多人同时使用Terraform的问题

通过以上简单的示例可知，Terraform的使用过程如下：

1. 为每名研发人员配置一个云服务账号，该账号的权限应该根据这名研发人员的角色而设置
2. DevOps工程师编写`.tf`脚本，并在本地运行和测试，通过测试之后，为这些`.tf`脚本打上版本号，最终上传到版本控制系统(比如git)
3. 使用Terraform执行`.tf`脚本并在生产环境中生成基础资源
4. Terraform会生成state文件，该文件记录了生产环境中资源的最终状态。也就是说这些`.tf`脚本在现实世界中生成的资源状态与state文件中记录的状态是一一对应的

如果只有一名DevOps工程师使用Terraform工具，那么就不会存在分享`.tf`文件和state文件的问题，但是如果有多名DevOps工程师共同编写`.tf`脚本并且这些脚本是需要组合使用的，那么就需要引入一套多人协作的机制。这套机制需要解决的问题有：1.分配不同的云服务账号；2.如何对`.tf`文件进行版本管理；3.共享state文件。

1. 分配不同的云服务账号

为不同研发人员分配不同云服务账号的原因在于：同一管理所有研发人员，减少研发人员因权限的问题破坏生产环境或者其它重要的环境。在云计算的世界里，有太多的因素需要考虑，其中安全因素尤其重要。如果没有合理地分配云服务账号，那么就无法有效地追踪每一名研发人员的操作记录。如果外来入侵者登录了你的云服务账号，那么这些混乱的操作记录将难以提供入侵者的行踪，从而管理人员将无法及时修复安全漏洞。因此在使用云服务之前，需要建立起多账号方案，[这篇文章](https://2cloudlab.com/portfolio/how-to-construct-enterprise-accounts/)介绍了一种企业级多账号管理方案，通过实践这个方案将方便企业管理多人同时使用云服务进行研发的问题。

2. 如何对`.tf`文件进行版本管理

软件产品在每一个阶段都有其对应的功能，这些功能是通过每一次的迭代而添加的。要想在旧功能的基础上添加新的功能就需要引入版本控制系统。DevOps工程师会划分模块来编写`.tf`脚本，这些脚本每隔一段时间会引入新的功能或者修复漏洞，那么就需要类似于git一样的工具来记录每一次改动。除此之外，为了不影响外部使用这些模块，那么需要为这些模块打上版本号，使用者根据版本号来使用这些模块，编写这些模块的工程师则可以大胆更新模块。有了记录和版本的模块，接下来就是要发布给外部使用者，通过源码托管服务（比如github），这些模块能够方便地被其他人使用。引入源码托管服务也能够方便Code Review。

3. 使用S3和DynamoDB服务存储与共享Terraform状态

运行Terraform之后，将会生成一个state文件，这个文件记录了现实世界云服务资源的最终状态。没有这个state文件，那么terraform将认为云服务资源没有创建出来。因此如果这个state文件生成在本地，那么将引发一个问题：2名DevOps工程师执行同一个`.tf`脚本。工程师A生成了云计算资源R，紧接着工程师B再次运行该脚本，Terraform提示工程师B资源R将被创建。这个问题引发的原因在于工程师B没法获取工程师A的state文件，从而导致Terraform误认为资源R没有被创建出来（实际已经被工程师A创建了）。因此需要通过将state文件共享才能解决这个问题。

共享的方法有很多种，其中一种是利用AWS S3和DynamoDb服务来实现共享。这种方法的好处是容易实现而且方便加密。使用AWS服务来实现state文件共享的第一步是：在AWS上创建S3对象存储和DynamoDb Key-Value存储（它们的名称分别是：terraform-remote-state-storage-s3和terraform-state-lock-dynamo）。接下来只要在`.tf`文件中配置以下信息就能实现state文件共享。

```terraform
# main.tf
terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "terraform-remote-state-storage-s3"
    dynamodb_table = "terraform-state-lock-dynamo"
    region         = "us-west-2"
    key            = "path/to/state/file"
  }
}
```

通过以上配置，每次运行`terraform apply`都会先执行加锁操作（作用到terraform-state-lock-dynamo）；接着生成state文件，并将其存储到指定的S3对象存储（由terraform-remote-state-storage-s3指定），S3自动对state文件加密；最后再执行解锁操作（作用到terraform-state-lock-dynamo）。解锁和加锁的作用在于保证存储state文件时只有一个人在操作。

## 在企业中建立Devops团队以及Terraform规范

**企业需要组建一支DevOps团队来打造CICD**。在企业内部，一般是由devops工程师来使用terraform工具，编写terraform脚本，除此之外devops工程师还需要使用其它工具比如Python、Go、Bash、Packer、Git、Docker、Kubernetes来配合。除了掌握这些工具之外，还需要具备软件工程方面的经验和devops方面的经验。拥有这些经验和工具是打造一条**高效CICD流水线**的基本条件。**CICD**分为2个阶段：**持续集成（CI）和持续发布（CD）**，每个阶段都有相对应的任务清单，比如：CI阶段需要解决研发、版本控制、测试等问题，而CD阶段需要解决基础资源创建、部署、配置、监控、安全、规范、优化等问题。根据企业自身情况，每个任务都能细分出更多的小任务。

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

## 现实世界中DevOps团队的工作内容

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

当任务分配到每位成员之后，Tony要做的是准备2个repository，分别为:live和package_aws_web_service，它们托管在github上，目录结构按照以上方式排布。除此之外，[live](https://github.com/2cloudlab/live)中的文件会调用package_aws_web_service中的模块，这种可复用的方式不仅适合内部团队，也适用于其它团队，比如测试和研发团队。

Jack

Jack根据实施细节编写了模块`web_cluster`([完整源码](https://github.com/2cloudlab/package_aws_web_service))，结果如下：

```terraform
# main.tf

module "asg" {
  source = "../../cluster/asg-rolling-deploy"

  cluster_name  = "hello-world-${var.environment}"
  ami           = var.ami
  user_data     = data.template_file.user_data.rendered
  instance_type = var.instance_type

  min_size           = var.min_size
  max_size           = var.max_size
  enable_autoscaling = var.enable_autoscaling

  subnet_ids        = local.subnet_ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"
  
  custom_tags = var.custom_tags
}

module "alb" {
  source = "../../networking/alb"

  alb_name   = "hello-world-${var.environment}"
  subnet_ids = local.subnet_ids
}
```

```terraform
# variables.tf

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "environment" {
  description = "The name of the environment we're deploying to"
  type        = string
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "ami" {
  description = "The AMI to run in the cluster"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}
```

```terraform
# outputs.tf

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "The domain name of the load balancer"
}
```

jack编写了一个通用模块：`web_cluster`（为了阅读方便省去了细节部分），其他团队可以调用这一模块。这个模块的作用是生成Load Balance和一族EC2实例（如下图所示）。这个模块像一个函数一样有输入参数和输出参数。`variables.tf`文件中定义了该模块的输入参数，它们分别是：`environment`、`min_size`和`max_size`。`outputs.tf`文件中定义了该模块的输出参数：`alb_dns_name`。`main.tf`文件中定义了具体的逻辑部分：`alb`和`asg`。也就是说使用模块`web_cluster`之后，会生成一个域名地址，用户可以通过该域名地址，访问网站服务。

![](https://2cloudlab.com/images/blog/only-web-cluster.png)

Jane

Jane根据实施细节编写了模块`mysql_database`([完整源码](https://github.com/2cloudlab/package_aws_web_service))，结果如下：

```terraform
# main.tf

resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-up-and-running"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  name                = var.db_name
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true
}
```

```terraform
# variables.tf

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "db_name" {
  description = "The name to use for the database"
  type        = string
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
}
```

```terraform
# outputs.tf

output "address" {
  value       = aws_db_instance.example.address
  description = "Connect to the database at this endpoint"
}

output "port" {
  value       = aws_db_instance.example.port
  description = "The port the database is listening on"
}
```

像Jack一样，Jane编写了一个通用模块：`mysql_database`（为了阅读方便省去了细节部分），其他团队可以调用这一模块。Jane和Jack根据规范，编写了统一格式的模块。格式统一的模块能够减少团队之间的障碍，促进工作顺利进行下去。调用Jane编写的模块会生成一个由AWS完全托管的MySQL数据库服务（如下图所示）。DevOps中的团队成员各司其职，都输出了相对独立的模块，因此，需要Tony将Jane和Jack的成果集成在一起才能部署网站应用并对外发布。

![](https://2cloudlab.com/images/blog/only-mysql-database.png)

## 总结

Terraform工具主要解决了创建资源和管理资源的问题，随着云计算的普及以及Terraform支持大多数云服务商，包括AWS、GCP、Azure Cloud和阿里云等，使得Terraform工具的使用场景更加丰富！使用Terraform工具的好处是：以统一的方式创建和管理资源，并引入了软件工程管理经验。DevOps工程师只需要编写脚本文件并使用Terraform执行它们，就可以创建和管理基础资源，这些资源构成了产品或服务所需的运行环境。将资源代码化(也就是Infrastructure as code)的好处是可以引入软件工程管理实践经验来更好地发布软件。这些经验包括版本控制、自动化测试、模块复用、Code Review和编写文档等。

为了帮助企业打造世界级CICD，除了需要熟练掌握Terraform知识以外，还需要结合软件工程实践经验。因此，企业需要专门成立一个DevOps团队来服务于企业内部不同团队以及对外发布产品。当引入一个团队的时候，就需要考虑多人协作和规范的问题。使用Terraform工具所生成的真实环境有各种各样的依赖关系，任何一次局部修改，都有可能导致整个运行环境瘫痪，因此要严格隔离不同环境，比如使test、stage和prod环境相互独立，使每一位研发人员都拥有独立的云服务账号。除此之外DevOps要定义一些规范，这些规范不仅能够使团队内部达成共识，而且能够更加有效地使外部团队消化DevOps的输出成果，最终使得DevOps运动能够在企业内部顺利运转起来。

在企业中实施DevOps是一个漫长的过程，这个过程涉及了多方面的内容。千里之行始于足下，建立统一的[用户管理体系](https://2cloudlab.com/portfolio/how-to-construct-enterprise-accounts/)是打造世界级DevOps的良好开端。[<让产品7*24小时持续服务用户--如何测试Terraform>](https://2cloudlab.com/blog/how-to-test-terraform-code/)能够确保Terraform脚本的质量，进而能够克服实施DevOps时所遇到的困难。

本文介绍了企业内部如何高效使用Terraform工具，在企业内部使用Terraform工具的时候，严格执行以下几点原则能够帮助企业更加顺利地实施DevOps：

* 给予研发人员充足的时间学习Terraform工具，尤其是掌握其中的Infrastructure as Code
* 结合公司现实状况，独立所有运行环境、独立所有研发人员使用的账号。独立的好处是可以多人同时负责不同的模块，以及任何使某个环境瘫痪的操作不会影响到另外一个环境
* 如果条件允许，在公司内部建立DevOps团队，建立DevOps团队的工作标准和工作流程，否则将DevOps的业务委托给专业的公司（比如[2cloudlab.com](https://2cloudlab.com/)）

看到这里，你会发现搭建世界级DevOps所需要的东西太多，有时甚至会不知所措。如果你正在为企业搭建DevOps但是不知如何前进，那么不妨以文章[<如何构建企业级AWS账号体系>](https://2cloudlab.com/portfolio/how-to-construct-enterprise-accounts/)开启企业级DevOps之旅！

___[2cloudlab.com](https://2cloudlab.com/)为企业准备产品的运行环境，只需要1天！___