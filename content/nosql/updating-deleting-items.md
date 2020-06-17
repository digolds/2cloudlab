---
title: "更新和删除数据项"
date: 2020-02-25T12:27:38+06:00
description: "本文是关于DynamoDB的表达式。表达式是DynamoDB的内置功能，它又细分为以下几类表达式："
type: post
image: images/blog/updating-deleting-items.png
author: Alex
tags: ["NoSQL", "DynamoDB", "Data-Intensive"]
---

在这篇文章中，我们将学习如何向表中更新和删除单项数据。这是最后一篇关于单项数据操作的文章，后续的文章将涉及多个数据项的操作，这些操作主要有Queries和Scans。

## 更新单项数据



## 删除单项数据

最后一个关于单项数据的操作是删除操作，也就是DeleteItem。在有些场景，你需要删除表中的某项数据，而这个操作则能满足该场景。

DeleteItem操作相当简单--你只需要提供想要删除数据项的主键信息，如下所示：

```bash
$ aws dynamodb delete-item \
    --table-name Users \
    --key '{
      "Username": {"S": "daffyduck"}
    }' \
    $LOCAL
```

以上操作将把"Username"为"daffyduck"的数据项从表中移除。如果你想通过GetItem操作来获取该用户，那么你将得到空的结果。

类似于PutItem操作，你能够使用`--condition-expression`来指定删除的条件。比如我想删除该用户，但是前提条件是该用户的年龄必须是少于21岁，示例如下：

```bash
$ aws dynamodb delete-item \
    --table-name Users \
    --key '{
      "Username": {"S": "yosemitesam"}
    }' \
    --condition-expression "Age < :a" \
    --expression-attribute-values '{
      ":a": {"N": "21"}
    }' \
    $LOCAL

An error occurred (ConditionalCheckFailedException) when calling the DeleteItem operation: The conditional request failed
```

通过以上示例的执行结果可知：由于Yosemite Sam已经73岁了，所以条件表达式将无法通过，最终导致此次删除操作失败。

## 结论