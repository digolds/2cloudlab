---
title: "Go编程的奇幻之旅（一）基础知识"
date: 2019-12-15T12:21:58+06:00
description : "本文将指导你如何准备Go研发环境以及介绍一些基础语法知识。这些内容能够帮助你快速地在企业中应用Go语言所带来的好处。这些好处有：跨平台、丰富的三方库、并发和内置自动化测试功能。"
type: post
image: images/blog/Golang.png
author: 郑思龙
tags: ["Go", "并发", "编程"]
---

本文将指导你如何准备Go研发环境以及介绍一些基础语法知识。这些内容能够帮助你快速地在企业中应用Go语言所带来的好处。这些好处有：跨平台、丰富的三方库、并发和内置自动化测试功能。本文将按照以下几个方面来介绍Go：

1. 下载和安装Go
2. 选择IDE
3. Go常用的命令
4. Go的内置类型
5. 流程控制
6. 并发
7. 错误处理
8. 结构化数据的转化

## 下载和安装Go

在使用Go编程时，首先需要下载和安装Go研发环境。读者可以到其[官方网站](https://golang.org/dl/)下载。下载完成之后是安装Go研发环境，假设安装路径为`/path/to/go`。

安装完成之后需要配置环境变量`GOROOT`，根据不同的平台设置环境变量的命令是不一样的，如下所示：

* Linux和macOS平台

```bash
export GOROOT=/path/to/go
```

* Window平台

```bash
setx GOROOT "\path\to\go"
```

环境变量`GOROOT`的作用是告诉系统Go语言的安装路径，以便当执行go命令时能够找到可执行性文件。除了要设置`GOROOT`，还需要设置环境变量`GOPATH`。Go所提供的工具集依赖于`GOPATH`，所有源码、三方库以及编译好的程序都会在`GOPATH`所指定的目录下。假设在macOS运行以下指令：

```bash
export GOPATH=$HOME/gocode
```

那么你的所有源码都需要放在`src`目录下，因此，你需要在目录`$HOME/gocode`中创建文件夹`src`。除了使用`src`目录放置Go源码，在目录`$HOME/gocode`中还需要创建目录`bin`和`pkg`。此时的目录结构是：

```bash
gocode
  ├─bin
  ├─pkg
  └─src
```

`bin`放置所有可执行性文件；`pkg`放置Go程序所依赖的3方库；`src`放置了你即将编写的Go程序。

以上步骤操作完成之后，需要执行以下命令来进一步确保Go运行环境安装正确！

```bash
$ go version
go version go1.11.5 linux/amd64
```

## 选择IDE

在开始编写Go程序之前，需要根据自身的情况来选择IDE。以下是一些常用的IDE，使用这些IDE能够提高编程效率！

* [Vim Editor](https://github.com/fatih/vim-go/)
* [GitHub Atom](https://atom.io/)
* [Microsoft Visual Studio Code](https://code.visualstudio.com)

## Go常用的命令

* `go run`

这个命令的作用在于编译并运行*main* *package*，比如以下文件(注意这个文件需要在目录`$GOPATH/src/`中创建):

```go
// $GOPATH/src/test_go_run/main.go
package main
import (
    "fmt"
)
func main() {
    fmt.Println("Hello, 2cloudlab.com!")
}
```
以上代码执行所得到的结果如下所示：

```bash
Hello, 2cloudlab.com!
```

`go run`命令不会生成可执行性文件，如果想要将程序发布给别人使用，那么需要使用以下命令。

* `go build`

这个命令会编译你所编写的Go程序，并生成一个可执行性文件，但是不会执行这个可执行性文件。运行以下命令将生成可执行性文件`main`。

```bash
go build main.go
```

你也可以通过指定`-o`参数来重命名所生成的可执行性文件，比如以下命令将生成`2cloudlab`可执行性文件

```bash
go build -o 2cloudlab main.go
```

以上生成的可执行性文件将包含调试信息和一些符号信息，这些信息会导致所生成的文件变大，因此需要在生成可执行性文件时去掉这些信息。通过添加以下参数来去掉这些信息：

```
go build -ldflags "-w -s" -o 2cloudlab main.go
```

这个时候生成的`2cloudlab`文件将比原来的少30%。

* `GOOS`和`GOARCH`

Go支持在其它平台上编译另外一个平台上的可执行性文件。也就是说，你可以在Windows OS上执行以下指令来生成Linux平台上的可执行性文件。

```bash
GOOS="linux" GOARCH="amd64" go build -ldflags "-w -s" -o 2cloudlab main.go
```

* `go doc`

Go语言提供了大量内置函数，每个内置函数都会提供使用说明。你可以通过使用以下命令来查看某个函数、package或者变量的使用说明。比如通过以下命令来查看`Println`的使用说明：

```bash
go doc fmt.Println
```

运行以上命令的输出结果如下：

```bash
package fmt // import "fmt"

func Println(a ...interface{}) (n int, err error)
    Println formats using the default formats for its operands and writes to
    standard output. Spaces are always added between operands and a newline is
    appended. It returns the number of bytes written and any write error
    encountered.
```

以上命令在Go编程的时候会经常使用，不需要刻意记住，需要使用某个命令的时候，如果忘记了，那么可以再次回来查看本文。接下来，让我们把注意力转向Go语言的编程语法。

## Go的内置类型

Go的内置类型主要分为3类：基础类型、集合类型和复杂类型。

* 基础类型有以下几种

```bash
bool, string, int, int8, int16, int32, int64, uint, uint8, uint16, uint32, uint64, uintptr, byte, rune, float32, float64, complex64, and complex128.
```

以下例子定义了2个变量`x`和`z`：

```go
var x = "Hello World"
z := int(42)
```

其中变量`x`的类型为`string`，变量`z`的类型是`int`

* 集合类型有Slices和Maps

Go内置了2中类型，分别是数组和字典，每种集合类型都有能够删除和添加元素。以下例子定义了这2个类型的变量并为其添加了元素。

```go
var s = make([]string, 0)
var m = make(map[string]string)
s = append(s, "some string")
m["some key"] = "some value"
```

以上代码定义了一个数组变量`s`，这个数组中的元素类型是`string`，`append`函数用于向数组`s`追加一个元素。除此之外还定义了一个字典变量，这个字典变量的key是`string`类型，value也是`string`类型，`m["some key"] = "some value"`表示向`m`字典里添加一个元素。

* 复杂类型有：Pointers、Structs和Interfaces

**pointer**是一块内存的地址，Go语言提供2个关键字`*`和`&`来分别获取这块内存中存储的值和获取这块内存的地址。以下例子定义来了一个指针类型的变量`ptr`：

```go
count := int(100)
ptr := &count
fmt.Println(*ptr)
*ptr = 200
fmt.Println(count)
```

以上代码运行的结果如下：

```bash
100
200
```

**struct**是结构体，通过结构体可以定义更加复杂的数据类型。比如下面的例子定义了一个`Person`结构体，这个结构体有2个属性`Name`和`Age`以及一个方法`SayHi()`

```go
type Person struct {
    Name string
    Age int
}

func (p *Person) SayHello() {
       fmt.Println("Hi! My name is ", p.Name)
}

func main() {
    var guy =  new(Person)
    guy.Name = "2cloudlab.com"
    guy.SayHi()
}
```

运行以上代码将输出以下结果：

```bash
Hi! My name is 2cloudlab.com
```

**interface**是接口类型，这个类型只允许申明一些方法，这些方法由其它具体的结构体来实现。比如以下例子定义了一个接口类型：

```go
type Friend interface {
    SayHi()
}

func Greet(f Friend) {
    f.SayHi()
}

func main() {
    var guy = new(Person)
    guy.Name = "2cloudlab.com"
    Greet(guy)
}
```

运行以上代码将得到以下结果：

```bash
Hi! My name is 2cloudlab.com
```

以上代码定义了一个接口类型`Friend`，结构体类型`Person`实现了`SayHi()`方法，因此可以将Person看成`Friend`类型。

## 流程控制

每个编程语言都会有流程控制，它们主要分为2类：条件控制和循环控制。

* 条件控制

Go的条件控制有2类： `if` 和 `switch`

```go
if x == 1 {
    fmt.Println("X is equal to 1")
} else {
    fmt.Println("X is not equal to 1")
}
```

```go
switch x {
    case "foo":
        fmt.Println("Found foo")
    case "bar":
        fmt.Println("Found bar")
    default:
        fmt.Println("Default case")
}
```

* 循环控制

循环控制有2类：

```go
for i := 0; i < 10; i++ {
    fmt.Println(i)
}
```

```go
nums := []int{2, 4, 6, 8}
for idx, val := range nums {
    fmt.Println(idx, val)
}
```

## 并发

Go语言内置了并发功能，它是通过coroutine来实现并发。Go程序运行的时候只有一个线程，因此coroutine不是线程。开启一个coroutine是通过关键字`go`来实现的，比如：

```go
func f() {
    fmt.Println("goroutine f")
}

func main() {
    go f()    
    fmt.Println("run in other goroutine")
}
```

以上例子的`go`关键字使得函数`f`可以和函数`main`并发执行。但是以上例子有一个问题，如果`main`函数比`f`函数先执行结束，那么`f`函数将无法输出结果，这就是并发所带来的同步问题。要解决这种同步问题，这需要引入Go特有的`chan`类型。接下来让我们看看以下例子是如何解决这类同步问题的：

```go
func f(c chan int) {
    fmt.Println("goroutine f")
    c <-int(1990)
}

func main() {
    c := make(chan int)
    go f(c)
    x := <-c
    fmt.Println("run in other goroutine")
}
```

上面这个例子定义了一个`chan`类型的变量，这个变量的作用是在不同的coroutine中传递信息。`x := <-c`的作用是从变量`c`中读取信息，如果没有信息，那么执行`main`的coroutine则会阻塞，直到`c <-int(1990)`向这个变量填入信息。

## 错误处理

在Go的世界里没有错误处理机制，Go鼓励编写程序的人自己判断可能出现的错误。因此在Go中处理错误的时，通常按照以下方式处理：

```go
func errorHappens() {

}

func main() {
    if err := errorHappens(); err != nil {
        //Handle the error
    }
}
```

## 结构化数据的转化

在传输数据时，经常会处理结构化数据。常用的格式有*Json*和*XML*。Go语言中提供了内置的格式化处理方法，比如以下示例说明了如何将结构化数据转成*Json*格式的字符串：

```go
type Foo struct {
    Bar string
    Baz string
}

func main() {
    f := Foo{"Joe Junior", "Hello Shabado"}
    b, _ := json.Marshal(f)
    fmt.Println(string(b))
    json.Unmarshal(b, &f)
}
```

运行以上代码将输出以下结果:

```bash
{"Bar":"Joe Junior","Baz":"Hello Shabado"}
```