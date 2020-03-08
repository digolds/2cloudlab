---
title: "如何构建企业级AWS账号体系"
type: portfolio
date: 2019-07-12T16:58:55+06:00
description : "当使用AWS作为基础服务为分布式软件产品提供资源时，需要做的事情太多了。有时需要查看使用AWS服务的费用、有时需要在dev环境中测试研发的功能、有时需要在stage环境中模拟prod环境的运行情况、有时需要在prod环境中上线新功能。如果研发团队里有100人都能对AWS进行各种个样的操作，那么后果是非常混乱不堪的：比如，有些成员的操作导致prod环境奔溃了、有些成员完成测试时忘记销毁资源最终导致费用变高、甚至没有察觉外来攻击者使用了企业的AWS资源等。为了杜绝这些情况发生，企业在使用AWS服务之前，需要为研发团队构建一套有效的AWS账号体系。本文将围绕如何构建企业级AWS账号体系展开，最终提供一套可实施的方案。"
caption: 基础设施
image: images/portfolio/multi-aws-accounts.png
category: ["AWS","云计算","Terraform","IAM"]
liveLink: https://2cloudlab.com
---

当使用AWS作为基础服务为分布式软件产品提供资源时，需要做的事情太多了。有时需要查看使用AWS服务的费用、有时需要在dev环境中测试研发的功能、有时需要在stage环境中模拟prod环境的运行情况、有时需要在prod环境中上线新功能。如果研发团队里有100人都能对AWS进行各种个样的操作，那么后果是非常混乱不堪的：比如，有些成员的操作导致prod环境奔溃了、有些成员完成测试时忘记销毁资源最终导致费用变高、甚至没有察觉外来攻击者使用了企业的AWS资源等。为了杜绝这些情况发生，企业在使用AWS服务之前，需要为研发团队构建一套有效的AWS账号体系。本文将围绕如何构建企业级AWS账号体系展开，最终提供一套可实施的方案。

1. 为何构建企业级AWS账号体系
2. 构建企业级AWS账号体系的基本思想
3. 一天之内构建企业级AWS账号体系的操作指南

## 为何构建企业级AWS账号体系

使用AWS服务前，我们需要到AWS官网注册一个账号。通过这个账号就可以使用AWS提供的各种服务，比如：EC2、S3、CloudWatch等。由于一个研发团队由多人组成，因此需要为每一个团队成员准备一个AWS账号。为了能够有效地管理这些账号，此时需要构建一个账号体系，这个账号体系的作用如下：

1. 隔离

使用不同的AWS账号能够将不同的环境（dev、stage、prod）独立开来，以免任何一个环境出问题了不会影响其它环境。隔离不同的环境能够带来这些好处：外来攻击者登陆到了stage环境，而prod环境依然得到了保护；研发人员修改stage环境，prod环境的依然正常工作。

2. 安全

构建有效的账户体系能够统一管理用户。管理员能够轻松地在一个集中的地方为所有用户启动密码策略（比如密码的长度、密码组成的字符类型等）、MFA认证（比如短信或邮箱校验码通知）、定期修改密码等。除此之外，研发人员的权限控制粒度更细了。比如管理员可以方便地为研发人员赋予某个环境下某些具体的权限。

3. 记录与报告

一个有效的账户体系能够记录所有人员的操作历史。在一个有效的账户体系下，任何用户的任何操作都会留下记录，并统一存储在一个集中的地方。除此之外，如果有外来者入侵，那么他们的操作和行踪也会被记录下来，以便查明漏洞。使用AWS服务会产生费用，那么一个有效的账户体系能够集中生成各个环境的费用情况，包括每个环境的各个资源的细节，避免了漏算的情况。

以上提到的好处是建立在一个有效的账号体系下的。要想更加顺利地研发产品的前提是：建立一个有效的账号体系。接下来，让我们看看一个企业级AWS账号体系应该是怎样的。

## 构建企业级AWS账号体系的基本思想

构建AWS账号体系能够带来诸多好处，因此企业在研发初期就应该构建这种账号体系。构建一个有效的AWS账号体系的方案有很多，接下来本文将提出一个可实施并且简单的企业级AWS账号体系解决方案，其设计思路如下图所示：

![](https://2cloudlab.com/images/blog/aws-account-structure.png)

上图的账号体系是分步构建的，每一步基本上围绕Users、Groups、Role以及Policy展开。这些组件（Users、Groups、Role以及Policy）是由AWS的IAM（Identity and Access Management）服务提供的，用户可以基于IAM服务来构建安全的用户访问机制。通过手动方式来创建企业级AWS账号体系无疑是具有挑战的，这种方式不仅容易出错，而且时间漫长，因此需要一种自动化的方式来解决这些挑战。2cloudlab所提供的**across_account_assistant**模块能够帮助企业快速且正确地构建企业级AWS账号体系。接下来让我们看看每一步所涉及的具体内容。

1. 创建root账号，并用root用户登陆

在开始使用AWS服务的时候，需要使用邮箱来注册一个账号，这个账号就是上图最上面的root账号。使用root账号登陆的用户就是root用户，这个用户能够做任何事情（包括删除用户、创建各种资源、创建子账号等等）。创建root账号的作用主要有以下2方面：

* 创建其它子账号，这些子账号里的Users能够创建和使用云资源；创建组以及每组成员（full_access和billing）
* 统一管理所有子账号使用云服务而产生的费用。

因此root用户需要创建2组人员：一组是管理人员（组名为full_access），他们负责创建和管理子账号；另外一组是财务人员(组名为billing)，他们负责管理费用。创建组的同时，需要指定哪些用户属于哪个组，这些操作步骤可以通过点击AWS的UI页面完成，但是这种手动方式容易出错而且十分耗时，因此推荐使用2cloudlab所提供的[across_account_assistant]()模块来创建（最多需要一天就能建立完整的企业级AWS账号体系）。为了使billing组的用户能够访问账单相关的页面，需要root用户主动启动IAM访问账单的设置，具体设置如下（点击用户名，选择"My Account"，滑动到以下内容，将“Activate IAM Access”勾选并点击“Update”）：

![](https://2cloudlab.com/images/blog/iam-user-access-to-billing.png)

在创建组full_access和billing以及对应的成员之后，需要降低入侵root账号的风险。具体的操作方式为：为root用户开启MFA验证，其不能用于研发并需要安全放置，只允许少部分人知道，删除所有root用户相关的命令行方式登陆凭证，定期更换密码。从此之后退出root账号，转而用full_access的成员登陆并用于后续操作。

使用full_access的成员登陆AWS之后，首先要做的事情是：创建cloud trail服务（推荐使用2cloudlab所提供的模块来创建），该服务是为了跟踪所有用户使用资源的情况，以便出问题的时候可以根据这些跟踪的信息定位问题发生的原因。其次需要创建organization服务，并使用organization服务创建security、dev、stage、prod和shared-service子账号。每一个子账号都有对应的邮箱，这个邮箱所对应的用户就是该子账号下的root用户。为了登陆这些子账号，需要重制每个子账号下root用户的密码。重制完成之后，需要登陆到各个子账号完成后续的构建。

注：root账号和root用户是不同的概念。每个账号下可以有多个用户，包括root用户，具有相同权限的用户可以分在同一组。企业只有一个root账号，而且不同企业需要根据自己的实际情况创建对应的子账号，以上给出的例子适用于大多数中小型企业。对于大型企业，则需要考虑在organization服务下创建Unit，每一个Unit对应一个事业部，需要重复创建以上子账号。

2. 以root用户的方式登陆security账号

在security账号下，主要创建管理组(full_access)和其它组（across_account_dev_*、across_account_stage_*等）。管理组的主要作用在于管理security账号，只允许一部分人加入这个组；其它组的作用在于允许其成员访问其它子账号(比如dev、stage和prod)。企业应该根据实际情况来建立其它组，常见的划分依据有根据职能来划分。比如：across_account_dev_developers_access、across_account_dev_testers_access的组成员能够分别以研发和测试权限访问dev子账号。所有用户都会创建在security账号中，这种方式统一了用户管理。其它子账号则只需要建立对应的role就能够被security账号下有权限的用户访问。

security账号下的所有用户都不会在该账号下创建资源，反而会通过其它子账号中role来在其它子账号（dev、stage、prod）创建资源。建立其它组的时候需要用到其它子账号（dev、statge和prod）的role arn，因此需要在其它子账号中创建对应的role，并将role arn提供给其它组。接下来是stage账号的构建。

3. 以root用户的方式登陆stage账号

stage账号中不存在用户，只有role，这些role根据角色来确定权限（比如：可以为研发人员创建这个role：allow_dev_access_from_other_account，该role允许来自其它账号的用户在stage账号中创建一小部分资源）。其它子账号（dev和prod）也只能创建role，并通过role授权给其它账号（比如security）的用户。因此，构建dev和prod账号的过程与构建stage账号的具体过程是一致的。其中要注意的是，dev、stage、prod这些子账号是不允许创建分组和用户的。在stage子账号中创建role的过程主要分以下3步：

* 为role选择一个名字，并创建role
* 为该role指定trusted policy，该policy的作用是指定能够使用该role的其它账号（比如security账号，通过12位的ID来识别）
* 为该role指定permission policy，该policy的作用是限制这个role能够在stage账号中使用哪类资源以及对其所执行的操作

为了在其它子账号中使用stage子账号中创建的role，则需要在其它账号中授予用户权限（比如在security子账号中为across_account_dev_developers_access赋予访问allow_dev_access_from_other_account的权限，这一步通过为across_account_dev_developers_access指定inline policy完成）。

在stage账号中创建其它role的过程类似，为了一次性完成stage账号中所有role的创建，推荐使用2cloudlab所提供的[across_account_assistant]()模块来辅助。dev、prod、shared-service等账号也需要按照类似的方式创建对应的role。

当完成对所有子账号的构建之后，需要将root用户的登陆方式限制，只允许其通过网站的方式登陆子账号，并且将所有命令行登陆的凭证删除。

4. 在security账号中，使用admin用户创建cloudtrail服务

敬请期待

5. 在security账号中，a)使用admin用户，b)通过role获取子账号中的登陆凭证，c)提供MFA Token，最终拿到子账号的登陆凭证创建cloudtrail服务

敬请期待

## 一天之内构建企业级AWS账号体系的操作指南