---
layout: page
title: AIClash 评测平台介绍
---

这是一个可以评测应用于路径搜索的智能算法的多玩家对抗沙箱程序. (限在 Chrome 浏览器下运行)

## 背景

在 AICLASH 竞技场上, 两支队伍的各三只地精(gnome)分别踏上了直捣对方老巢的征途. 

## 规则

游戏规则与传统走迷宫游戏近似, 但略有不同. 各由三只地精组成的两支队伍从矩形网格地图的左上角和右下角出发, 目的地为对方的起点. 

### 地图

游戏地图为一个 `200 × 150` 的格子网络. 每个格子(cell)与其上, 下, 左, 右可以有连接, 其中处在边界上的格子在边界外方向上无连接. 地图由随机的 Kruskal 算法生成, 源码见[此处]({{ site.baseurl }}/assets/js/lib/map.js). 

在游戏中连接状态用一个数字表示. 
设 `c` 为一个格子: 

* 若 `c & 1 > 0` 则 `c` 与上方方格连通, 
* 若 `c & 2 > 0` 则 `c` 与右方方格连通, 
* 若 `c & 4 > 0` 则 `c` 与下方方格连通, 
* 若 `c & 8 > 0` 则 `c` 与左方方格连通. 

游戏中地图的代码结构: 

    var map = [
        [
            1, 
            2, 
            9, 
            ...
        ], 
        ...
    ];

除地图连通性数据外, 选手还会得到一个描述对手在地图上经过次数的对象: 

    var visited = {
        [
            2, 
            3, 
            3, 
            ... 
        ]
        ...
    };

地图的左下角和右上角分别有一个持久 buff 药水, 先到此处的地精会使用并使自己的视野增加一倍, 若有两只地精在同一 tick 到达, 只有一只会得到此 buff([哪一只? ](javascript:alert('猜');)). 

### 地精

每个队伍有三只地精, 每只地精包含横坐标, 纵坐标和视野三个状态. 地精的视野初始值为 15, 也就是可以看到曼哈顿距离(Manhattan distance)为 15 的格子, 两点间曼哈顿距离定义为两点横坐标之差的绝对值与纵坐标之差的绝对值的和. 视野会在得到 buff 后有相应的变化. 

    var gnome = {
        x: 0, 
        y: 0, 
        vision: 15
    };

### 运行机制

每一个 tick 双方的代码会被调用一次, 给出包含地图, 自己队伍地精状态的数据, 并要求返回一个操作数组. 游戏后台会检查操作数组并根据其中的指令操作地精向指定方向前进一步, 若选手给出的操作指令不合法(比如向不连通的方向前进或给出的操作不符合规范), 对应的地精会随机走向一个可用的方向. 随后会标记访问状态数组, 检查是否有 buff 被触发, 检查游戏是否结束(开发版不会检查结束). 

### 起始状态和终止条件

游戏开始时, 双方地精均分别在左上角和右下角. 地精视野为 15. 

当以下条件之一被满足时, 游戏结束(开发版并未设置此判断): 

* 有任一方地精到达另一方起点时; 
* 游戏时间超过 600 秒; 

### 胜负判定

若游戏结束时, 仅有一方达到另一方起点, 则达到起点所在的玩家赢的比赛, 否则为平局. 

### 积分制度

比赛将采用[等级分制度](http://en.wikipedia.org/wiki/Elo_rating_system)积分, 最终将生成排名结果返回给主办方处理. 

## 参赛入门

本评测平台接收 JavaScript 代码, 点击[此处](http://bonsaiden.github.io/JavaScript-Garden/zh/)学习 JavaScript. 

（（或者, 选手也可以编写其他语言代码并编译至 JavaScript, [这里](https://github.com/jashkenas/coffee-script/wiki/List-of-languages-that-compile-to-JS)有一些可选的编译器, 如果选手想用的语言当前没有可用编译至 JavaScript 的编译器, 那么也可以自行编写编译器或者使用其他编译器编译至机器码或 bitcode 或 bytecode 之后再编译至 asm.js 或者 PNaCl. 

### 选手应该提供什么? 

选手应提供一份可制行的 JavaScript 代码, 其中有注册 `onMyTurn` 的函数, 且该函数返回一个包含三个数字的数组. 例如: 

    onMyTurn = function() {
        return [0, 0, 0];
    };

注意: 此代码返回不可用操作, 实际执行表现为随机游走. 

另有一个拙劣的例子: [这里](http://goo.gl/R4cS4k), 如果打不开的话可能是被墙了, 就点[这个链接]({{ site.baseurl }}/sandbox/#dmFyIGdub21lRGlyID0gW107CnZhciBpZkZpcnN0TW92ZSA9IHRydWU7CgpmdW5jdGlvbiB0dXJuTGVmdChkaXIpIHsKICAgIGRpciA+Pj0gMTsKICAgIGlmKGRpciA9PT0gMCkgewogICAgICAgIGRpciA9IDg7CiAgICB9CiAgICByZXR1cm4gZGlyOwp9CgpmdW5jdGlvbiB0dXJuUmlnaHQoZGlyKSB7CiAgICBkaXIgPDw9IDE7CiAgICBpZihkaXIgPiA4KSB7CiAgICAgICAgZGlyID0gMTsKICAgIH0KICAgIHJldHVybiBkaXI7Cn0KCmZ1bmN0aW9uIGNoZWNrKGdhbWUsIHNyYywgZGlyKSB7CiAgICBpZigoZ2FtZS5tYXAuZGF0YVtzcmMueF1bc3JjLnldICYgZGlyKSA+IDApIHsKICAgICAgICByZXR1cm4gdHJ1ZTsKICAgIH0gZWxzZSB7CiAgICAgICAgcmV0dXJuIGZhbHNlOwogICAgfQp9Cgpvbk15VHVybiA9IGZ1bmN0aW9uKGdhbWUpIHsKICAgIGlmKGlmRmlyc3RNb3ZlKSB7CiAgICAgICAgaWZGaXJzdE1vdmUgPSBmYWxzZTsKICAgICAgICBpZihnYW1lLmdub21lc1swXS54ID09PSAwKSB7CiAgICAgICAgICAgIGdub21lRGlyWzBdID0gMjsKICAgICAgICAgICAgZ25vbWVEaXJbMV0gPSA0OwogICAgICAgIH0gZWxzZSB7CiAgICAgICAgICAgIGdub21lRGlyWzBdID0gMTsKICAgICAgICAgICAgZ25vbWVEaXJbMV0gPSA4OwogICAgICAgIH0KICAgIH0KICAgIHZhciBhY3Rpb24gPSBbXTsKICAgIGdub21lRGlyWzBdID0gdHVyblJpZ2h0KGdub21lRGlyWzBdKTsKICAgIHdoaWxlKGNoZWNrKGdhbWUsIGdhbWUuZ25vbWVzWzBdLCBnbm9tZURpclswXSkgIT09IHRydWUpIHsKICAgICAgICBnbm9tZURpclswXSA9IHR1cm5MZWZ0KGdub21lRGlyWzBdKTsKICAgIH0KICAgIGFjdGlvblswXSA9IGdub21lRGlyWzBdOwogICAgZ25vbWVEaXJbMV0gPSB0dXJuTGVmdChnbm9tZURpclsxXSk7CiAgICB3aGlsZShjaGVjayhnYW1lLCBnYW1lLmdub21lc1sxXSwgZ25vbWVEaXJbMV0pICE9PSB0cnVlKSB7CiAgICAgICAgZ25vbWVEaXJbMV0gPSB0dXJuUmlnaHQoZ25vbWVEaXJbMV0pOwogICAgfQogICAgYWN0aW9uWzFdID0gZ25vbWVEaXJbMV07CiAgICB2YXIgYXZhaWxhYmxlQWN0aW9ucyA9IFtdOwogICAgZm9yKHZhciBpID0gMTsgaSA8IDE2OyBpICo9IDIpIHsKICAgICAgICBpZihjaGVjayhnYW1lLCBnYW1lLmdub21lc1syXSwgaSkgPT09IHRydWUpIHsKICAgICAgICAgICAgYXZhaWxhYmxlQWN0aW9ucy5wdXNoKGkpOwogICAgICAgIH0KICAgIH0KICAgIGFjdGlvblsyXSA9IGF2YWlsYWJsZUFjdGlvbnNbTWF0aC5mbG9vcihNYXRoLnJhbmRvbSgpICogYXZhaWxhYmxlQWN0aW9ucy5sZW5ndGgpXTsKICAgIHJldHVybiBhY3Rpb247Cn07Cn92YXIgZ25vbWVEaXIgPSBbXTsKdmFyIGlmRmlyc3RNb3ZlID0gdHJ1ZTsKCmZ1bmN0aW9uIHR1cm5MZWZ0KGRpcikgewogICAgZGlyID4+PSAxOwogICAgaWYoZGlyID09PSAwKSB7CiAgICAgICAgZGlyID0gODsKICAgIH0KICAgIHJldHVybiBkaXI7Cn0KCmZ1bmN0aW9uIHR1cm5SaWdodChkaXIpIHsKICAgIGRpciA8PD0gMTsKICAgIGlmKGRpciA+IDgpIHsKICAgICAgICBkaXIgPSAxOwogICAgfQogICAgcmV0dXJuIGRpcjsKfQoKZnVuY3Rpb24gY2hlY2soZ2FtZSwgc3JjLCBkaXIpIHsKICAgIGlmKChnYW1lLm1hcC5kYXRhW3NyYy54XVtzcmMueV0gJiBkaXIpID4gMCkgewogICAgICAgIHJldHVybiB0cnVlOwogICAgfSBlbHNlIHsKICAgICAgICByZXR1cm4gZmFsc2U7CiAgICB9Cn0KCm9uTXlUdXJuID0gZnVuY3Rpb24oZ2FtZSkgewogICAgaWYoaWZGaXJzdE1vdmUpIHsKICAgICAgICBpZkZpcnN0TW92ZSA9IGZhbHNlOwogICAgICAgIGlmKGdhbWUuZ25vbWVzWzBdLnggPT09IDApIHsKICAgICAgICAgICAgZ25vbWVEaXJbMF0gPSAyOwogICAgICAgICAgICBnbm9tZURpclsxXSA9IDQ7CiAgICAgICAgfSBlbHNlIHsKICAgICAgICAgICAgZ25vbWVEaXJbMF0gPSAxOwogICAgICAgICAgICBnbm9tZURpclsxXSA9IDg7CiAgICAgICAgfQogICAgfQogICAgdmFyIGFjdGlvbiA9IFtdOwogICAgZ25vbWVEaXJbMF0gPSB0dXJuUmlnaHQoZ25vbWVEaXJbMF0pOwogICAgd2hpbGUoY2hlY2soZ2FtZSwgZ2FtZS5nbm9tZXNbMF0sIGdub21lRGlyWzBdKSAhPT0gdHJ1ZSkgewogICAgICAgIGdub21lRGlyWzBdID0gdHVybkxlZnQoZ25vbWVEaXJbMF0pOwogICAgfQogICAgYWN0aW9uWzBdID0gZ25vbWVEaXJbMF07CiAgICBnbm9tZURpclsxXSA9IHR1cm5MZWZ0KGdub21lRGlyWzFdKTsKICAgIHdoaWxlKGNoZWNrKGdhbWUsIGdhbWUuZ25vbWVzWzFdLCBnbm9tZURpclsxXSkgIT09IHRydWUpIHsKICAgICAgICBnbm9tZURpclsxXSA9IHR1cm5SaWdodChnbm9tZURpclsxXSk7CiAgICB9CiAgICBhY3Rpb25bMV0gPSBnbm9tZURpclsxXTsKICAgIHZhciBhdmFpbGFibGVBY3Rpb25zID0gW107CiAgICBmb3IodmFyIGkgPSAxOyBpIDwgMTY7IGkgKj0gMikgewogICAgICAgIGlmKGNoZWNrKGdhbWUsIGdhbWUuZ25vbWVzWzJdLCBpKSA9PT0gdHJ1ZSkgewogICAgICAgICAgICBhdmFpbGFibGVBY3Rpb25zLnB1c2goaSk7CiAgICAgICAgfQogICAgfQogICAgYWN0aW9uWzJdID0gYXZhaWxhYmxlQWN0aW9uc1tNYXRoLmZsb29yKE1hdGgucmFuZG9tKCkgKiBhdmFpbGFibGVBY3Rpb25zLmxlbmd0aCldOwogICAgcmV0dXJuIGFjdGlvbjsKfTsK). 

详见[接口文档]({{ site.baseurl }}/api/). 

## 评测沙箱使用方法

### 操作说明

选手将自己的代码输入至代码编辑器之后, 点击 `Start` 按钮即可开始运行. 

### 调试

由于我们的评测平台在线版本使用 web worker 机制防止选手作弊, 所以调试时需要在 Chrome 中打开 worker 调试面板, [这里](http://www.nczonline.net/blog/2009/08/25/web-workers-errors-and-debugging/)和[这里](http://blog.csdn.net/donghao526/article/details/9664701)讲述了 web worker 中代码的调试方法. 

调试时打开 Chrome 开发者工具, 装载代码(点击 `Load` )完毕后, 在 `Sources` 标签中的右侧点击 `Workers` 打开 Web Worker 调试窗口, 这里的 `Source` 标签中, `(no domain)` 下的代码即为调试选手提交的脚本. 

_注意: 每次装载都会产生新的 Web Worker 线程, 需要重新打开 Web Worker 调试窗口. _

## 关于

作者: Simonmysun

<!--鸣谢: Friends-->

## 版权和开放许可 - Copyright & Licence

### 平台代码 - Code of the platform

MIT

### 使用者提交的代码 - Code of participant
使用者提交的内容指从本网站可以下载的所有数据. 

Code of participant are all data that can be downloaded from the website. 

你可以用这些代码在本网站上运行, 也可以缓存或在本地储存. 但除非原作者(们)许可, 你不能出于任何目的修改或重新发布这些代码. 为了本地测试和实验, 你可以使用你自己修改的而非其他人修改的任何版本的 AIClash. 

You may use the code to play the original Snake-AI as served from this website, and you may cache or copy it locally. However, you may not modify or redistribute the code for any purpose unless you have a separate license from the owner(s) to do so. To enable local testing and experimenting, you may use the code with versions of AIClash that you yourself have modified, but not if the modifications were made by someone else.
