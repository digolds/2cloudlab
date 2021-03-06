
---
title: "由amazon.com背后的数据系统所引发的思考"
date: 2020-03-14T12:27:38+06:00
description: "amazon.com是服务于全球的在线电商，遍布全球的用户在它的平台上购买一件商品所需的时间不超过10秒。它是如何陈列成千上万件商品的同时，依然输出稳定的数据存取性能，从而提升全球用户在购物过程中的体验？对于这个问题的思考，将加深我们对数据库系统的理解，进而设计出优良的数据服务！"
type: post
image: images/blog/mongoDB-data-model.png
author: 郑思龙
tags: ["NoSQL", "DynamoDB", "Data-Intensive"]
---

amazon.com是服务于全球的在线电商，用户在它的平台上购买一件商品所需的时间不超过10秒。它是如何陈列成千上万件商品的同时，依然输出稳定的数据存取性能，从而提升全球用户在购物过程中的体验？对于这个问题的思考，将加深我们对数据库系统的理解，进而设计出优良的数据服务！[本文](https://2cloudlab.com/nosql/amazon-back-end-data-system/)将从Amazon的分类商品和推荐商品问题开始，揭示其背后的数据中心及其构成。紧接着为遇到的问题进行数据建模并分别使用MySQL，MongoDB，DynamoDB技术方案来解决这些问题。每种技术方案都有其适用的场景，并体现在文中，最终形成了一些判断依据，用于决定选择NoSQL还是SQL。

## 1.1 Amazon的分类商品与推荐商品所引发的思考

下图是从amazon.com首页截取的部分信息，主要包括 **分类商品** 与 **推荐商品** 。

![](https://2cloudlab.com/images/blog/amazon-home-page.png "图 1.1 amazon.com主页中部分商品")

以上信息有一个特点：**每一个大类中均包含多件商品**。比如：推荐板块中列举了多件商品；Ride electric类目下有多种商品。这些信息通常会存储在中心服务器上，由数据库系统管理。当用户访问amazon.com时，浏览器会向中心服务器获取商品数据。整个过程如下图所示：

![](https://2cloudlab.com/images/blog/amzone-visit-workflow.png "图 1.2 从数据中心查询商品数据")

通过上图可知，**数据中心**不仅需要存储这些商品信息以及每件商品所属的分类信息，还要提供获取商品信息的方法。为了使数据中心具有数据存取的能力，往往需要引入数据库系统（下图蓝色区域部分）。这些系统不仅能够存储数据，也能够查询数据，通常运行于多台服务器。而这些服务器通过网线连接在一起，作为一个整体对外提供数据存取服务。最终，数据中心的演化如下图所示：

![](https://2cloudlab.com/images/blog/amzone-visit-workflow-detail.png "图 1.3 位于数据中心的数据库系统")

**注意**：以上只是一个简化版的数据中心，现实情况是：amazon.com依赖于多个数据中心，每个国家都会有一个或多个数据中心（比如：美国，欧洲以及中国均有多个数据中心），每个数据中心都有大量的微服务支持着amazon.com。不同国家的用户会直接访问该国家的数据中心，这么做的好处是基于地理位置来降低访问延时。以上简化版的数据中心已经足够让我们讨论大多数amazon.com背后的数据服务了，对于业务遍布全球的企业，多数据中心是必须考虑的。接下来，让我们思考：使用数据库系统存取这些商品信息时会遇到的问题。

首先将遇到问题是：**当数据量增多，超过现有的存储能力时，数据如何存储**？通常的做法是增加存储空间，比如在每台服务器上挂载多块硬盘。

其次，**当每秒访问数据库系统的次数增多时，如何确保数据库系统是有能力提供服务的**？解决这个问题的做法是提供多台服务器（每台服务器中运行着数据库软件），并将数据切分成好几份，再将每一份分配到不同的服务器上。

最后，**如何确保一次性获取完整的数据**（比如一次性获取Ride electric类目下的多种商品）？当所有商品的数据集被切割成更小的集合散落在不同的服务器上时，会出现一种情况：相关联的数据分布在不同的服务器上，为了获取这些数据，则需要从不同的服务器中收集这些数据，最终整合在一起。这种方式存在一个问题：获取相关联的数据所需的时间变长了！因此为了减少获取数据的时间，则需要将相关联的数据集中在一台服务器上，以便一次性将这些关联的数据从一台服务器上取出，而不是多台服务器。为了实现这一目标，则需要一些数据应用的设计经验。

除了以上提到的问题之外，还有其它一些常见的问题需要考虑：如何确保每个分区的数据有多个备份（replica），以便该分区无法提供服务时，另外一个备份接替它的工作？如何解决数据热区的问题（比如一个热销商品被全球60亿人在一秒之内查看）？启动多少台数据库服务器以及如何监控这些服务器的运行状态？如何备份数据，以防人为失误所导致的损失（比如删除所有数据）？如何确保数据中心的温度是正常的，以便服务器能够正常运行？等等。虽然企业在起步阶段不会遇到这些问题，但是随着业务的增长，这些问题将会接踵而至，等待你的是无穷无尽的问题。

如果你开始着手处理以上所有提到的问题，那么你会发现：需要大量有经验的人才和时间以及金钱才能完成，而这种做法是非常糟糕的！好在，现有的云服务厂商，比如中国的阿里云，美国的AWS，Google Cloud以及Azure基本上解决了以上大多数问题！而我们只需要在其基础之上解决一些与业务相关以及技术选型的问题。**接下来，让我们基于以上例子来分析有哪些业务问题需要解决，然后选择合适的技术来解决这些问题**。

## 1.2 面临的问题

**摆在我们面前的问题**有以下2点：

1. 作为用户，我希望系统能根据历史购买记录来向我展示推荐商品的列表，时间控制在1s以内
2. 作为用户，我希望系统为商品分类，并展示分类商品，时间控制在1s以内

以上问题有很多，分为前端和后端以及数据端，这里要讨论的焦点主要集中在 **数据端**。为了解决以上2个问题，我们需要对其进行数据建模-数据建模是指将现实世界中的问题抽象成数据实体（data entity）并建立数据实体之间的关系，最终通过计算机来表示。

通过问题的描述可知，共有4个数据实体，它们分别是：用户（User），商品（Product），推荐物（Recommend）以及商品分类（Category），以及3个关系，它们分别是：用户与推荐商品的关系，推荐物与商品的关系和商品分类与商品的关系。整个数据实体以及其之间的关系可以通过下图抽象出来：

![](https://2cloudlab.com/images/blog/data-entity-and-relationship.png "图 1.4 基于SQL的Schema来数据建模")

上图实体之间的连线代表它们之间的关系，其中`1:*`的含义是只1对0或1对多。比如一个用户可以有0，1，或者多个推荐商品。

对面临的问题建立数据模型之后，接下来需要考虑的问题是：**技术选型**。

## 1.3 技术选型

在软件行业里，专门针对数据存储与查询的数据库系统有很多，主要分为2大阵营，它们分别是SQL和NoSQL。典型的SQL产品有：MySQL，SQL Server，PostgreSQL等等，而NoSQL的产品有：MongoDB，CouchDB，Dynamo，DynamoDB等等。每种类型的数据库都有其适用的场景，没有一个数据库能够解决所有问题，常见的做法是将这些数据库整合在一起来提供一套数据库系统解决方案。比如SQL数据库产品就特别适合OLAP类型（数据分析）的业务，而NoSQL则适合于OLTP类型（线上交易或即时交互）的业务。比如amazon.com的后台数据系统的构成主要分为3大部分，它们分别是：

1. 由NoSQL数据库系统组成，并提供在线交易支持的数据服务
2. 由SQL数据库系统组成，并为公司内部提供数据分析服务（ETL）
3. 大数据平台，比如由Hadoop，Spark等框架提供的大数据服务

我们所面临的业务问题属于OLTP类型，因此接下来的内容将围绕OLTP类型的业务问题展开。在展开过程中，我们首先考虑使用SQL数据库系统来解决问题，然后分析这种方法能够带来哪些好处以及什么时候能使用它。除此之外，我们也会分析使用这种方法在哪些条件下会遇到瓶颈以及如何使用NoSQL来解决所遇到的问题。其次，我们会分析NoSQL是如何消除这些瓶颈以及需要为之付出的代价。最后，我们将解释为什么使用DynamoDB而不是其它NoSQL数据库系统。以上提出的第2，3点虽然不属于本文讨论的范围，但是它们在现代互联网企业中依旧占有一席之地，只不过这些问题会随着企业的发展而渐渐浮出水面！

> OLTP=(Online transaction processing)，是指线上交易活动的处理，比如电商，社交网络，搜索引擎等属于这类问题。这类活动有一个特征：低延时。
>
> OLAP=(Online analytical processing)，是指线上分析的处理，比如BI系统，市场分析，销售报告等与数据分析与挖掘相关的日常问题均属于这类问题。这类活动有一个特征：在海量数据里读取一小部分数据来生成报告，进而分析业务活动。

首先，让我们看看 **使用SQL数据库系统** 解决之前所提到的2个业务问题的情况。成熟的SQL数据库系统有很多，这里我们选用MySQL来解决以上提出的问题。接下来提到的方法同样适用于其它数据库系统。使用MySQL的前提条件是创建Schema，如图 1.4所示。该Schema里包含了4张表，每张表对应现实问题中的一个数据实体，比如"users"表代表用户实体，表中的每一行代表一个具体的用户，该表能容纳多个不同的用户。

为了处理获取某个用户的推荐列表的请求，MySQL数据库需要执行以下步骤：

1. 从表"users"中找到该用户所对应的行，拿到user_id
2. 根据user_id到表"recommends"中找到所有与user_id相等的行
3. 遍历步骤2返回的结果，根据每一行数据中的product_id从表"products"中取出详细的商品信息
4. 将1，2，3步获得的数据打包成一个整体返回给请求端（比如浏览器）

为了处理获取分类商品的请求，MySQL数据库需要执行以下步骤：

1. 从表"categories"获取商品分类条目
2. 根据每一个条目的category_id到表"products"中获取属于该条目的商品
3. 将类目信息与该类目下的商品打包在一起，并返回给请求端（比如浏览器）

到目前为止，这个技术选型完美地解决了以上2个问题。用户能在1s之内获取分类商品和推荐商品；修改表"products"中的产品信息会及时作用到其它表，比如表"recommends"；每张表一一对应了现实问题的数据实体，将现实问题中的逻辑关系保留下来；每张表的数据类型是一致的，使得分析表中的数据变得容易了许多。除此之外，如果未来有新的业务需求（比如用户可以对每件商品进行评价），那么我们只需要在原来的Schema中添加新的表（比如新添表"comments"）便能应对这些变化！

**注意**：想要获得以上好处的前提条件是：数据库存储的数据量不多，以及所有数据都在一台服务器上。往往一家企业在起步阶段就满足了这个条件，因此刚刚起步的企业经常会使用SQL数据库系统来搭建数据服务。使用SQL数据库不仅能应对业务变化，而且只需要管理一台服务器，消除了运维的负担。除此之外，开发者能很快上手SQL数据库系统，对应的学习资料也遍布网络，遇到问题也能及时得到社区反馈！开发者只需要根据问题来定义表，然后未来需要获取某些数据时，则只需要借助SQL语句来整合多张表的数据。这种模式的特征是：先根据存储来数据建模，未来需要数据时，再通过SQL语句进行整合。SQL中这种基于存储优化的设计理念显然不符合计算优化的应用场景，尤其是当数据库中的数据变多时（比如超过100TBs）。

数据变多将引发一个致命的问题：**查询时间变长了**。假设，每一张表均有10亿行数据，那么对于处理获取某个用户的推荐列表的请求的问题，则需要查询3张表，它们分别是："users"，"recommends"，"products"，每张表的查询时间随着数据量的增多而变长，最终导致相同的查询语句，其执行过程所需的时间是不稳定的。如果你的业务场景要求随着数据量增多依然需要提供稳定的查询性能，那么这种基于SQL数据库系统的数据服务显然不是一个可行的解决方案。为了解决这个问题，一个可行的思路是：将庞大的数据进行分区，并将相关联的数据放在一起，位于同一台服务器上，然后根据请求的信息直接到那台服务器上获取数据。实现这种思路的数据库系统就是NoSQL，它要求开发者提前想好查询数据的模式，并找到关联数据。接下来，让我们看看如何使用NoSQL数据库系统来解决我们的问题。

**使用NoSQL数据库系统**之前需要认真考虑业务问题所涉及的数据查询和存储模式。假设，我们使用MongoDB数据库，所面对的数据量是100TBs以上，数据模型依然如图 1.4所示。为了保持数据读写性能，则需要设计一种方法，让关联的数据集中在一起，并且每一个关联的数据集 **均匀分布** 在不同的服务器上。接下来，让我们基于遇到的问题来体现这种设计思路。

下面是从问题中提炼出来的数据存取模式：

1. 获取某个用户的推荐列表
2. 获取某个类目下的所有商品
3. 添加一件商品
4. 添加一个商品分类
5. 向某个用户添加一个推荐

为了存储用户，商品，商品分类以及推荐信息，则需要在MongoDB中创建一个collection，所有的实体信息均存储在这个collection里，这一点与SQL的做法（通过4张表来分别存储）不一样。为了让某类实体（比如用户）均匀分布在不同的服务器上，那么我们需要根据一个随机的字段（比如用户的user_id）来实现。为了让相关数据（比如某个用户的推荐列表）集中在一起，则需要使用一个字段（比如所有推荐的商品都包含了相同的user_id）来将关联的数据集中在一起。基于这些规则，我们很快能得到以下数据分布的collection。

![](https://2cloudlab.com/images/blog/mongoDB-data-model.png "图 1.5 MongoDB中的数据分布")

通过上图可知，每一条数据均通过一个document来记录，比如用户名为"slzheng"的用户为user document。Node1和Node2分别是2台服务器，category为book的document与product id为110和247的document连续存储于Node2的磁盘上，这是由shard_key和sort_key来决定的。为了一次性返回推荐商品列表，我们在recommend document里内置了product信息，这违背了SQL的第二范式原则，但是换来了更好的查询性能。有了这些基础，浏览器查询这些数据的具体过程如下：

1. 浏览器准备查询条件：比如user_id=123，前4个商品分类，将这些信息发送到数据中心
2. 分解器将这个查询条件分解成2个请求：user_id=123和前4个商品分类，并分别发送到Node1和Node2
3. Node1和Node2将结果返回，由分解器将分类商品和推荐商品组合在一起，最终返回给浏览器

**注意**:分解器实际上是运行在数据中心的服务器（如下图所示），上面运行的应用主要是分解来自浏览器的请求。通过这种办法，浏览器的响应延时最终由Node1和Node2中最迟返回的节点决定（如下图所示）。

![](https://2cloudlab.com/images/blog/amzone-visit-workflow-with-resolver.png "图 1.6 带有resolver的数据中心")

引入MongoDB能解决存取数据的性能问题，这是因为我们知道数据存取的模式，并根据这些存取模式来设计数据库的关键字以及数据的关联性。这种方式最终会将所有关联的数据集中在一起，以便一次性获取。而使用SQL数据库则不需要提前想好这些关键字，不需要知道数据的关联性，只需要定义实体，以后需要某些关联的数据时则只需要执行SQL语句来获取。

当然，为了使用MongoDB或者SQL数据库，依然需要很多有经验的人员投入，他们一方面要根据业务场景构思数据存取模式，另外一方面还得安装，部署，集群MongoDB节点。这些与业务无关的运维工作将消耗公司部分资源，因此为了摆脱这种运维上的限制AWS推出了DynamoDB服务。

最后，让我们看看 **使用DynamoDB** 的情况。与MongoDB类似，DynamoDB能够处理大量数据的同时输出稳定的数据存取性能，不同的是，DynamoDB的安装，部署以及集群完全由AWS来负责。作为开发者，你要做的只需要根据业务场景来设计数据库，以及根据业务的流量来启动对应的读写能力！由于使用DynamoDB设计数据库的思路类似于之前的MongoDB所做的设计，因此这里省略详细的设计过程。更多关于DynamoDB的设计原则将在后续章节中陆陆续续展开。

## 1.4 选择NoSQL还是SQL？

上节内容分别使用了3种数据库（MySQL，MongoDB，DynamoDB）来解决我们面临的问题，每一种方法都有其优点和缺点，以及对应的应用场景。下面，让我们根据一些条件来判断什么时候应该用MySQL，什么时候应该用MongoDB，什么时候应该用DynamoDB？这些数据库有时甚至需要结合在一起解决不同的问题。

如果以下任一条件满足，则可以考虑使用MySQL或者其它SQL数据库：

* 处理OLAP类型的业务问题
* 对于业务不熟悉，数据量不大的场景
* 对查询存取性能没有要求的应用场景
* 多个本地应用交换数据的场景

如果以下条件同时满足，则可以考虑使用DynamoDB数据库：

* 处理OLTP类型的业务问题
* 要求高性能的数据存取能力
* 无须运维
* 要求对数据加密
* 企业拥有清晰的业务模式，而且正在快速增长

如果以下条件同时满足，则可以考虑使用MongoDB：

* 处理OLTP类型的业务问题
* 需要开源的且高性能的数据库系统，以便未来能根据业务场景来修改数据库
* 需要在自己的数据中心搭建MongoDB集群
* 拥有一批擅长MongoDB的专业人才和运维人才

对于有清晰业务模式的企业，以及能够预计到其业务模式将会带来大规模的用户，那么这类企业应该考虑使用DynamoDB作为其数据服务的技术支持。要想使DynamoDB助力企业发展，则还需了解如何正确使用DynamoDB，这部分的内容将在下一节展开。

对于需要了解DynamoDB基础知识的读者，可以到[DynamoDB学习指南](https://2cloudlab.com/nosql/nosql-index/)。那里包含了大量关于DynamoDB的基础知识，它们从最基本的概念讲起，[什么是DynamoDB](https://2cloudlab.com/nosql/what-is-dynamo-db/)；如何在本地电脑上[安装一个DynamoDB](https://2cloudlab.com/nosql/environment-setup/)，以便读者能在本地实践。紧接着，介绍了关于单项数据以及多项数据的操作，这些操作有[DeleteItem，UpdateItem](https://2cloudlab.com/nosql/updating-deleting-items/)，[PutItem](https://2cloudlab.com/nosql/inserting-retrieving-items/)，[Query](https://2cloudlab.com/nosql/querying/)和[Scan](https://2cloudlab.com/nosql/scans/)。在这个过程中还应用了[条件表达式](https://2cloudlab.com/nosql/expression-basics/)，比如[Filter表达式](https://2cloudlab.com/nosql/filtering/)。除了一些基础知识之外，还包括一些有用的例子，比如如何在DynamoDB中表示[层级结构的数据](https://2cloudlab.com/nosql/hierarchical-data/)，如何在DynamoDB中实现一个[冠军榜](https://2cloudlab.com/nosql/leaderboard-write-sharding/)来展示Top 3的数据。如果你决定使用DynamoDB作为数据服务的基础，下一站将会是[如何正确使用DynamoDB](https://2cloudlab.com/nosql/how-to-use-dynamodb-effectively/)。