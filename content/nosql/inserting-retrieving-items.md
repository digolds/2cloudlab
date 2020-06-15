---
title: "在DynamoDB中插入和读取数据项"
date: 2019-02-22T12:27:38+06:00
description: "[数据项](https://2cloudlab.com/nosql/anatomy-of-an-item/)是DynamoDB的基础单元，每一张表都会包含多项数据。接下来，在本文中，我们将向DynamoDB中插入和读取数据项。我们将创建Users表，并为该表指定一个简单键：Username。接着，我们将操作2个基本的接口：PutItem和GetItem。下一篇文章，我们将在这篇文章的基础上应用表达式来实现更加复杂的查询功能。在这之后，我们另起一篇文章来讲解如何更新和删除数据项。"
type: post
image: images/blog/anatomy-of-an-item.png
author: Alex
tags: ["NoSQL", "DynamoDB", "Data-Intensive"]
---

[数据项](https://2cloudlab.com/nosql/anatomy-of-an-item/)是DynamoDB的基础单元，每一张表都会包含多项数据。接下来，在本文中，我们将向DynamoDB中插入和读取数据项。我们将创建Users表，并为该表指定一个简单键：Username。接着，我们将操作2个基本的接口：PutItem和GetItem。下一篇文章，我们将在这篇文章的基础上应用表达式来实现更加复杂的查询功能。在这之后，我们另起一篇文章来讲解如何更新和删除数据项。

为了能顺利操作本文所列举的示例，请确保DynamoDB的环境已经准备好。注意：如果你使用的是本地版本的DynamoDB，那么请确保`$LOCAL`变量配置正确，如果使用的是AWS上的DynamoDB，那么在每一个命令后面无需追加这个参数。

## 创建表

在演练本文列举的用例之前，首先需要创建一张表。我们将创建一张表Users，并为该表定义了一个简单主键："Username"，它的类型是string。

当创建表时，你需要为主键或索引提供属性定义。这些属性定义包含了属性名和属性类型。在Users这张表中，我们使用"Username"作为主键，其类型是string（"S"）。除此之外，你还需要为该表指定KeySchema。This is where you define your primary key, including a HASH key and an optional RANGE key. In this example, we're using a simple primary key so we're just using Username as a HASH key.

Finally, you'll need to specify a TableName and the ProvisionedThroughput for your table. We'll keep the Read and Write Capacity Units at 1 since this is just an example.

有了以上概念, 让我们运行以下指令来创建表"Users":

```bash
$ aws dynamodb create-table \
  --table-name Users \
  --attribute-definitions '[
    {
        "AttributeName": "Username",
        "AttributeType": "S"
    }
  ]' \
  --key-schema '[
    {
        "AttributeName": "Username",
        "KeyType": "HASH"
    }
  ]' \
  --provisioned-throughput '{
    "ReadCapacityUnits": 1,
    "WriteCapacityUnits": 1
  }' \
  $LOCAL
```