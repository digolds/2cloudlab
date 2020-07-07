---
title: "如何正确使用DynamoDB"
date: 2020-03-15T12:27:38+06:00
description: "把DynamoDB作为数据层的引擎能带来许多好处，一方面，它能够存储大规模数据的同时也保持高性能的数据存取，另外一方面，它能减少运维工作。打造一个稳定高效的数据服务需要解决很多问题，这些问题有：选择哪些工具为DynamoDB建模？如何记录热数据以及引发异常的数据？如何保证数据是加密存储在磁盘的？如何减少存取数据的响应延时？限制哪些用户拥有哪些数据存取的权限？选择哪种类型的数据备份策略？如何将数据发布到全球并保持同步？DynamoDB的最佳设计原则有哪些？等等。"
type: post
image: images/blog/dynamodb-relate-components.png
author: 郑思龙
tags: ["NoSQL", "DynamoDB", "Data-Intensive"]
---

把DynamoDB作为数据层的引擎能带来许多好处，一方面，它能够存储大规模数据的同时也保持高性能的数据存取，另外一方面，它能减少运维工作。打造一个稳定高效的数据服务需要解决很多问题，这些问题有：选择哪些工具为DynamoDB建模？如何记录热数据以及引发异常的数据？如何保证数据是加密存储在磁盘的？如何减少存取数据的响应延时？限制哪些用户拥有哪些数据存取的权限？选择哪种类型的数据备份策略？如何将数据发布到全球并保持同步？DynamoDB的最佳设计原则有哪些？等等。

> 使用频率很高的数据被称为**热数据**。比如DynamoDB中的某项数据item每秒被访问1亿次，那么这个item就是一项热数据。

以上问题有的一开始就会遇到（比如选择数据建模工具），有的则只在业务发展到一定阶段才会遇到（比如将企业的业务从中国区扩展到北美区）。不同问题需要不同的工具或者服务来解决，使用DynamoDB服务的一个好处是：它集成了很多开箱即用的服务。作为开发者，只需要创建这些服务，然后将其串联在一起形成一个完整的数据服务，而无需从头开始搭建解决问题的方案。

## 1.1 使用DynamoDB时需要考虑的问题

围绕DynamoDB展开研发数据服务需要在不同阶段考虑不同问题。这些问题将在研发所处的阶段一一暴露出来，而企业发展到一定阶段时才需要考虑属于这个阶段的问题。这3个阶段分别是：研发初期，测试阶段和发布阶段。其中发布阶段需要考虑的问题有很多。

在**研发初期**，需要为团队选择可视化工具来提供数据建模，可视化数据，以及操作数据。除此之外，还需要在本地安装DynamoDB，以便研发人员能够快速地在本地验证其想法。

在**测试阶段**，则需要搭建线上的测试环境，准备测试数据，使用AWS的Lambda服务进行各种测试（功能测试和性能测试）。由于测试环境位于AWS的数据中心，因此还需要考虑由哪些研发人员使用测试环境，以及他们所拥有的权限，这就是用户权限的问题。

在**发布阶段**，则需要准备生产环境，实施增量发布策略，在这个过程中还需要考虑如何在保持已有数据库服务稳定运行的同时升级数据库，升级业务逻辑，最终将数据服务平稳地替换成新的数据库服务而不影响线上用户，这就是我们常说的rolling deployment。由于数据是存储于云端的，因此为了数据安全，则需要为存储在云端的数据进行加密存储以及需要确保数据传输过程也是加密的。为了观察业务增长模式以及性能调优，则需要监控DynamoDB的使用情况，找出哪些数据经常被访问，哪个时间段的数据存储活动最活跃。为了防止运维人员错误地删除数据，则还需要选择合适的策略为数据进行备份。为了防止其他用户读取不相干的信息，则还需要考虑设置数据存取权限，以便某些数据无法被查阅。当遇到某些场景，其要求低延时，比如1微秒以内，那么则还需要考虑使用缓存技术来降低响应延时。当企业开始向海外扩张时，为了让海外用户能够快速地访问数据服务，则需要将数据完整地拷贝到离海外用户地理位置更近的数据中心。有时，你还需要将数据导出到数据分析系统，以便其它部门，比如销售或市场部门能分析这些数据，用于后续的营销活动。

企业的业务在发展过程中会经常遇到以上所提到的问题，为了解决这些问题则需要借助对应的工具。接下来，让我们看看DynamoDB都提供了哪些功能以及集成了哪些服务来解决上述提到的问题。

## 1.2 DynamoDB与周围的工具

DynamoDB本身提供了数据存取功能，它还考虑了高可用性（所有的数据会自动拷贝到不同的可用区，以免某一个区发生故障了，另外一个区能够及时补上），除此之外，它会将所有数据以加密的方式存储在磁盘（从9.KMS中获取秘钥），而传输过程中则使用了HTTPS协议来加密传输数据。DynamoDB还提供了1.Stream功能，该功能能够捕获数据的变动，因此可以基于这个功能将数据同步到4.其它数据分析系统。如果企业需要海外扩张，那么可以借助DynamoDB的2.Global Table功能。为了避免人为因素引起数据丢失，DynamoDB提供了2种数据备份的方式：分别是按需备份和按时间备份。这些功能均是开箱即用的，也就是说研发人员只需要根据实际的业务场景来组合所需的功能。之前所提到的部分问题均可以迎刃而解！而剩下的一些问题则需要结合一些周围的工具来解决。

使用DynamoDB的初期需要选择合适的数据建模工具：[NoSQL Workbench](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/workbench.settingup.html)。这个工具是一个可视化工具，有了它，研发人员可以通过可视化的方式数字化建模，定义数据存取模式，查看数据以及操作数据。通过这种方式，数据服务的设计者们可以很快地验证想法。

安装本地版本的DynamoDB对于研发人员来说是非常有必要的，原因在于它能够方便研发人员减少调试数据服务的时间。比如，你用Go语言编写了一个函数，该函数调用了GetItem接口，那么你可以在本地执行单元测试来验证这个函数是否达到预期。安装DynamoDB数据库的方式有很多种，其中通过Docker来启动DynamoDB是一个不错的方法，你要做的只需要安装Docker，之后运行以下指令，就能在本地使用DynamoDB。具体说明可以参考[这里](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.Docker.html)。

```bash
sudo docker run -p 8000:8000 amazon/dynamodb-local
```

为了对已有的数据服务调优，比如将经常被访问的数据放到缓存里，首先需要借助DynamoDB提供的10.Contributor Insights功能来查看哪些数据被频繁访问，哪些数据引发了错误，然后还需要启动3.DAX集群服务来缓存这部分数据。DAX集群与DynamoDB无缝连接，它将热数据放到DAX集群机器的内存里，最终从内存里取出数据提供给终端用户。

有时候，有些业务要求返回部分数据，比如对于线上机票业务，用户购买了一张机票，此时该用户只需要知道该机票的登机信息而不需要知道机长等信息。对于这种场景，则借助IAM服务来控制某些数据的访问权限（比如，创建5.Role）。再比如你的所有服务均部署在AWS，且你希望只有AWS中的服务才能访问DynamoDB，那么此时也可以借助IAM服务来支持这种场景。

使用DynamoDB的时候会产生各种信息，有些信息是指标数据：DynamoDB资源的使用情况，有多少请求因为资源不足而无法处理，错误信息，为了得到这些信息，研发人员可以使用7.CloudWatch服务来收集它们。除此之外，还可以创建8.CloudWatch Alarms来判断指标是否超出了一个界限，如果超出则会自动触发一系列操作。还有一些信息是关于操作相关的信息：是谁在什么时间段使用了DynamoDB以及做了什么操作，为了收集这些信息，研发人员可以借助6.CloudTrail服务。

通过以上描述可知，只有将DynamoDB以及周围的服务或工具结合在一起才能打造出一个完整稳定的系统。作为研发者，则只需要根据自身的业务需求来选择是否启用某些服务，比如，如果你的业务不要求微秒级别的响应，那么则没有必要启动3.DAX服务；如果你的业务只是服务于中国的用户，那么2.Global Tables的功能则不需要开启。这里需要注意的是，每种服务的使用都会增加系统的复杂性和费用，因此使用AWS服务的首要原则是**按需使用**。

## 1.3 DynamoDB与所处的位置

由上图可知，DynamoDB与许多服务均有交互，如图中的2所示。终端用户（图中的users）通过手机客户端或浏览器访问间接访问DynamoDB，它一方面可以通过https协议来存取数据，另外一方面通过3.DAX来加快存取数据的流程。在存取数据的过程中均会受到5.role的限制，role是属于IAM的一个资源，开发者为其指定哪些人拥有哪些操作DynamoDB的权限以及能存取哪些数据。每次对DynamoDB进行操作，都会产生log信息，这些信息主要分为2类，一类是哪些人做了哪些操作，这些信息存储在6.CloudTrail中，另外一类是关于操作DynamoDB的数据信息，这些信息有哪些数据是热数据，并通过10.Contributor Insights发布到7.CloudWatch中。如果发布到7.CloudWatch中的数据有异常，则会通过8.CloudWatch Alarm发起邮件来通知研发者。如果需要分析DynamoDB中的数据，那么则需要借助1.DynamoDB Stream来将数据导出到4.分析系统，市场人员将通过这个分析系统来生产报告，用于后续的市场推广活动。为了对DynamoDB中的数据加密存储到磁盘，则需要借助9.KMS服务，由KMS提供秘钥原料，并生成key来对数据进行加密。

DynamoDB自身具有自动备份的功能以及同步到不同的区域。区域与区域之间是地理上相互隔离，并通过高速电缆连接起来的数据中心。每一个数据中心除了能防止单点故障（某个区域发生故障后，另外一个区域依然能正常运行）之外，还可以从地理位置上降低服务的响应延时（美国的用户只需要访问美国的Oregon数据中心，而日本的用户则只需要访问Tokyo数据中心）。

作为研发者，在使用AWS服务时，则需要考虑环境的问题。比如，哪些环境是提供给终端用户使用的，哪些环境用于内部测试。比如上图创建了2个账号，分别是security和prod account。其中prod account专门用于生产环境，该环境需要严格把控，尽可能让最少的研发人员操作这个环境，因此需要借助IAM服务来授予部分经验丰富的工程师，授予最少的操作prod account资源的权限。所有研发工作者应该在security account里有对应的IAM User，并通过security来操作prod account中的资源。这种方式确保了每一个环境均是隔离的，且研发工作者的研发账号都得以在security account中统一管理（这种方式称为[Across Accounts](https://2cloudlab.com/portfolio/how-to-construct-enterprise-accounts/)）。

## 结论

这篇文章试图通过[现实世界中遇到的问题](https://2cloudlab.com/nosql/amazon-back-end-data-system/)来分析DynamoDB所提供的功能以及集成了哪些服务。这些问题有的一开始就会遇到（比如每名DynamoDB的研发工作者，均需要将在本地安装DynamoDB，以便能方便调试。），有的则是在业务发展的过程中陆续出现，而研发工作者要做的是根据业务场景开启对应的功能或使用集成的服务来解决所遇到的问题。为了你能更好地使用DynamoDB，你需要知道它所处的位置，提供了哪些功能以及其他服务是如何与它交互的。另外，在统一管理研发工作者的账号时，通常需要考虑多个AWS账号，这种方式的好处是能让账号与账号之间的资源是相互独立，以便减少研发人员因错误操作而导致所有环境无法使用的风险。