# 网络编程—服务器

练习项目：使用BSD Socket实现HTTP Server的GET和POST方法，可以上传文件

## 实现的功能

- [x] GET - 返回静态网页
- [x] POST-通过表单提交图片文件，并在客户端展示

### 具体细节

#### socket连接相关

- [x] 监听连接的主socket创建
  - [x] 使用dispatch source监听连接事件
  - [x] 创建每一个连接sockets创建线程
    - [x] dispatch queue
- [x] 数据接收
  - [x] prebuffer
  - [x] package 用tag来区分
- [x] 读取
  - [x] 固定长度
  - [x] 指定结束符
- [x] 写数据
  - [x] packageWrite

#### HTTP相关

- [x] iOS中CFNetwork中有相关实现CFHTTP API 如CFHTTPMessageRef
  - [x] HTTP Connect与 TCP socket连接的对应关系问题
    - [x] 服务器建立的HTTP Connect 就是一个 socket connect连接，要接收读写数据
- [x] Header解析 收到一部分就解析一部分 ，可能对此回调才解析完一个header
  - [x] request解析
    - [x] 目标是支持简单的GET 、POST方法—通过url返回文件夹下的文件（静态网页功能）和文件上传方法
- [x] 如何断开连接
  - [x] HTTP ：1.0？每次连接只处理一个request 服务器处理完客户的请求，并收到客户的应答后，即断开连接。采用这种方式可以节省传输时间
    - [x] 1.1可以一个连接有多个请求，—  断开方式不同，还有就是header字段
    - [x] http协议1.1版本不是直接就断开了，而是等几秒钟，这几秒钟是等什么呢，等着用户有后续的操作，如果用户在这几秒钟之内有新的请求，那么还是通过之前的连接通道来收发消息，如果过了这几秒钟用户没有发送新的请求，那么就会断开连接，这样可以提高效率，减少短时间内建立连接的次数，因为建立连接也是耗时的，默认的好像是3秒中现在，但是这个时间是可以通过咱们后端的代码来调整的，自己网站根据自己网站用户的行为来分析统计出一个最优的等待时间

- [x] Requeset解析
  - [x] 分步解析
    - [x] 获取Header数据 --  关键分隔符—header结束分隔符 /r/n/r/n
    - [x] 解析Header字段
      - [x] 行分隔符 —  /r/n
      - [x] 解析基础信息-状态信息
    - [x] 解析Body
      - [x] 通过header里面的Content-Length获取body长度
      - [x] boundary+Multipart
        - [x] part header解析
  - [x] 数据读取
    - [x] 所有的header一次性获取  /n/r/n/r 作为header和body的结束标记
    - [x] 按照行读取，如状态行，header中的字段行，然后是body读取

- [x] response生成
  - [x] 返回指定文件
  - [x] 状态码
  - [x] header数据
  - [x] body
