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

When creating a table, you will need to provide AttributeDefinitions for each attribute you need to define. An attribute definition includes the name and type of the attribute. For us, this means we have an attribute with the name "Username" and of type "S", for String. You only need to define attributes which are used in your primary key or are used in secondary indexes.

You'll then need to provide the KeySchema of your table. This is where you define your primary key, including a HASH key and an optional RANGE key. In this example, we're using a simple primary key so we're just using Username as a HASH key.

Finally, you'll need to specify a TableName and the ProvisionedThroughput for your table. We'll keep the Read and Write Capacity Units at 1 since this is just an example.

With these notes in mind, let's create our table:

```bash
$ aws dynamodb create-table \
  --table-name UsersTable \
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