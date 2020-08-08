---
title: "Terraform、aws-vault和Go实用技巧指南"
date: 2020-03-15T12:21:58+06:00
description : "本文记录了2cloudlab.com在使用Terraform、aws-vault和Go工具所积累的知识和经验。这些知识和经验是在解决某些问题的时候发现的，如果能够将这些知识和经验汇总，也许能够帮助到其他团队。"
type: post
image: images/blog/terraform-tactics.png
author: 郑思龙
tags: ["Terraform", "自动化经验", "云计算", "Go"]
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

3. Terraform提供`for_each`指令来遍历一个`map`对象，并根据该对象的键值对`each.key`和`each.value`来创建资源

```terraform
locals {
  buckets = {
    bucket1 = "2cloudlab-your-unique-bucket-name-1"
    bucket2 = "2cloudlab-your-unique-bucket-name-2"
  }
}

resource "aws_s3_bucket" "b" {
  for_each     = local.buckets
  bucket = each.value
}

output "results" {
  value = aws_s3_bucket.b
}
```

以上命令将生成2个S3资源，名字分别是`2cloudlab-your-unique-bucket-name-1`和`2cloudlab-your-unique-bucket-name-2`，运行结果如下所示（为了方便显示和阅读，我已经将无关紧要的信息剔除）：

```bash
results = {
  "bucket1" = {
    "bucket" = "2cloudlab-your-unique-bucket-name-1"
  }
  "bucket2" = {
    "bucket" = "2cloudlab-your-unique-bucket-name-2"
  }
}
```

4. 如何在Terraform中将数组转化成字典

```bash
my_map = {
    for i in range(1, 11, 2):
    format("%d", i) => format("%s-%d", "prefix", i)
  }
```

`range(1, 11, 2)`将生成数组[1,3,5,7,9]，运行以上指令将得到以下结果：

```bash
{
  "1" = "prefix-1"
  "3" = "prefix-3"
  "5" = "prefix-5"
  "7" = "prefix-7"
  "9" = "prefix-9"
}
```

## Go实用技巧

1. 如何使用Go来运行某一个测试用例（比如定义了一个TestIntegrationOrganization测试用例）？

```go
go test -v -run TestIntegrationOrganization
```

2. 如何根据tag(`+build integration`)来执行一组测试用例？

```go
// intergration_test.go
// +build integration

func TestCase1(t *testing.T) {
    // ...
}

func TestCase2(t *testing.T) {
    // ...
}
```

在文件*intergration_test.go*中指定tag：`// +build integration`，运行以下命令将执行该文件中的所有自动化测试用例。

```bash
go test -v -run -tags=integration
```

3. Go Concurrency: Confinement, for-select and done channel

```go
//Confinement that channels done, inputStream is read only, and the return value resultsStream is also read only
func func1(done <-chan interface{}, inputStream <-chan interface{}) <-chan interface{} {
	//Create unbuffer channel in lexical scope
	resultsStream := make(chan interface{})
	// Launch another go routine to handle task and generate result which is passed to resultsStream
	go func() {
		defer close(resultsStream)
		for {
			select {
			case <-done:
				//Cancel by parent
				return
			case <-inputStream:
				//Read from input stream
				result := 1
				resultsStream <- result
			default:
				//Continual monitoring
			}
		}
	}()
	return resultsStream
}
```

4. 使用or-channel来检测多任务中某个任务是否完成：

```go
func or(channels ...<-chan interface{}) <-chan interface{} {
	switch len(channels) {
	case 0:
		return nil
	case 1:
		return channels[0]
	}
	orDone := make(chan interface{})
	go func() {
		defer close(orDone)
		switch len(channels) {
		case 2:
			select {
			case <-channels[0]:
			case <-channels[1]:
			}
		default:
			select {
			case <-channels[0]:
			case <-channels[1]:
			case <-channels[2]:
			case <-or(append(channels[3:], orDone)...):
			}
		}
	}()
	return orDone
}
```

5. Fan-out vs tee 模式

![](https://2cloudlab.com/images/blog/tee-vs-fanout-patterns.png)

**fan-out**

```go
numFinders := runtime.NumCPU()
finders := make([]<-chan int, numFinders)
for i := 0; i < numFinders; i++ {
    finders[i] = primeFinder(done, randIntStream)
}
```

**tee**

```go
tee := func(
    done <-chan interface{},
    in <-chan interface{},
) (_, _ <-chan interface{}) { <-chan interface{}) {
    out1 := make(chan interface{})
    out2 := make(chan interface{})
    go func() {
        defer close(out1)
        defer close(out2)
        for val := range orDone(done, in) {
            var out1, out2 = out1, out2
            for i := 0; i < 2; i++ {
                select {
                case <-done:
                case out1<-val:
                    out1 = nil
                case out2<-val:
                    out2 = nil
                }
            }
        }
    }()
    return out1, out2
}
```

6. Fan-in vs bridge 模式

![](https://2cloudlab.com/images/blog/bridge-fanin-patterns.png)

**fan-in**

```go
fanIn := func(
    done <-chan interface{},
    channels ...<-chan interface{},
) <-chan interface{} {
    var wg sync.WaitGroup
    multiplexedStream := make(chan interface{})

    multiplex := func(c <-chan interface{}) {
        defer wg.Done()
        for i := range c {
            select {
            case <-done:
                return
            case multiplexedStream <- i:
            }
        }
    }

    // Select from all the channels
    wg.Add(len(channels))
    for _, c := range channels {
        go multiplex(c)
    }

    // Wait for all the reads to complete
    go func() {
        wg.Wait()
        close(multiplexedStream)
    }()

    return multiplexedStream
}
```

**bridge**

```go
bridge := func(
    done <-chan interface{},
    chanStream <-chan <-chan interface{},
) <-chan interface{} {
    valStream := make(chan interface{})
    go func() {
        defer close(valStream)
        for {
            var stream <-chan interface{}
            select {
            case maybeStream, ok := <-chanStream:
                if ok == false {
                    return
                }
                stream = maybeStream
            case <-done:
                return
            }
            for val := range orDone(done, stream) {
                select {
                case valStream <- val:
                case <-done:
                }
            }
        }
    }()
    return valStream
}
```

7. 为什么使用context package，以及它是如何帮助你解决问题的

假设你启动了一个goroutine（父亲），它同时启动了多个goroutines（孩子），那么你将面临以下问题：

* 如果将一些通用的信息流转于各个goroutines？
* 如果父亲goroutine不需要其孩子goroutines的计算结果了，如何取消孩子goroutines，以便释放资源？
* 由于业务需要，要求某个goroutine的执行时间不超过某段时间，比如2秒。如果超过这段时间，应该如何停止该goroutine的执行？
* 由于业务需要，要求某个goroutine的执行时间不超过某个时间点，比如5:00 PM。如果超过这个时间点，应该如何停止该goroutine的执行？

如果你所在的业务场景中面临以上问题，那么则需要借助Go中的标准库context。通过使用该库，你可以针对调用图来定义context tree，比如下图：

![](https://2cloudlab.com/images/blog/goroutine-flow-vs-context-flow.png)

[Using Context Package in GO (Golang) – Complete Guide](https://golangbyexample.com/using-context-in-golang-complete-guide/)

8. value receiver 与 pointer receiver的区别

* value receiver指明，调用接口过程中拷贝一份新的对象，因此对新对象进行修改，不会影响原来的对象
* pointer receiver指明，调用接口过程中只会传递原来对象的地址，因此对该地址所指向的对象进行修改则会直接改变原对象

以下例子说明了这一点：

```go
package main

import (
	"fmt"
)

type Shape interface {
	DoubleArea() float64
}

type Rect struct {
	Width  float64
	Height float64
}

type Circle struct {
	Radius float64
}

func (s *Rect) DoubleArea() float64 {
	fmt.Println(fmt.Sprintf("Width is %f, Height is %f", s.Width, s.Height))
	s.Width *= 1.414
	s.Height *= 1.414
	return s.Width * s.Height
}

func (s Circle) DoubleArea() float64 {
	fmt.Println(fmt.Sprintf("Radius is %f", s.Radius))
	s.Radius *= 1.414
	return s.Radius * s.Radius * 3.14
}

func main() {
	// pointer receiver
	fmt.Println("[Pointer receiver]")
	var s Shape = &Rect{Width: 1.0, Height: 1.0}
	s.DoubleArea()
	fmt.Println(fmt.Sprintf("After double area, the Width is %f", s.(*Rect).Width))

	fmt.Println("-----------------------------")

	// value receiver
	fmt.Println("[Value receiver]")
	var c Shape = Circle{Radius: 1.0}
	c.DoubleArea()
	fmt.Println(fmt.Sprintf("After double area, the Radius is %f", c.(Circle).Radius))
}
```

运行以上程序的输出结果如下：

```bash
[Pointer receiver]
Width is 1.000000, Height is 1.000000
After double area, the Width is 1.414000
-----------------------------
[Value receiver]
Radius is 1.000000
After double area, the Radius is 1.000000
```

## 组合Terraform、aws-vault和Go工具的实用技巧

1. 如何使用aws-vault和Go工具来操作AWS服务？

```go
aws-vault exec fans55 --no-session -- go test -v -run TestIntegrationOrganization
```