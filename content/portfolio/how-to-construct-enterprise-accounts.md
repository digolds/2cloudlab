---
title: "如何构建企业级AWS账号体系"
type: portfolio
date: 2019-07-12T16:58:55+06:00
description : "当使用AWS作为基础服务为分布式软件产品提供资源时，需要做的事情太多了。有时需要查看使用AWS服务的费用、有时需要在dev环境中测试研发的功能、有时需要在stage环境中模拟prod环境的运行情况、有时需要在prod环境中上线新功能。如果研发团队里有100人都能对AWS进行各种个样的操作，那么后果是非常混乱不堪的：比如，有些成员的操作导致prod环境奔溃了、有些成员完成测试时忘记销毁资源最终导致费用变高、甚至没有察觉外来攻击者使用了企业的AWS资源等。为了杜绝这些情况发生，企业在使用AWS服务之前，需要为研发团队构建一套有效的AWS账号体系。本文将围绕如何构建企业级AWS账号体系展开，最终提供一套可实施的方案。"
caption: Conceptual Design
image: images/portfolio/item-5.jpg
category: ["AWS","云计算","Terraform","IAM"]
liveLink: https://2cloudlab.com
client: Julia Robertson
submitDate: November 20, 2017
location: 1201 park street, Avenue, Dhaka
---

当使用AWS作为基础服务为分布式软件产品提供资源时，需要做的事情太多了。有时需要查看使用AWS服务的费用、有时需要在dev环境中测试研发的功能、有时需要在stage环境中模拟prod环境的运行情况、有时需要在prod环境中上线新功能。如果研发团队里有100人都能对AWS进行各种个样的操作，那么后果是非常混乱不堪的：比如，有些成员的操作导致prod环境奔溃了、有些成员完成测试时忘记销毁资源最终导致费用变高、甚至没有察觉外来攻击者使用了企业的AWS资源等。为了杜绝这些情况发生，企业在使用AWS服务之前，需要为研发团队构建一套有效的AWS账号体系。本文将围绕如何构建企业级AWS账号体系展开，最终提供一套可实施的方案。

1. 为何构建企业级AWS账号体系
2. 构建企业级AWS账号体系的基本思想

## 为何构建企业级AWS账号体系

使用AWS服务前，我们需要到AWS官网注册一个账号。通过这个账号就可以使用AWS提供的各种服务，比如：EC2、S3、CloudWatch等。由于一个研发团队由多人组成，因此需要为每一个团队成员准备一个AWS账号。为了能够有效地管理这些账号，此时需要构建一个账号体系，这个账号体系的作用如下：

1. 隔离

使用不同的AWS账号能够将不同的环境（dev、stage、prod）独立开来，以免研发人员操作失误而导致prod环境奔溃。除此之外，隔离不同的环境能够杜绝这类事情的发生：外来攻击者登陆到了stage环境，而prod环境依然得到了保护。

2. 安全

构建有效的账户体系能够统一管理
If you configure your AWS account structure correctly, you’ll be able to manage all user accounts in one place, making it easier to enforce password policies, multi-factor authentication, key rotation, and other security requirements. Using multiple AWS accounts also makes it easier to have fine-grained control over what permissions each developer gets in each environment.

Auditing and reporting
A properly configured AWS account structure will allow you to maintain an audit trail of all the changes happening in all your environments, check if you’re adhering to compliance requirements, and detect anomalies. Moreover, you’ll be able to have consolidated billing, with all the charges for all of your AWS accounts in one place, including cost breakdowns by account, service, tag, etc.

## 构建企业级AWS账号体系的基本思想

构建AWS账号体系能够带来诸多好处，那么接下来为企业构建一个有效的AWS账号体系，如下图所示：

上图的账号体系是一步一步构建的，让我们看看每一个过程中的具体内容。

1. 创建root账号，并用root用户登陆

在root账号下分2组：admin和billing，并分别为这2组创建不同的IAM User
限制root用户的安全权限
限制每个IAM User的安全权限
使用admin组中的用户开启cloud trail服务
使用admin组中的用户创建organization服务，并创建security、dev、stage、prod和shared-service等子账号
将每个子账号中的root用户的密码重制

注：root账号和root用户是不同的概念。每个账号下可以有多个用户，包括root用户，具有相同权限的用户可以分在同一组。

2. 以root用户的方式登陆security账号

根据公司的研发团队的情况创建分组：管理组（full-access）和其它组（_account.dev-*、_account.stage-*等）
管理组具有管理security账号的权限，其它组的成员通过Role访问其它账号（dev、stage、prod、shared-service等）的资源
为每组分配对应的用户

3. 以root用户的方式登陆stage账号

只允许创建Role，不允许创建分组和用户，创建的Role需要和上述第二步所用到的Role对应起来
为创建的Role添加Trusted Entity和Policy
Trusted Entity是security账号，通过12位的ID来识别
Policy指定了Role可操作的资源

重复为dev、prod、shared-service等账号执行步骤3

4. 限制所有子账号中root用户的安全权限

5. 在security账号中，使用admin用户创建cloudtrail服务

6. 在security账号中，a)使用admin用户，b)通过role获取子账号中的登陆凭证，c)提供MFA Token，最终拿到子账号的登陆凭证创建cloudtrail服务