---
title: "设计数据应用的最佳实践"
type: portfolio
date: 2018-07-12T16:54:54+06:00
description : "This is meta description"
caption: NoSQL, Data, Large Scale
image: images/portfolio/data-intensive-best-practices.png
category: ["mockup","design"]
liveLink: https://www.themefisher.com
client: Julia Robertson
submitDate: November 20, 2017
location: 1201 park street, Avenue, Dhaka
---

# [如何在一天之内搭建大规模存储系统-NoSQL](https://2cloudlab.com/portfolio/how-to-craft-a-nosql-storage-system-in-one-day-dynamodb-large-scale-cloud-computing/)

这篇指南将通过以下4步来帮助你**在一天之内搭建大规模存储系统-NoSQL**：

* 开箱即用的云原生解决方案
* 现实情况
* 准备和实现
* 具体案例
* 存在的问题

## 开箱即用的云原生解决方案

[module\_dynamodb](https://github.com/2cloudlab/module_dynamodb)模块用于创建DynamoDB存储系统，它是NoSQL数据库，非常**适合大规模数据存取**，即便是数据量大规模增长了，它依然能提供10毫秒(ms)以内的数据存取性能。在使用它之前，你需要参考[这里来准备研发环境和了解一些注意事项](https://www.digolds.cn/article/001605969144845d618aa67ad2f4f5a890c0a43d5aa5f71000)。这个解决方案能够帮助你创建一个NoSQL存取系统，你只需要提供表的主键或排序键以及创建索引即可。关于DynamoDB的使用，你可以[参考这里](https://www.digolds.cn/article/001572926018754ebaf8e3696284bab9e5e2c940396c424000)，在那里，你可以看到如何使用DynamoDB来高效存取层级数据，除此之外，你还能看到Amazon是如何使用它来存取购物车信息的，实际上它需要一系列的教程来介绍它。这套开箱即用的解决方案能够帮助你快速地创建DynamoDB存储系统，它可以集成到其它服务，如下图最右边的部分所示：

![](https://2cloudlab.com/images/blog/load-balance-nosql-cloud-computing-WSGI-python-gunicorn-supervisior-nginx-ec2.png)

## 现实情况

你拥有一支非常擅长业务应用的研发团队，然而却**缺乏大规模数据存取系统搭建的经验**和软件工程经验。你迫切希望，你的团队能够研发一款面向互联网的服务，该服务能够大规模存取用户产生的数据。

## 准备和实现

**首先**，你需要为你的业务进行**数据建模**，以及分析**数据存取模式**。

**数据建模**要解决的问题是将现实世界里的对象抽象化，通过数据结构来定义和描述现实世界里的对象，每一个数据结构由一些字段来构成，每个字段有对应的类型，常见的类型有Number、String、Bool、Enum等等。

**数据存取模式**要解决的问题是搞清楚存取哪些数据和存取操作都有哪些。比如，你正在做一个电商服务，因此你需要存储商品数据，此外，你肯定会陈列商品以及展示商品的详细，这些都是属于数据存取模式要解决的问题。

**你必须反复思考以上问题，把思考过程中的信息记录下来**，因为，使用DynamoDB会存在一个问题：在已有的存取系统上增加新的数据存取模式会涉及到数据迁移，如果数据量很庞大，那么这种迁移工作会带来挑战，比如如何确保数据迁移的完整性、如何在不影响线上应用的情况下完成迁移等等。

**其次**，你需要创建*main.tf*文件，内容如下：

```bash
terraform {
  required_version = "= 0.12.19"
}

provider "aws" {
  version = "= 2.58"
  region  = "ap-northeast-1"
}

module "dynamodb" {
  source       = "github.com/2cloudlab/module_dynamodb//modules/dynamodb?ref=<tag>"
  name         = <your-table-name>
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = <main-table-hash-key>
  range_key    = <main-table-range-key>
  attributes = [
    {
      name = <main-table-hash-key>
      type = "S"
    },
    {
      name = <main-table-range-key>
      type = "S"
    },
    ]
}

output "dynamodb_instance" {
  value = module.dynamodb.dynamodb_instance
}
```

你只需要指定以下几点

1. `ref=<tag>`中的`tag`需要替换成该模块的版本号，比如*v.0.0.1*
2. `name`是指表的名字，你的数据会存储在这张表中
3. 其它属性需要根据你的业务场景来定，你可以参考[这里](https://www.digolds.cn/article/001572926018754ebaf8e3696284bab9e5e2c940396c424000)来了解DynamoDB的基础知识

指定之后，`cd`到*main.tf*所在的目录，然后执行以下命令来创建DynamoDB服务：

```bash
terraform init
terraform plan
terraform apply
```

成功之后，你将看到以下类似的输出（其中的省略号是为了方便显示）：

```bash
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:
...
```

创建成功之后，你就可以借助各种编程语言来操作DynamoDB服务了，可选的编程语言有Go、Python、Node.JS、C++、Java等等，AWS均为这些编程语言提供了对应的SDK，你应该优先选择SDK来操作DynamoDB服务。

## 具体案例

在之前[这篇文章](https://www.digolds.cn/article/001605969485805c873b6a1c226495b82cf1f88aef67d22000)里，我们搭建了一个WSGI兼容的博客应用，它是基于Python研发的，虽然，在那里我们能够在一个小时之内将该App接入互联网，你也可以访问它的主页，然而它依然没有存储文章的能力。接下来，让我们为这个博客应用增加存储能力，它的源码托管在[这里](https://github.com/digolds/digolds_sample)。

之前说过，在创建DynamoDB服务之前，你需要为你的业务场景进行数据建模和分析数据存取模式，在我们这个例子里，该业务场景就是博客应用，它需要对单篇文章进行增删改查，除此之外，它还需要分页显示文章列表以及获取当前正在阅读文章的前一篇和后一篇文章。

文章的格式如下所示：

```bash
{
    'title':'What is digwebs',
    'description':'A tiny web framework called digwebs which is developed by Python.',
    'markdown_content':'######',
    'created_date':1604282588, # int(time.time())
    'author_name':'slz',
    'id':9609923996892418
}
```

而对应的数据操作是:

1. `add_article`
2. `get_single_article`
3. `update_single_article`
4. `delete_article`
5. `list_simple_articles`
6. `get_near_articles`

接下来，编写一个*main.tf*文件，其内容如下所示：

```bash
terraform {
  required_version = "= 0.12.19"
}

provider "aws" {
  version = "= 2.58"
  region  = "ap-northeast-1"
}

module "dynamodb" {
  source       = "github.com/2cloudlab/module_dynamodb//modules/dynamodb?ref=v0.0.1"
  name         = "personal-articles-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Id"
  attributes = [
    {
      name = "Id"
      type = "N"
    },
    {
      name = "ContentType"
      type = "N"
    },
    {
      name = "CreatedDateTime"
      type = "N"
  }, ]
  global_secondary_indexes = [{
    name               = "ContentGlobalIndex"
    hash_key           = "ContentType"
    range_key          = "CreatedDateTime"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["Id", "Title", "Description", "AuthorName"]
  }, ]
}

output "dynamodb_instance" {
  value = module.dynamodb.dynamodb_instance
}
```

在上面的脚本中，你要特别注意以下几点：

* 我们定义了一个全局索引，它的名字是`ContentGlobalIndex`
* 我们只为主表指定了主键`Id`
* 所有主键（hash_key）和排序键（range_key）均需要在`attributes`中指定

`cd`到文件*main.tf*所在的目录，执行以下指令来创建DynamoDB服务：

```bash
terraform init
terraform apply
```

成功之后，你将看到以下输出结果：

```bash
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:
...
```

虽然，你成功创建了DynamoDB服务，但是它和这个博客应用是相互独立的，因此，你需要通过某种方式将两者集成在一起，一种比较好的做法是在博客应用中加入**环境变量**，事实上，该博客应用的源码已经包含了下面2个环境变量：

```python
os.environ['TABLE_NAME'] = 'personal-articles-table'
os.environ['INDEX_NAME'] = 'ContentGlobalIndex'
```

因此，为了能让这个博客应用访问上面创建的DynamoDB服务，你需要在[之前的文章](https://www.digolds.cn/article/001605969485805c873b6a1c226495b82cf1f88aef67d22000)中增加2个环境变量。同时，你也会看到在这个博客应用里使用了`boto3`库，它是AWS提供的专门用于操作AWS服务的Python版SDK。

## 存在的问题

在使用这个开箱即用的解决方案时，你需要注意以下几点：

1. 选择的hash\_key最好能均匀分布，而选择的range\_key最好能够根据业务场景对数据进行排序
2. DynamoDB服务是对数据的大小是敏感的，如果你存取单条数据的大小超过400 KB，那么，你需要考虑使用S3服务
3. DynamoDB中的表和索引是有数据吞吐量的限制的，因此你需要根据业务需求来为其选择相应数量的读写单元