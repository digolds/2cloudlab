---
title: "DynamoDB Stream"
date: 2020-03-05T12:27:38+06:00
description: ""
type: post
image: images/blog/dynamodb-streams.png
author: 郑思龙
tags: ["NoSQL", "DynamoDB", "Data-Intensive"]
---

DynamoDB的表能够存储大量的数据，为了提高查找性能，研发人员通常会将关联但不同的数据实体（比如User和Order）集中存放在一台服务器上，这就导致表中的数据关系难以理解！如果直接基于该表来分析其中的数据，则分析工作将会变得困难起来，除此之外，也会影响终端用户的用户体验（分析任务会占用该表的读写单元）。为了使分析工作变得简单，则需要将表中的数据导入到其它分析系统，最终依赖其它分析系统来分析数据。将数据导出到其它系统主要有2种办法，它们分别是：1.遍历整张表，并将每一项数据写入到其它系统；2.表中的数据每变更一次，则将变更写入到其它系统。前者不适用于数据量庞大的情景，而后者可以很好地避开处理大量数据，但需要借助**DynamoDB Stream**功能来实现。

**DynamoDB Stream**是DynamoDB提供的一个功能，现实世界里有许多场景会使用到它，这些场景有：

* 同步不同区域的数据。比如你的业务分布在中国和美国，那么你需要将美国的数据同步到中国，反之亦然。此时你需要借助DynamoDB Stream来实现数据同步，最终确保中国用户与美国用户访问的数据是一致的。
* 发送消息。比如你的App有一个用户注册功能，每当一个新用户注册时，你需要向新用户发送一封表示欢迎的邮件通知。此时你需要DynamoDB Stream的通知机制来触发分发邮件的服务。
* 索引数据。DynamoDB不适合**全文搜索**，因此如果你想要搜索表中的数据，那么最好的办法是将表中的数据快速同步到**Elastic Search**服务或者[algolia](https://www.algolia.com/)里，最终通过这些服务来搜索数据。为了能够快速地将数据更新到搜索系统，那么则需要DynamoDB Stream。
* 聚合或统计数据。有时你想快速得到一些统计信息，比如某个区域的总销量，每家门店每个月所需的成本等等。那么你可以使用DynamoDB Stream来聚合这些数据。

为了实现以上提到的应用场景，则需要了解DynamoDB Stream内部的逻辑以及它与其它服务的关系。[这篇文章](https://2cloudlab.com/nosql/dynamodb-streams/)将从以下几个方面来讲解DynamoDB Stream：

1. DynamoDB Stream的构成以及其周边服务
2. DynamoDB Stream的限制
3. 基于DynamoDB Stream的设计模式
4. 参考

## DynamoDB Stream的构成以及其周边服务

DynamoDB Stream是DynamoDB服务所提供的一个功能，它需要结合DynamoDB Table来使用。开启DynamoDB Stream功能的Table能集成其它服务，最终能够延伸DynamoDB的功能（比如，使用Elastic Search来检索表中的数据，并提供全文搜索功能！）。下图展示了DynamoDB Stream与其它服务的关系：

![](https://2cloudlab.com/images/blog/DynamoDB-Stream.png)

上图涉及到DynamoDB Stream的工作流程是：

1. Producers将向表中修改数据，包括添加数据，修改已有数据，删除数据等。这些操作均是基于HTTPS协议来发起的。
2. DynamoDB将修改之后的数据发送给DynamoDB Stream（向每个Shard中写入数据的速率最多是1MB/S），数据在DynamoDB中只能存放24小时，在这之后，数据将自动从DynamoDB Stream中移除。
3. 每个Consumer从对应的Shard中批量读取记录，每次最多能读取1000条记录或者每秒最多能读取2MB数据，只要有一个条件满足，则读取数据的操作将停止并将读到的数据返回给Consumer。读取操作是基于HTTPS协议来发起的。

上图涉及到DynamoDB Stream的内部逻辑以及外部交互：

研发人员在使用DynamoDB服务时，需要创建表（Table），每一张表其内部又根据数据量划分了好几个分区（如上图的Partition A，Partition B，Partition C）。每一个分区其实会分布于不同的服务器上。

如果在该表上启用了DynamoDB Stream，那么这个Stream会根据分区数量来创建Shard（如上图有3个Shard）。每一个分区中修改的数据只会发送到对应的Shard上，并且是有序的。每一个Shard里的数据（如上图的Record），其生命周期是24小时，在这之后，该数据项自动移除。

DynamoDB Stream只允许使用者（也就是上图的Consumers）从中批量读取数据，其它操作，比如删除其中的数据项或者修改其中的数据项是禁止的。DynamoDB Stream的吞吐量（MB/S）受到Shard的限制，Shard的数量越多，则其吞吐量越大（每个Shard的吞吐量是2MB/S，每个Consumer每秒最多能读取1MB的数据）。每个Consumer一次最多能从对应的Shard中读取1000条数据（Record）。每个Shard最多同时被2个Consumers来使用，超过这个数量，则会导致读取失败，这一点使得DynamoDB Stream无法直接支持超过2个以上的服务（比如，无法同时支持新用户注册收到欢迎邮件，将数据导出到其它分析系统，检索DynamoDB中的数据等）。

上图使用了AWS Lambda服务作为DynamoDB Stream的Consumers。研发人员只需要创建一个Lambda Function，然后将该Function的触发器设置成DynamoDB，就能接收DynamoDB Stream的通知了。当每个Shard里有新的数据时，Lambda服务会根据该函数的设置（比如最多一次取10000个Records）读取Records（如果Shard里有100万条数据，每1000条的数据量是0.8MB<1MB，那么Lambda服务会调用10次[GetRecords](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_streams_GetRecords.html)操作，并得到8MB的数据，但是由于Lambda Function的request PayLoad最大是6MB，因此，此时调用Lambda Function时会引发异常。），然后调用Function实例，并将读取到的Records批量传递给Function，由Function决定发送给哪些下游服务，如果这些批量数据均处理成功，那么Lambda服务将继续从对应的Shard中读取下一批Record，直到对应的Shard中没有新的数据。

除了使用Lambda Function，还可以使用EC2，并运行[KCL和DynamoDB Streams Kinesis Adapter](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.KCLAdapter.html)应用来读取数据，如下图所示：

![](https://2cloudlab.com/images/blog/DynamoDB-stream-with-kcl.png)

与Lambda Function作为Consumers不同，KCL Workers需要运行在服务器上（比如EC2或Kubernetes的节点上），并且需要研发人员考虑规模化的问题，比如决定运行几个Workers等。除此之外，研发人员还要基于[KCL和DynamoDB Streams Kinesis Adapter](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.KCLAdapter.html)编写数据读取应用。

## 参考

* [How to perform ordered data replication between applications by using Amazon DynamoDB Streams](https://aws.amazon.com/blogs/database/how-to-perform-ordered-data-replication-between-applications-by-using-amazon-dynamodb-streams/)
* [DynamoDB Stream Processing: Scaling it up](https://medium.com/realtime-data-streaming/data-streaming-from-dynamodb-scaling-it-up-8273d23295c)
* [DynamoDB Stream Processing](https://medium.com/realtime-data-streaming/data-streaming-from-dynamodb-to-elasticsearch-eb2381446f43)
* [Event-driven processing with Serverless and DynamoDB streams](https://www.serverless.com/blog/event-driven-architecture-dynamodb/)
* [Challenges and patterns for building event-driven architectures](https://www.serverless.com/blog/stream-based-challenges-and-patterns/)
* [DynamoDB Streams Use Cases and Design Patterns](https://aws.amazon.com/blogs/database/dynamodb-streams-use-cases-and-design-patterns/)