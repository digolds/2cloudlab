---
title: "如何正确使用2cloudlab.com的服务"
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
3. 如何构建infrastructure_modules
4. 如何构建infrastructure_live
5. 在infrastructure_modules中引用2cloudlab的Terraform模块
6. 在infrastructure_live中引用infrastructure_modules
7. 总结

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

## 2cloudlab所提供的Terraform模块

2cloudlab基于Terraform编写了可复用的模块，这些模块主要托管在github上。每个模块的格式如下所示：

```terraform
.
|____examples
| |____iam_across_account_assistant
| | |____main.tf
| | |____outputs.tf
| | |____README.md
| | |____variables.tf
|____modules
| |____iam_across_account_assistant
| | |____main.tf
| | |____outputs.tf
| | |____README.md
| | |____variables.tf
|____README.md
|____test
| |____README.md
| |____iam_across_account_assistant_test.go
```

* modules目录下包含了子功能，用户将引用这个目录下的子功能来完成环境的搭建
* examples目录下包含了如何使用modules目录下子功能的例子以及对应的说明文档
* test目录主要测试了modules目录下的子功能
* README.md文件则是一些说明文档，用户需要参考这些说明文档来使用对应的模块功能

用户在使用2cloudlab所提供的模块时，需要参考modules目录和examples目录下的内容以及对应的README.md文件。接下来的内容将围绕一个具体的示例展开。这个示例将围绕以下几个方面展开：

* 在github上创建2个repository，名称分别是infrastructure_modules和infrastructure_live
* 在infrastructure_modules中引用并组合2cloudlab所提供的模块，并打上版本
* infrastructure_live中的内容对应真实世界的环境，需要结合Terragrunt工具来生成

在使用2cloudlab所提供的Terraform模块时，需要在github上注册一个账号，并且需要将注册好的用户名提供给2cloudlab，完成之后，该用户便可以访问2cloudlab所提供的所有Terraform模块。接着用户需要在github上创建2个repository，名称分别是infrastructure_modules和infrastructure_live。

## 如何构建infrastructure_modules

**infrastructure_modules**对2cloudlab所提供的Terraform模块进行了封装。封装的好处是infrastructure_live能够复用infrastructure_modules组合好的模块。除此之外还可以为infrastructure_modules打上版本号，infrastructure_live可以自由切换不同版本的infrastructure_modules。一个比较通用的infrastructure_modules结构如下所示：

```bash
.
|____networking
| |____vpc_app
| | |____main.tf
| | |____outputs.tf
| | |____variables.tf
|____README.md
|____security
| |____cloudtrail
| | |____main.tf
| | |____outputs.tf
| | |____variables.tf
| |____iam
| | |____main.tf
| | |____outputs.tf
| | |____variables.tf
| |____organization
| | |____main.tf
| | |____outputs.tf
| | |____variables.tf
```

其中`networking`目录中主要存放网络相关的模块（比如`vpc_app`），而`security`目录中主要存放权限管理和日志模块（比如支持[多账号管理](https://2cloudlab.com/portfolio/how-to-construct-enterprise-accounts/)的`iam`模块和记录用户行为的`cloudtrail`模块）。

## 如何构建infrastructure_live

**infrastructure_live**中的内容对应真是环境的描述，所以在这个repository做任何操作的时候都需要谨慎对待。infrastructure_live中的内容主要是后缀为`.hcl`的文件，并通过Terragrunt工具来执行。使用Terragrunt工具的作用在于减少重复代码，降低复制黏贴所带来的错误。以下是一个比较实用的infrastructure_live的目录结构：

```bash
.
|____production
| |_____global
| | |____cloudtrail
| | | |____terragrunt.hcl
| | |____iam
| | | |____terragrunt.hcl
| |____terragrunt.hcl
| |____us-east-1
| | |____prod
| | | |____datastore
| | | | |____couchdb
| | | | | |____terragrunt.hcl
| | | | |____mysql
| | | | | |____terragrunt.hcl
| | | |____networking
| | | | |____load_balance
| | | | | |____terragrunt.hcl
| | | | |____vpc
| | | | | |____terragrunt.hcl
| | | |____web_app
| | | | |____web_cluster
| | | | | |____terragrunt.hcl
| |____us-east-2
|____root
| |_____global
| | |____cloudtrail
| | | |____terragrunt.hcl
| | |____iam
| | | |____terragrunt.hcl
| | |____organization
| | | |____terragrunt.hcl
| |____terragrunt.hcl
|____security
| |_____global
| | |____cloudtrail
| | | |____terragrunt.hcl
| | |____iam
| | | |____terragrunt.hcl
|____staging
| |_____global
| | |____cloudtrail
| | | |____terragrunt.hcl
| | |____iam
| | | |____terragrunt.hcl
| |____terragrunt.hcl
| |____us-east-1
| | |____stage
| | | |____datastore
| | | | |____couchdb
| | | | | |____terragrunt.hcl
| | | | |____mysql
| | | | | |____terragrunt.hcl
| | | |____networking
| | | | |____load_balance
| | | | | |____terragrunt.hcl
| | | | |____vpc
| | | | | |____terragrunt.hcl
| | | |____web_app
| | | | |____web_cluster
| | | | | |____terragrunt.hcl
| |____us-east-2
```

以上目录结构最上层分了4个账号，它们分别是`production`、`root`、`security`和`staging`，每个账号又包含`_global`和`region`（AWS服务遍布全球，因此需要划分区域来管理。如果你的业务是在北美区，那么可选择的region有`us-east-1`、`us-east-1`、`us-west-1`、`us-west-2`。）。每一个region下又可以划分不同环境（比如`stage`、`prod`和`test`）以及拥有只属于该区域的资源`_global`。每一个环境或者全局资源下面又会划分具有某种功能的模块（比如在环境stage下划分了这些模块：`datastore`、`networking`和`web_app`。如何划分模块需要结合公司的产品情况来决定。）。因此一个好的infrastructure_live目录结构应该根据如下模式来确定：

```bash
infrastructure-live
  └ <account>
    └ terragrunt.hcl
    └ _global
    └ <region>
      └ _global
      └ <environment>
        └ <resource>
          └ terragrunt.hcl
```

## 在infrastructure_modules中引用2cloudlab的Terraform模块

接下来通过一个例子来使用2cloudlab所提供的多账号创建模块：``。新建一个`security`目录，在该目录下建立`iam`目录，如下所示：

```bash
security
|____iam
| |____main.tf
| |____outputs.tf
| |____variables.tf
```

其中`main.tf`的内容如下：

```terraform
provider "aws" {
  region              = var.aws_region
  version             = "= 2.46"
  allowed_account_ids = [var.aws_account_id]
}

terraform {
  backend "s3" {}
  required_version = "= 0.12.19"
}

module "iam_across_account_assistant" {
  source = "git::git@github.com:2cloudlab.git/module_security.git//modules/iam_across_account_assistant?ref=v0.0.1"

  allow_read_only_access_from_other_account_arns = var.allow_read_only_access_from_other_account_arns
  should_require_mfa                             = var.should_require_mfa
  across_account_access_role_arns_by_group       = var.across_account_access_role_arns_by_group
  user_groups                                    = var.user_groups
}
```

以上`main.tf`主要做了3件事情：

1. 定义云服务提供商，并且指定区域和账号。

在使用Terraform模块时，需要指定这个模块用于哪些云服务提供商，这里通过`provider aws`来指定云服务提供商是AWS。除此之外还通过输入变量来决定模块应该在哪个区域，哪个账号上使用。这么做的好处是，防止在错误的AWS登陆凭证或区域之上操作另外一个账号或者区域。最后我们要指定使用AWS的版本，在现实环境中，这个版本需要具体指定，否则会引发很多难以察觉的缺陷！

2. 定义Terraform工具的版本号和存储state文件的方式.

在使用Terraform模块时，需要指定由哪个版本的Terraform工具来执行这些脚本，由于Terraform工具处于快速迭代中并无法向后兼容，因此需要指定具体的版本。除此之外，还需要指定存储state文件的策略，这里只是说明了使用S3服务（指令`backend "s3" {}`）来存储state文件，但是并没有具体的S3服务信息。这些S3服务信息是由`infrastructure_live`调用的时候提供。

3. 引用2cloudlab所提供的`iam_across_account_assistant`模块

最后，在`main.tf`文件中通过以下方式引用了2cloudlab所提供的`iam_across_account_assistant`模块：

```terraform
source = "git::git@github.com:2cloudlab.git/module_security.git//modules/iam_across_account_assistant?ref=v0.0.1"
```

这里有2点需要注意的：1）`ref=v0.0.1`指定了使用哪一个版本；2）ssh地址后面多了一个`/`符号。

最后别忘了在`variables.tf`和`outputs.tf`文件中定义输入变量和输出变量，以及通过以下git命令提交带有版本的`iam`模块：

```bash
git add security/iam
git commit -m "Add iam wrapper module"
git tag -a "v0.3.0" -m "Created iam module"
git push --follow-tags
```

接下来让我们看看：如何在infrastructure_live中引用`iam`模块。

## 在infrastructure_live中引用infrastructure_modules

infrastructure_modules只是提供Terraform模块，其本身并不会在现实世界中创建资源。而infrastructure_live则不同，它不仅要引用infrastructure_modules中的模块，而且还需要对应到现实环境中的资源，因此每次修改infrastructure_live中的内容时，都应该持有谨慎的态度。接下来让我们从之前infrastructure_live的目录结构中使用infrastructure_modules所提供的模块`iam`。

假设，你打算在AWS的root账号中创建2组：`full_access`和`billing`，那么`root/_global/iam`目录下`terragrunt.hcl`的内容应该如下所示：

```terraform
terraform {
  source = "git@github.com/<YOUR_ORG>/infrastructure-modules.git//security/iam?ref=v0.3.0"
}

inputs = {
  # Fill in your region you want to use (only used for API calls) and the ID of your root AWS account
  aws_region     = "us-east-2"
  aws_account_id = "111122223333"

  should_require_mfa = true
  user_groups = [
    {
      group_name = "billing"
      user_profiles = [
        {
          user_name = "Jim",
          pgp_key   = "keybase:jim"
        },
      ]
    },
    {
      group_name = "full_access"
      user_profiles = [
        {
          user_name = "Tony",
          pgp_key   = "keybase:tony"
        },
      ]
    }
  ]
}

include {
  path = find_in_parent_folders()
}
```

上面的代码做了3件事情：

1. 引用infrastructure_modules中的`root/_global/iam`模块，引用的版本号是`v0.3.0`,其中`<YOUR_ORG>`是注册github时的账号
2. 通过`inputs`传递参数给infrastructure_modules中的模块
3. 引入根目录中`terragrunt.hcl`里的内容

根目录中`terragrunt.hcl`里的内容如下所示：

```bash
remote_state {
  backend = "s3"
  config = {
    bucket         = "cloudlab-terraform-state-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "cloudlab-lock-table-1"
  }
}
```

根目录中`terragrunt.hcl`的内容表示：在AWS`root`账号下生成的state文件将存储到这里`cloudlab-terraform-state-bucket`，每一个模块产生的文件将包含其所在的路径名（通过`${path_relative_to_include()}/terraform.tfstate`来实现）。infrastructure_live中`root`目录的结构如下：

```bash
.
|_____global
| |____iam
| | |____terragrunt.hcl
|____terragrunt.hcl
```

完成以上步骤后，需要借助Terragrunt工具来执行以上脚本。进入`iam`目录，运行以下命令：

```bash
cd infrastructure-live/root/_global/iam
terragrunt apply
```

运行以上命令，配置正确的AWS登陆凭证（[如何高效授权登陆AWS账号](https://2cloudlab.com/blog/how-to-authority-aws-through-command-line/)），Terragrunt会执行以下步骤:

1. 将版本为`v0.3.0`的`root/_global/iam`模块从infrastructure_modules中获取到本地的一个临时目录
2. 在这个临时目录下运行`terraform init`并且将根目录下的`terragrunt.hcl`文件内容配置到Terraform工具的backend上
3. 在这个临时目录下运行`terraform apply`，同时把`inputs = { ... }`中的内容设置到Terraform的环境变量

## 总结

创建一个完整的产品运行环境需要涉及诸多内容，这些事情包括安装软件，准备数据库，准备环境，负载均衡，安全等等。如果这些事情都需要通过手动来完成，那么结果是令人沮丧的！因此2cloudlab试图通过自动化的方式来解决这些问题。*infrastructure as code*的出现让这件事情成为可能！2cloudlab通过提供大量可复用的Terraform模块，使得企业能够在一天之内创建产品运行环境。

2cloudlab的模块托管在github上，企业需要注册一个github账号，并将该账号提供给2cloudlab才能访问2cloudlab所提供的模块。使用2cloudlab所提供的模块时，最好的做法是在github上创建2个repository：`infrastructure_modules`和`infrastructure_live`，并根据前面内容来构建这2个repository。

`infrastructure_modules`主要封装了2cloudlab所提供的模块，而`infrastructure_live`则会引用`infrastructure_modules`中的模块。为了能够减少复制黏贴所引发的错误，`infrastructure_live`中的内容主要是由后缀为`.hcl`的文件组成。这些文件根据现实世界中所需要的资源而划分成不同的模块，并最终由Terragrunt工具执行。一个完整的产品运行环境是分步实现的，首先需要创建云服务账号，在不同的账号下创建不同的资源，这些资源有网络资源、数据库资源、日志资源等等。因此在`infrastructure_live`需要将不同的资源模块独立在不同的目录中，并按照定义好的依赖关系依次执行每一个模块。

*[2cloudlab.com](https://2cloudlab.com/)为企业准备产品的运行环境，只需要1天！*