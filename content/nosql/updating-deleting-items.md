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

zuiThe final single-item action to cover is DeleteItem. There will be times when you want to delete Items from your tables, and this is the action you'll use.

The DeleteItem action is pretty simple -- just provide the key of the Item you'd like to delete:

```bash
$ aws dynamodb delete-item \
    --table-name UsersTable \
    --key '{
      "Username": {"S": "daffyduck"}
    }' \
    $LOCAL
```

Your Item is deleted! If you try to retrieve your Item with a GetItem, you'll get an empty response.

Similar to the PutItem call, you can add a --condition-expression to only delete your Item under certain conditions. Let's say we want to delete Yosemite Sam, but only if he's younger than 21 years old:

```bash
$ aws dynamodb delete-item \
    --table-name UsersTable \
    --key '{
      "Username": {"S": "yosemitesam"}
    }' \
    --condition-expression "Age < :a" \
    --expression-attribute-values '{
      ":a": {"N": "21"}
    }' \
    $LOCAL
```

An error occurred (ConditionalCheckFailedException) when calling the DeleteItem operation: The conditional request failed
Because Yosemite Sam is 73 years old, the conditional check failed and the delete did not go through.