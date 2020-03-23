---
title: "Terraform、aws-vault和Go实用技巧指南"
date: 2020-03-15T12:21:58+06:00
description : "本文记录了2cloudlab.com在使用Terraform、aws-vault和Go工具所积累的知识和经验。这些知识和经验是在解决某些问题的时候发现的，如果能够将这些知识和经验汇总，也许能够帮助到其他团队。"
type: post
image: images/blog/terraform-tactics.png
author: 郑思龙
tags: ["Terraform", "经验", "云计算"]
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

## Go实用技巧

1. 如何使用Go来运行某一个测试用例（比如定义了一个TestIntegrationOrganization测试用例）？

```go
go test -v -run TestIntegrationOrganization
```

## 组合Terraform、aws-vault和Go工具的实用技巧

1. 如何使用aws-vault和Go工具来操作AWS服务？

```go
aws-vault exec fans55 --no-session -- go test -v -run TestIntegrationOrganization
```