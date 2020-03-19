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

2cloudlab的模块都会包含一些自动化测试用例。每一个Terraform模块都会有对应的测试用例，这些测试用例会放在一个`test`目录下（目录结构如下所示），每一个测试用例所验证的场景是不同的。由于这些自动化测试用例都是用`Go`语言来编写的，因此需要使用`Go`语言的运行时环境来运行。除此之外，为了能够高效地编写自动化测试用例，需要引入第三方工具[Terratest](https://github.com/gruntwork-io/terratest)，该工具也是基于Go语言来编写的（[这篇文章](https://2cloudlab.com/blog/how-to-use-go-to-develop-part1.md)介绍了Go语言的基础知识），它像一把瑞士军刀，提供了大量通用的基础操作。

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

这些好处能够缩短单元测试运行的时间，使得团队能够及时得到测试报告，进而根据测试报告修复检测到的缺陷。以下例子是使用Go所编写的单元测试：

```go
package test

import (
	"fmt"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/aws/aws-sdk-go/service/iam"

	"github.com/stretchr/testify/assert"
)

//Create full_access group with admin permissions and config with MFA option
func TestIntegrationIAM2Groups(t *testing.T) {
	//1. Make this test case parallel which means it will not block other test cases
	t.Parallel()
	//2. Copy folder "../" to a tmp folder and return the tmp path of "examples"
	examplesFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples")
	iam_across_account_assistantFolder := filepath.Join(examplesFolder, "iam_across_account_assistant")

	//3. Create terraform options which is passed to terraform module
	expected_group_name := "full_access"
	expected_user_name := fmt.Sprintf("username-%s", random.UniqueId())
	user_groups := []map[string]interface{}{
		{
			"group_name": expected_group_name,
			"user_profiles": []map[string]interface{}{
				{
					//Use random.UniqueId() to make input value uniqued!
					"pgp_key":   "keybase:freshairfreshliv",
					"user_name": expected_user_name,
				},
			},
		},
	}
	terraformOptions := &terraform.Options{
		TerraformDir: iam_across_account_assistantFolder,
		Vars: map[string]interface{}{
			"should_require_mfa": true,
			"user_groups":        user_groups,
		},
		// Retry up to 3 times, with 5 seconds between retries, on known errors
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
		RetryableTerraformErrors: map[string]string{
			"RequestError: send request failed": "Throttling issue?",
		},
	}

	//4. Something like finally in try...catch
	defer terraform.Destroy(t, terraformOptions)

	//5. Something like terraform init and terraform apply
	terraform.InitAndApply(t, terraformOptions)

	//6. Validate the created group
	iamClient := aws.NewIamClient(t, "us-east-2")

	resp, err := iamClient.GetGroup(&iam.GetGroupInput {
		GroupName : &expected_group_name,
	})
	if err != nil {
		return
	}
	actual_group_name := *resp.Group.GroupName
	assert.Equal(t, expected_group_name, actual_group_name, "These 2 groups should be the same.")
	actual_user_name := *resp.Users[0].UserName
	assert.Equal(t, expected_user_name, actual_user_name, "These 2 user names should be the same.")
}
```

以上自动化测试用例测试了Terraform模块`iam_across_account_assistant`。注意代码中注释，一共分成6个部分，2cloudlab针对Terraform模块所编写的自动化测试用例都会按照以上模式。它们的作用在于：

1. `t.Parallel()`使得所有测试用例能够并发执行，这样的好处是可以缩短执行测试用例所需的整体时间
2. 会将Terraform模块拷贝到一个临时目录，这样做的好处是避免不同测试场景调用相同Terraform模块所引发的State文件冲突
3. 在Go中创建Terraform的输入参数，注意参数`MaxRetries`、`TimeBetweenRetries`和`RetryableTerraformErrors`确保了每一个测试用例如果发生了意外错误的时候，依然可以重复执行
4. 使用`defer`确保测试用例在退出的时候依然能够执行资源销毁操作
5. 在Go中调用Terraform模块，通过执行命令`terraform init`和`terraform apply`
6. 验证逻辑，这个验证逻辑因不同的Terraform模块而不同，需要借助Terratest所提供的一些函数来实现

编写完以上测试之后需要执行以下命令来运行该测试用例（其中参数`timeout`能够确保自动化测试有充足的时间执行）:

```terraform
go test -v -timeout 30m
```

输出结果如下（该测试用例花了大约204秒）：

```bash
--- PASS: TestIntegrationIAM2Groups (204.00s)
PASS
ok      module_security/test    204.031s
```

2cloudlab提供了大量的Terraform模块，这些模块都是相互独立的。为了确保这些模块的质量，2cloudlab会用Go编写大量的单元测试，因此这些单元测试都会按照以上模式来编写。当Terraform模块都能独立工作的时候，那么如何确保它们组合在一起的时候依然能够正常工作，这个时候就需要通过集成测试来保证。接下来让我们把注意力转移到如何编写和组织集成测试。

## 针对Terraform模块编写集成测试（Integration Test）

集成测试的主要目的是验证几个模块组合在一起时是否能够正常工作。使用Go来编写集成测试的时候，除了要根据单元测试的模式来编写之外，还需要结合Terratest所提供的`test_structure.RunTestStage`。接下来让我们通过一个例子来说明如何编写有效的集成测试。这个例子有2个模块，它们分别是：`mysql_database`和`web_app`，其中后者依赖前者。每个模块的职责如下：

* `mysql_database`将创建一个RDS服务，其输出的是连接信息（地址+端口），该信息将被`web_app`使用
* `web_app`将创建一个EC2服务，并且会在端口8080监听请求，并将数据库的连接信息（`mysql_database`的地址+端口）返回给用户

为了验证这2个模块能够放在一起正常工作，则需要编写以下Go代码：

```go
// web_app_intergration_test.go
const dbExampleDir = "../examples/mysql_database"
const webAppExampleDir = "../examples/web_app"

//Start up web app with real db
func TestIntegrationWebApp(t *testing.T) {
	//1. Make this test case parallel which means it will not block other test cases
	t.Parallel()
	//2. Deploy database
	defer test_structure.RunTestStage(t, "destroy_db", func() { destroyDb(t, dbExampleDir) })
	test_structure.RunTestStage(t, "deploy_db", func() { deployDb(t, dbExampleDir) })
	//3. Deploy web app
	defer test_structure.RunTestStage(t, "destroy_web_app", func() { destroyWebApp(t, webAppExampleDir) })
	test_structure.RunTestStage(t, "deploy_web_app", func() { deployWebApp(t, webAppExampleDir) })

	//4. Validate
	webAppOpts := test_structure.LoadTerraformOptions(t, webAppExampleDir)

	public_ip := terraform.OutputRequired(t, webAppOpts, "public_ip")
	listening_port := terraform.OutputRequired(t, webAppOpts, "listening_port")
	url := fmt.Sprintf("http://%s:%s", public_ip, listening_port)

	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	config := &tls.Config{}
	http_helper.HttpGetWithRetryWithCustomValidation(
		t,
		url,
		config,
		maxRetries,
		timeBetweenRetries,
		func(status int, body string) bool {
			return status == 200 &&
				strings.Contains(body,
					fmt.Sprintf("(%s,%s) with (%s,%s)", webAppOpts.Vars["db_address"], webAppOpts.Vars["db_port"], webAppOpts.Vars["db_name"], webAppOpts.Vars["db_password"]),
				)
		})
}
```

为了方便理解，以上集成测试代码只保留了主体部分，完整的代码可以到[这里](https://github.com/2cloudlab/package_aws_web_service/blob/master/test/web_app_intergration_test.go)去查阅。该集成测试主要完成了以下几个步骤：

1. 调用`t.Parallel()`使得该集成测试不会堵塞住其它自动化测试
2. 创建数据库服务
3. 获取第二步数据库连接信息，并将其用于创建WebApp服务
4. 根据第3步的WebApp返回的url+port来发送HTTP请求，并验证返回结果
5. 先销毁WebApp资源，再销毁数据库资源

运行以上集成测试所需的时间如下(大约需要14分钟)：

```bash
--- PASS: TestIntegrationWebApp (892.07s)
PASS
ok      package_aws_web_service/test    892.095s
```

正常情况下，在自动化测试的环境里，需要把每一个测试从头到尾执行一遍。但是，研发人员在本地会反复修改模块，并执行对应的自动化测试用例，如果是这样，那么这种从头开始执行测试用例并最终销毁所创建的资源的漫长过程是不合理的。正确的做法应该是这样：研发人员一开始就将集成测试所需的资源创建，并跳过销毁阶段。在随后的研发过程中，研发人员只会修改某一部分，然后重新部署该部分所对应的资源，其它未修改的部分则不需要重新部署。为了实现这种可选择执行哪些模块的部署和销毁，则需要借助Terratest所提供的`test_structure.RunTestStage`功能。使用这个功能可以划分不同阶段并可选择那个阶段是需要执行的而哪些阶段是不需要执行的。让我们接着分析以上集成测试的例子来理解这一过程。

假设研发人员开始测试WebApp服务，他/她需要输入以下命令来创建集成测试所需的资源，同时避免销毁(通过设置`SKIP_destroy_db`和`SKIP_destroy_web_app`为`true`来实现)这些资源。

```bash
SKIP_destroy_db=true \
SKIP_destroy_web_app=true \
go test -v -timeout 30m -run 'TestIntegrationWebApp'
```

该研发人员发现web_app模块的一些bug，并花了一个小时修复这些bug。他／她准备验证修复的bug，因此需要再次部署与web_app相关的资源，他／她可以通过以下命令来实现(通过`SKIP_deploy_db=true`来跳过数据库模块相关的资源创建)：

```bash
SKIP_destroy_db=true \
SKIP_destroy_web_app=true \
SKIP_deploy_db=true \
go test -v -timeout 30m -run 'TestIntegrationWebApp'
```

运行以上指令的输出结果如下所示，整个运行时间缩短为160s。

```bash
--- PASS: TestIntegrationWebApp (160.56s)
PASS
ok      package_aws_web_service/test    160.588s
```

如果该研发人员修复了这些bug，那么他/她只需要执行销毁操作，如下所示：

```bash
SKIP_deploy_db=true \
SKIP_deploy_web_app=true \
go test -v -timeout 30m -run 'TestIntegrationWebApp'
```

通过以上示例可知：集成测试所花费的时间会远远大于每个独立的单元测试所需的时间；通过机器执行集成测试应该从头到尾执行一遍，以便确保每一步都能够覆盖到；研发人员在本地进行集成测试的时候，需要选择哪些阶段可以执行而哪些阶段应该避免重复执行，以便减少集成测试的运行时间，及时得到测试反馈。

一个研发团队在编写自动化测试的时候，不仅要编写大量的单元测试来验证模块是能够单独正常工作的，而且还需要编写一部分集成测试来验证模块组合在一起也是能正常工作的。每运行一次集成测试都有可能发现新的缺陷，修复这些缺陷能够增强团队对自己的输出成果的信心，但是集成测试通过并不能说明线上的真实环境也能正常工作！为了进一步增强团队的信心，需要做进一步的End-to-End测试。

## 针对Terraform模块编写端到端的测试（End-to-End Test）

敬请期待...

## 为测试环境中的资源定制清除策略

在为Terraform模块执行自动化测试的时候，应该为其准备一个独立的测试账号，这个账号能够访问云服务商（比如AWS）。在使用测试账号执行测试用例的时候，会生成临时资源，如果这些资源没有及时销毁，那么会增加云服务使用成本，因此需要定期为测试账号销毁不用的资源。完成这个任务需要借助一些工具（比如[cloud-nuke](https://github.com/gruntwork-io/cloud-nuke)和[aws-nuke](https://github.com/rebuy-de/aws-nuke)），以及一些定期清除策略。

企业在日常研发的过程中主要涉及2类测试活动，一种是研发人员手动测试，另外一种是机器自动执行测试用例。每类测试场景，其资源的生命周期是不一样的，比如手动测试情况下，资源可能需要存在一整天，而在自动化测试场景下，只需要3个小时。因此企业可根据测试场景来定期清除资源。在实施定期清除方案时，企业可以借鉴以下经验:

1. 为自动化测试准备一个独立的账号，估算所有自动化测试执行所需要的时间，并使用cloud-nuke和crontab工具来定期清除资源

```bash
# 销毁存活超过3h的资源，常用于自动化测试账号
cloud-nuke aws --older-than 3h
```

2. 为每一名研发人员分配一个独立测试账号，这个测试账号主要用于手动测试，需要根据每一位研发人员的工作任务来确定定期清除资源所需的时间，根据该时间使用cloud-nuke和crontab工具

```bash
# 销毁存活超过1天的资源，常用于手动测试账号
cloud-nuke aws --older-than 24h
```

## 总结

本文主要介绍了如何使用Go语言编写测试Terraform模块的自动化测试用例以及在编写过程中应该注意的问题。总体而言，为了确保Terraform模块的质量，那么需要为其实施自动化测试流程。这些流程包括静态测试、单元测试、集成测试和End-2-End测试。每一类测试的侧重点是不一样的。静态测试关注Terraform模块语法上的错误，单元测试关注单个模块是否能正常工作，集成测试则是关注多个模块组合在一起的时候是否依然能正常工作，而End-2-End测试则是模拟真实的生产环境来验证功能是否正常。

企业在具体实践的过程中会发现在数量上的关系是：单元测试>集成测试>End-2-End测试。除此之外企业会采取增量发布的方式在线更新功能。在执行大量的自动化测试用例之后很有可能被会因为某些意想不到的原因导致遗留了大量临时无用的资源，此时为了降低使用这些资源的费用，那么企业需要借助一些工具以及寻求一种有效的定期清除资源的策略来降低使用资源的费用。

*[2cloudlab.com](https://2cloudlab.com/)为企业准备产品的运行环境，只需要1天！*