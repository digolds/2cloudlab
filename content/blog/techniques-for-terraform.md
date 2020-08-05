---
title: "Terraform、aws-vault和Go实用技巧指南"
date: 2020-03-15T12:21:58+06:00
description : "本文记录了2cloudlab.com在使用Terraform、aws-vault和Go工具所积累的知识和经验。这些知识和经验是在解决某些问题的时候发现的，如果能够将这些知识和经验汇总，也许能够帮助到其他团队。"
type: post
image: images/blog/terraform-tactics.png
author: 郑思龙
tags: ["Terraform", "自动化经验", "云计算", "Go"]
---

1. Terraform实用技巧
2. aws-vault实用技巧
3. Go实用技巧
4. 组合Terraform、aws-vault和Go工具的实用技巧

本文记录了2cloudlab.com在使用Terraform、aws-vault和Go工具所积累的知识和经验。这些知识和经验是在解决某些问题的时候发现的，如果能够将这些知识和经验汇总，也许能够帮助到其他团队。

## Terraform实用技巧

1. *aws_launch_configuration*资源是无法通过API来修改的

一个*aws_launch_configuration*实例创建之后，要想修改该实例的属性，则需要重新创建一个新的*aws_launch_configuration*实例，原因在于*aws_launch_configuration*类型的实例是无法通过AWS所提供的API来修改的。

2. Terraform所提供的所有类别的资源都有一个*lifecycle*的设置

Terraform工具通过这个设置来决定创建资源的行为。比如以下代码通过设置`create_before_destroy = true`，最终能够使得Terraform先创建一个*aws_launch_configuration*新的实例，再将新实例替换掉旧实例，替换成功后再销毁旧实例。*lifecycle*中的设置只能是常量，因此这种方式：`create_before_destroy = var.flag`来设置*create_before_destroy*是不允许的。

```terraform
resource "aws_launch_configuration" "launch_configuration_instance" {
  image_id        = "ami-0fc20dd1da406780b" #ubuntu 18.4
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, 2cloudlab.com" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  # Required when using a launch configuration with an auto scaling group.
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  lifecycle {
    create_before_destroy = true
  }
}
```

3. Terraform提供`for_each`指令来遍历一个`map`对象，并根据该对象的键值对`each.key`和`each.value`来创建资源

```terraform
locals {
  buckets = {
    bucket1 = "2cloudlab-your-unique-bucket-name-1"
    bucket2 = "2cloudlab-your-unique-bucket-name-2"
  }
}

resource "aws_s3_bucket" "b" {
  for_each     = local.buckets
  bucket = each.value
}

output "results" {
  value = aws_s3_bucket.b
}
```

以上命令将生成2个S3资源，名字分别是`2cloudlab-your-unique-bucket-name-1`和`2cloudlab-your-unique-bucket-name-2`，运行结果如下所示（为了方便显示和阅读，我已经将无关紧要的信息剔除）：

```bash
results = {
  "bucket1" = {
    "bucket" = "2cloudlab-your-unique-bucket-name-1"
  }
  "bucket2" = {
    "bucket" = "2cloudlab-your-unique-bucket-name-2"
  }
}
```

4. 如何在Terraform中将数组转化成字典

```bash
my_map = {
    for i in range(1, 11, 2):
    format("%d", i) => format("%s-%d", "prefix", i)
  }
```

`range(1, 11, 2)`将生成数组[1,3,5,7,9]，运行以上指令将得到以下结果：

```bash
{
  "1" = "prefix-1"
  "3" = "prefix-3"
  "5" = "prefix-5"
  "7" = "prefix-7"
  "9" = "prefix-9"
}
```

## Go实用技巧

1. 如何使用Go来运行某一个测试用例（比如定义了一个TestIntegrationOrganization测试用例）？

```go
go test -v -run TestIntegrationOrganization
```

2. 如何根据tag(`+build integration`)来执行一组测试用例？

```go
// intergration_test.go
// +build integration

func TestCase1(t *testing.T) {
    // ...
}

func TestCase2(t *testing.T) {
    // ...
}
```

在文件*intergration_test.go*中指定tag：`// +build integration`，运行以下命令将执行该文件中的所有自动化测试用例。

```bash
go test -v -run -tags=integration
```

3. Go Concurrency

```go
for {
  select {
    case <-done:
    default:
        //
  }
}
```

## 组合Terraform、aws-vault和Go工具的实用技巧

1. 如何使用aws-vault和Go工具来操作AWS服务？

```go
aws-vault exec fans55 --no-session -- go test -v -run TestIntegrationOrganization
```