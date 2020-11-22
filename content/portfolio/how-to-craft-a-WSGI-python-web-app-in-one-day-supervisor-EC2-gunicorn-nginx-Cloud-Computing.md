---
title: "如何在一天之内上线一款WSGI兼容的Python Web App"
type: portfolio
date: 2018-07-12T16:53:54+06:00
description : "如何在一天之内上线一款WSGI兼容的Python Web App"
caption: EC2, Load Balance, Cloud Computing, Python, Nginx, supervisor, gunicorn, Web Development
image: images/blog/2cloudlab-cloud-computing-python-nginx-gunicorn-supervisor-light-blog.PNG
category: ["EC2","Load Balance"]
liveLink: https://2cloudlab.com
client: 2cloudlab.com
submitDate: November 20, 2017
location: 2cloudlab.com
---

# 如何在一天之内上线一款WSGI兼容的Python Web App

这篇指南将通过以下4步来帮助你**在一天之内上线一款WSGI兼容的Python Web App**：

* 开箱即用的云原生解决方案
* 现实情况
* 准备和实现
* 具体案例
* 存在的问题

## 开箱即用的云原生解决方案

[module\_load\_balancer](https://github.com/2cloudlab/module_load_balancer)模块用于创建WSGI兼容Web App所依赖的环境，非常**适合只有Python技术栈**的团队。在使用它之前，你需要参考[这里来准备研发环境和了解一些注意事项](https://www.digolds.cn/article/001605969144845d618aa67ad2f4f5a890c0a43d5aa5f71000)。这个解决方案能够帮助你创建以下环境，你只需要提供图中Web App部分（它是基于Python来编写的并且是WSGI兼容的）。

![](https://2cloudlab.com/images/blog/load-balance-EC2-cloud-computing-gunicorn-supervisor-WSGI-python-web-app-environment-overview.png)

## 现实情况

你拥有一支非常擅长Python的研发团队，然而却缺乏DevOps和软件工程经验。你迫切希望，你的团队能够研发一款面向互联网的服务，并能快速接入互联网。

## 准备和实现

**首先**，你需要使用Python研发一个Web App，它是WSGI兼容的，然后将其打包成`tar.gz`格式，包中的目录结构如下所示：

```bash
.
  |-web-app-root
  |  |-web-app
  |  |  |-wsgiapp.py
  |  |-requirements.txt
```

1. `web-app-root`是包中的根目录，你可以重命名成其它
2. `web-app`是你的Web App所有可执行性文件所在的目录
3. `wsgiapp.py`是你的Web App的入口，里面定义了一个WSGI对象
4. `requirements.txt`是你的Web App所依赖的Python库

**其次**，你需要创建*main.tf*文件，内容如下：

```bash
terraform {
  required_version = "= 0.12.19"
}

provider "aws" {
  version = "= 2.58"
  region = "ap-northeast-1"
}

module "load_balance" {
  source       = "github.com/2cloudlab/module_load_balancer//modules/load_balancer?ref=<tag>"
  download_url = <your-WSGI-Compatible-Python-Package-URL>
  package_base_dir         = <your-root-folder-name-in-web-app-package>
  app_dir = <your-web-app-folder>
  envs     = <your-app-environment-variables>
  wsgi_app = <WSGI-Entry>
}

output "alb_dns_name" {
  value       = module.load_balance.alb_dns_name
  description = "The domain name of the load balancer"
}
```

你只需要指定以下几点

1. `ref=<tag>`中的`tag`需要替换成该模块的版本号，比如*v.0.0.3*
2. `download_url`指向了WSGI兼容的Web App的*tar.gz*包，比如"https://github.com/digolds/digolds_sample/archive/v0.0.1.tar.gz"
3. `package_base_dir`是*tar.gz*中的根目录
4. `app_dir`是WSGI兼容的Web App所有执行文件所在*tar.gz*中的目录
5. `envs`是WSGI兼容的Web App所依赖的环境变量
6. `wsgi_app`是WSGI兼容的Web App的调用入口，关于该模块的详细用法，你可以参考[这里](https://github.com/2cloudlab/module_load_balancer)

指定之后，`cd`到*main.tf*所在的目录，然后执行以下命令来创建WSGI兼容的Web App：

```bash
terraform init
terraform plan
terraform apply
```

成功之后，你将看到以下类似的输出：

```bash
Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = alb-1-712872544.us-west-1.elb.amazonaws.com
```

等待几分钟之后，你的WSGI兼容的Web App就已经在互联网中运行了，此时，你可以在浏览器里输入`alb_dns_name`所对应的值，来查看结果。

以上脚本帮你做了2件事情：

1. 下载你的WSGI兼容的Web App包
2. 在互联网上创建一个负载均衡器ALB（用于分发请求）、一族EC2实例（每个实例对应一台虚拟机，并运行着你的WSGI兼容的Web App、Nignx、gunicorn、supervisor）、一个Auto Scale资源（用于自动增加或减少EC2实例）

## 具体案例

下面，我将通过一个案例来说明这个模块的使用。假设，**你想上线一款轻博客服务**，它是用Python来实现的，而且兼容WSGI规范，这个博客应用的源码托管在[这里](https://github.com/digolds/digolds_sample)，它对外发布的完整的*tar.gz*包存储在这里："https://github.com/digolds/digolds_sample/archive/v0.0.1.tar.gz"，包中的目录结构如下所示：

```bash
.
  |-digolds_sample-0.0.1
  |  |-.gitignore
  |  |-deployment
  |  |  |-load-balancer
  |  |  |  |-main.tf
  |  |  |  |-service.sh
  |  |  |-nosql
  |  |  |  |-main.tf
  |  |-personal-blog
  |  |  |-controllers
  |  |  |  |-articles_controller.py
  |  |  |  |-main_controller.py
  |  |  |  |-sign_in.py
  |  |  |-favicon.ico
  |  |  |-middlewares
  |  |  |  |-logger_middleware.py
  |  |  |-model
  |  |  |  |-articles_content.py
  |  |  |  |-in_memory_db.py
  |  |  |-static
  |  |  |  |-images
  |  |  |  |  |-digolds.png
  |  |  |-views
  |  |  |  |-blogs.html
  |  |  |  |-edit-article.html
  |  |  |  |-home.html
  |  |  |  |-sign-in.html
  |  |  |  |-single_article.html
  |  |  |  |-__base__.html
  |  |  |-wsgiapp.py
  |  |-requirements.txt
```

其中*wsgiapp.py*中的内容如下所示，尤其是要注意最后一行，我定义了一个WSGI对象`wsgi_app`：

```python
#!/usr/bin/env python

__author__ = 'SLZ'

'''
digwebs framework demo.
'''

import logging
logging.basicConfig(level=logging.INFO)

from digwebs.web import get_app
import os
dir_path = os.path.dirname(os.path.realpath(__file__))
digwebs_app = get_app({'root_path':dir_path})
digwebs_app.init_all()
if __name__ == '__main__':
    import os
    os.environ['TABLE_NAME'] = 'personal-articles-table'
    os.environ['INDEX_NAME'] = 'ContentGlobalIndex'

    os.environ['USER_NAME'] = 'slz'
    os.environ['PASSWORD'] = 'abc'
    digwebs_app.run(9999, host='0.0.0.0')
else:
    wsgi_app = digwebs_app.get_wsgi_application()
```

接下来，编写一个*main.tf*文件，其内容如下所示：

```bash
terraform {
  required_version = "= 0.12.19"
}

provider "aws" {
  version = "= 2.58"
  region = "ap-northeast-1"
}

data "terraform_remote_state" "dynamodb" {
  backend = "local"

  config = {
    path = "../nosql/terraform.tfstate"
  }
}

module "load_balance" {
  source       = "github.com/2cloudlab/module_load_balancer//modules/load_balancer?ref=v0.0.4"
  download_url = "https://github.com/digolds/digolds_sample/archive/v0.0.1.tar.gz"
  package_base_dir         = "digolds_sample-0.0.1"
  app_dir = "personal-blog"
  envs     = ["USER_NAME=slz", "PASSWORD=abc"]
  wsgi_app = "wsgiapp:wsgi_app"
}

output "alb_dns_name" {
  value       = module.load_balance.alb_dns_name
  description = "The domain name of the load balancer"
}
```

在上面的脚本中，你要特别注意以下变量与之前的目录结构的关系：

* `download_url`
* `package_base_dir`
* `app_dir`

另外由于这个博客应用会用到环境变量*USER_NAME*和*PASSWORD*，因此我通过`envs`来设置博客应用所需的环境变量。

最后，我在*wsgiapp.py*文件里定义了一个WSGI对象`wsgi_app`，因此变量`wsgi_app`的值应该如下所示：

```bash
wsgi_app = "wsgiapp:wsgi_app"
```

`cd`到文件*main.tf*所在的目录，执行以下指令来上线这个博客应用：

```bash
terraform init
terraform apply
```

成功之后，你将看到以下输出结果：

```bash
Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = alb-1-712872544.us-west-1.elb.amazonaws.com
```

你必须等待几分钟左右，然后在浏览器中输入*alb\_dns\_name*所指向的url，访问这个博客应用，结果页面如下所示：

![](https://2cloudlab.com/images/blog/2cloudlab-cloud-computing-python-nginx-gunicorn-supervisor-light-blog.PNG)

## 存在的问题

这个开箱即用的解决方案依然存在许多问题，如下所示：

1. 它目前只支持80端口
2. 在创建成功之后，你需要等待大约几分钟的时间，才能上线Web App
3. 如果你需要更新Web App
4. 由于这套方案创建了ALB，一族EC2实例，因此这些资源如果闲置的时候依然会计费