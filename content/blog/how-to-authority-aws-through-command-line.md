---
title: "提高研发团队使用AWS服务的效率x100--高效使用aws-vault工具"
date: 2020-03-10T12:29:40+06:00
description : "在DevOps的世界里有太多工具需要掌握，命令行工具就是其中之一。企业在打造DevOps的过程中会经常使用命令行工具访问AWS服务。一名研发人员每天可能要在命令行里反复（平均50次）输入登录AWS的凭证才能创建资源，如果为每一名账号引入安全机制，那么这个登录流程耗时更长！为了减轻这种重复登录所带来的痛苦，则需要一个更加友好的命令行工具来辅助，这个工具就是：aws-vault。"
type: post
image: images/blog/command-line.png
author: 郑思龙
tags: ["aws-vault工具", "研发效率提升", "devops", "cicd", "云计算" , "cloudcomputing"]
---

在DevOps的世界里有太多工具需要掌握，命令行工具就是其中之一。企业在打造DevOps的过程中会经常使用命令行工具访问AWS服务。一名研发人员每天可能要在命令行里反复（平均50次）输入登录AWS的凭证才能创建资源，如果为每一名账号引入安全机制，那么这个登录流程耗时更长！为了减轻这种重复登录所带来的痛苦，则需要一个更加友好的命令行工具来辅助，这个工具就是：aws-vault。

1. 什么是aws-vault工具
2. aws-vault工具的使用指南
3. 总结

## 什么是aws-vault工具

aws-vault是一个命令行工具，这个工具的主要作用在于帮助研发人员以命令行的方式快速访问AWS服务，最终减轻了每一名研发人员因反复登录而带来的负担，从而提高企业整体的研发效率。

aws-vault是一款用go语言编写且开源的命令行工具，其项目地址在[这里](https://github.com/99designs/aws-vault)。aws-vault主要解决安全和自动设置凭证的问题。

初次运行aws-vault时，只需要在命令行里输入如下指令：

```terraform
aws-vault add slz
```

根据提示输入`AWS_ACCESS_KEY_ID`和`AWS_SECRET_ACCESS_KEY`信息。如果这个凭证具有操作AWS资源的权限，那么研发人员就能通过aws-vault工具高效访问AWS服务。此外，这2个登录信息是以密文的形式存储的，因此aws-vault进一步保护了登录凭证。如果该用户需要使用MFA，那么只需要在文件`~/.aws/config`加入以下内容：

```terraform
# config文件
[profile slz]
mfa_serial = arn:aws:iam::120699691161:mfa/Tony
```

aws-vault工具会自动到这个文件中读取该MFA地址，并提示研发人员键入6位安全码。如果研发人员需要用到AWs所提供的role，那么也可以按照类似的方式在该文件中添加以下内容：

```terraform
# config文件
[profile slz]
role_arn = arn:aws:iam::120699691161:role/update_role
```

aws-vault工具会自动读取这个role，并自动获取该role所拥有的权限来访问AWS服务。

设置好以上登录凭证之后，研发人员只需要执行以下命令就能自动访问AWS资源:

```terraform
aws-vault exec slz -- aws iam list-users
```

以上命令分两部分：`aws-vault exec slz`和`aws iam list-users`。前者会根据slz去找到对应的登录凭证，并自动设置好登录凭证，后者则是使用aws命令行工具列出所有用户信息。后半部分可以是支持AWS凭证登录的任何工具(比如：Terraform工具）。如下例子将`aws-vault`工具和`terraform`工具结合在一起使用：

```terraform
aws-vault exec slz -- terraform apply
```
## aws-vault工具的使用例子

完成以上配置之后，接下来看看`aws-vault`工具如何结合`terraform`工具使用的。

假设我们使用aws-vault添加了以下具有相同登录凭证，但是不同登录方式的登录选择：

* slz：直接通过登录凭证操作AWS服务
* slz_mfa：除了需要登录凭证，还需要输入6位安全码才能操作AWS服务
* slz_mfa_role：获取临时登录凭证，并以role的方式访问AWS服务

以下命令说明了如何使用`aws-vault`工具和`terraform plan`命令生成资源创建的详细信息

```terraform
aws-vault exec slz -- terraform plan
```

```terraform
aws-vault exec slz_mfa -- terraform plan
```

```terraform
aws-vault exec slz_mfa_role -- terraform plan
```

第一种命令直接通过登录凭证使terraform能够访问AWS服务；第二种命令以第一种类似，但是在执行访问AWS服务之前需要输入6位安全码；第三种的登录凭证使临时生成的，所拥有的权限由role来确定，这个role有可能是其它账号的。

通过以上命令，研发人员可以快速切换登录场景，并且只需要一行命令就能操作AWS服务。因此对于拥有上百人的研发团队而言，这种便捷能够以100x的系数来提高团队的工作效率！

## 总结

研发团队每天都会用到各种工具，登录各种系统。如果这些重复而且没有价值的任务没有得到有效解决，那么后果自然是会影响团队的研发效率！本文提到的aws-vault工具适用于需要命令行操作AWS服务的各种工具，这些工具有：aws、terraform等。aws-vault工具能够安全存储登录凭证，而且根据配置自动设置登录凭证，从而减少了研发人员反复设置登录凭证的步骤。如果你所在的企业或团队依然被登录AWS服务的过程困扰，那么实践本文所提到的aws-vault工具以及例子将会帮助你扫清这个障碍。

___[2cloudlab.com](https://2cloudlab.com/)为企业准备产品的运行环境，只需要1天！___