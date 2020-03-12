---
title: "如何快速使用2cloudlab.com的服务"
date: 2019-10-15T12:21:58+06:00
description : "企业在为软件产品提供运行环境时需要做的事情太多了。这些事情有安装软件、配置软件、创建服务器、准备数据库、监控等等。如果每一件事情都需要手动去完成，那么效率是低下的，而且容易出错！在2cloudlab，我们试图通过自动化的方式处理以上事情。因此2cloudlab提供了各种可重复使用的模块，通过组合这些模块以及依赖计算机执行这些模块来加速产品运行环境的生成！2cloudlab致力于让企业在一天之内创建完整的软件运行环境。"
type: post
image: images/blog/how-to-use-2cloudlab.jpg
author: 郑思龙
tags: ["2cloudlab.com", "devops"]
---

企业在为软件产品提供运行环境时需要做的事情太多了。这些事情有安装软件、配置软件、创建服务器、准备数据库、监控等等。如果每一件事情都需要手动去完成，那么效率是低下的，而且容易出错！在2cloudlab，我们试图通过自动化的方式处理以上事情。因此2cloudlab提供了各种可重复使用的模块，通过组合这些模块以及依赖计算机执行这些模块来加速产品运行环境的生成！2cloudlab致力于让企业在一天之内创建完整的软件运行环境。

1. 创建一个完整的产品运行环境的任务列表
2. 如何使用2cloudlab所提供的Terraform模块

## 创建一个完整的产品运行环境所需的任务列表

创建一个完整的产品运行环境需要考虑的事情太多了，这些事情有：

* 安装：安装产品以及其依赖项（比如准备操作系统）
* 配置：为软件提供配置信息，这些信息有端口设置、数据库密码等
* 创建资源：为软件创建运行环境，这些环境由计算资源、存储资源以及其它资源构成
* 部署：将软件部署到运行环境，在线更新功能等
* 高可用性：考虑在多个区域启动相同服务，确保任何一个区域停止工作时，其它区域依然能够提供服务
* 可扩展：支持横向扩展（增加或减少资源来应对高峰期或低峰期）和纵向扩展（增强资源）
* 性能：优化产品运行环境的性能，包括CPU、GPU和内存
* 网络：配置IP、端口、VPN、SSH
* 安全：增加数据安全（包括传输和存储安全）、网络安全
* 指标监控：收集有价值的数据，通过KPI的方式呈现出来
* 日志监控：收集用户日志以及产品运行环境日志
* 备份和恢复：支持数据备份和恢复，支持运行环境快速恢复
* 成本优化：降低产品运行环境的使用成本
* 文档：为产品代码编写文档，为产品编写说明书
* 测试：编写测试用例、自动化测试、集成测试和产品测试

为产品准备运行环境都会遇到以上问题，企业需要根据实际情况来选择哪些事项是需要实施的，哪些事项当下是不需要实现的。以上事项如果都使用手动的方式来实现，那么结果将会是令人失望的。2cloudlab针对这些事项实现了一个个可复用的模块，用户只需要组合并使用这些模块就能轻松地创建出开箱即用的解决方案。2cloudlab所提供的模块经过大量的测试，并可以帮助企业在一天之内完成环境的准备。接下来让我们看看如何使用2cloudlab所提供的模块。

## 如何使用2cloudlab所提供的Terraform模块

2cloudlab基于Terraform编写了可复用的模块，这些模块主要托管在github上。每个模块的格式如下所示：

```terraform
.
|____examples
| |____cloudtrail
| | |____main.tf
| | |____outputs.tf
| | |____README.md
| | |____variables.tf
| |____iam_groups
| | |____main.tf
| | |____outputs.tf
| | |____README.md
| | |____variables.tf
| |____iam_policies
| | |____main.tf
| | |____outputs.tf
| | |____README.md
| | |____variables.tf
|____modules
| |____cloudtrail
| | |____main.tf
| | |____outputs.tf
| | |____README.md
| | |____variables.tf
| |____iam_across_account_assistant
| | |____main.tf
| | |____outputs.tf
| | |____README.md
| | |____variables.tf
| |____iam_groups
| | |____main.tf
| | |____outputs.tf
| | |____README.md
| | |____variables.tf
| |____iam_policies
| | |____aws_managed_policies.tf
| | |____custom_managed_policies.tf
| | |____main.tf
| | |____mfa_base_policies.tf
| | |____outputs.tf
| | |____README.md
| | |____variables.tf
| |____iam_roles
| | |____main.tf
| | |____outputs.tf
| | |____README.md
| | |____variables.tf
|____README.md
|____test
| |____dep-install.sh
| |____README.md
| |____web-cluseter_test.go
```


* modules目录下包含了子功能，用户将引用这个目录下的子功能来完成环境的搭建
* examples目录下包含了如何使用modules目录下子功能的例子以及对应的说明文档
* test目录主要测试了modules目录下的子功能
* README.md文件则是一些说明文档，用户需要参考这些说明文档来使用对应的模块功能

用户在使用2cloudlab所提供的模块时，需要参考的内容有modules目录、examples目录和README.md文件。