---
title: "如何通过命令行访问AWS服务-最佳实践"
date: 2020-03-15T12:21:58+06:00
description : "使用命令行操作AWS服务之前，需要输入登陆凭证。每一个研发人员会经常使用不同账号的登陆凭证来完成他们的工作，比如在测试账号中进行测试工作，在stage账号中部署测试通过的功能等。在现实的工作中，每个研发人员每天平均会操作AWS服务20～50次，而每次都需要给AWS提供登陆凭证。因此为了提高一个团队的研发效率，需要寻求一个能够高效访问AWS服务的方法。本文将对比几种方法，并最终给出一个更加有效的方法来访问AWS。"
type: post
image: images/blog/command-line-aws-authorities.png
author: 郑思龙
tags: ["AWS", "命令行", "授权访问"]
---

使用命令行操作AWS服务之前，需要输入登陆凭证。每一个研发人员会经常使用不同账号的登陆凭证来完成他们的工作，比如在测试账号中进行测试工作，在stage账号中部署测试通过的功能等。在现实的工作中，每个研发人员每天平均会操作AWS服务20～50次，而每次都需要给AWS提供登陆凭证。因此为了提高一个团队的研发效率，需要采用一个能够高效访问AWS服务的方法。本文将对比几种方法，并最终给出一个更加有效的方法来访问AWS。

本文将基于以下几种方法来说明如何在类Unix系统上配置和使用登陆凭证：

1. 将登陆凭证写入配置文件`~/.aws/credentials`
2. 将登陆凭证写入环境变量`AWS_ACCESS_KEY_ID` 和 `AWS_SECRET_ACCESS_KEY`
3. 借助工具aws-valut来设置登陆凭证
4. 总结

## 将登陆凭证写入配置文件`~/.aws/credentials`

通过命令行访问AWS服务之前，你需要获得一对登陆凭证，它们的格式如下：

```bash
aws_access_key_id=AKIAIOSFODNN7EXAMPLE
aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

将以上登陆凭证写入`~/.aws/credentials`文件中就可以轻松访问AWS服务（内容如下所示）。这种方式的最大问题是不安全，因为该登陆凭证是以明文的方式存放，而且容易被别人获取。

```bash
[default]
aws_access_key_id=AKIAIOSFODNN7EXAMPLE
aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

既然将登陆凭证存放在磁盘上是不合适的，那么可以通过设置环境变量的方式来解决这类安全问题。

## 将登陆凭证写入环境变量`AWS_ACCESS_KEY_ID` 和 `AWS_SECRET_ACCESS_KEY`

为了不存储登陆凭证，则可以通过写入环境变量的方式来访问AWS服务，如下所示（注意*export*前的空格）：

```bash
echo "Note a space before export command, it will not store used commands in commands history."
 export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
 export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

以上方式只能在当前运行这些命令的命令行中访问AWS服务，如果该命令行关闭，那么这些环境变量需要重新设置。因此这种方式解决了安全的问题，但是确变得麻烦了。比如我需要打开2个命令行窗口来访问不同的AWS账号。

要想高效访问AWS服务，则应该同时解决以上2个问题。幸运的是，我们可以使用工具：aws-vault来协助我们更好地访问AWS服务。

## 借助工具aws-valut来设置登陆凭证

aws-valut是一个管理登陆凭证的命令行工具（[这篇文章](https://2cloudlab.com/blog/how-to-authority-aws-through-command-line/)进一步介绍了该工具）。这个工具通过以下方式解决了访问AWS时所遇到问题：

1. 加密存储登陆凭证
2. 一个命令行同时处理多个登陆凭证
3. 支持所有访问AWS的命令行工具

在使用aws-vault之前，需要设置登陆凭证，比如设置以下2个不同账号的登陆凭证：

```bash
aws-vault add slz
aws-vault add slz_mfa
```

比如以下命令使用了`slz`所对应的凭证并运行`aws`命令行工具

```bash
aws-vault exec slz -- aws iam list-users
```

以下命令使用了`slz_mfa`所对应的凭证并运行`terraform`工具

```bash
aws-vault exec slz_mfa -- terraform plan
```

`slz`和`slz_mfa`所对应的凭证均以密文的方式存储在磁盘上。通过以上对比，读者应该首先考虑使用aws-vault来访问AWS服务，并考虑在命令行之前加入一个空格来避免命令被记录在历史之中，比如以下示例：

```bash
 aws-vault exec slz_mfa -- terraform plan
```

基于aws-vault方式，我们可以进一步简化以role和MFA的方式来访问AWS服务，具体操作步骤可以查看这篇文章[<提高研发团队使用AWS服务的效率X100--高效使用AWS-VAULT工具>](https://2cloudlab.com/blog/how-to-authority-aws-through-command-line/)。


## 总结

高效访问AWS服务是提高研发效率的一个环节。在团队中应用以上提到的aws-vault工具将释放团队的生产力！除此之外，团队中的每一个成员都应该将其所涉及的登陆凭证添加到aws-vault工具中。这些登陆凭证有来自不同账号的，也有来自同一个账号但不同的role的，还有些涉及了MFA。因此团队中每一个成员的所有登陆凭证都应该容易区分，比如以下例子：

```bash
aws-vault add slz_<account A>_without_mfa
aws-vault add slz_<account A>_with_mfa
aws-vault add slz_<account B>_without_mfa_dev_role
aws-vault add slz_<account C>_without_mfa_read_only_role
```

*[2cloudlab.com](https://2cloudlab.com/)为企业准备产品的运行环境，只需要1天！*