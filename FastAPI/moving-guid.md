# 浅红⾊⽂字：<font color="#dd0000" size='6'>Moving from Flask to FastAPI</font>

Flask,一个Web框架，就是这样一种工具,在机器学习社区中很受欢迎。它也被广泛用于API开发.但有一个新的框架正在兴起：FastAPI.与Flask不同,FastAPI是一个ASGI（异步服务器网关接口）框架.与Go和NodeJS一样,FastAPI是最快的基于Python的Web框架之一.

本文面向那些有兴趣从 Flask 迁移到 FastAPI 的人,比较和对比了 Flask 和 FastAPI 中的常见模式。

## FastAPI vs Flask

FastAPI的构建考虑了以下三个主要问题：

- 速度
- 开发人员体验
- 开放标准

您可以将FastAPI视为将Starlette，Pydantic，OpenAPI和JSON Schema结合在一起的粘合剂。

- 在引擎盖下，FastAPI使用Pydantic进行数据验证，使用Starlette进行工具，与Flask相比，它的速度非常快，与Node或Go中的高速Web API具有相当的性能。
- Starlette + Uvicorn 提供了 async 请求功能，这是 Flask 所缺乏的。
使用Pydantic和类型提示，您可以通过自动完成获得良好的编辑器体验。您还可以获得数据验证、序列化和反序列化（用于构建 API）以及自动文档（通过 JSON Schema 和 OpenAPI）。
- 也就是说，Flask的使用范围要广泛得多，因此它经过了实战测试，并且有一个更大的社区支持它。由于这两个框架都是要扩展的，因此Flask由于其庞大的插件生态系统而成为明显的赢家。

>**建议:**

- 如果您与上述三个问题产生共鸣，厌倦了 Flask 扩展时的大量选择，希望利用异步请求，或者只是想建立一个 RESTful API，请使用 FastAPI。
- 如果您对 FastAPI 的成熟度级别不满意，需要构建具有服务器端模板的全栈应用程序，或者没有一些社区维护的 Flask 扩展，请使用 Flask。

## 开始

### 安装

像任何其他Python包一样，安装相当简单。

***flask***

```shell
pip install flask

# or
poetry add flask
pipenv install flask
conda install flask
```

***fastAPI***

```shell
pip install fastapi uvicorn

# or
poetry add fastapi uvicorn
pipenv install fastapi uvicorn
conda install fastapi uvicorn -c conda-forge
```

与Flask不同，FastAPI没有内置的开发服务器，因此需要像Uviono或Daphne这样的ASGI服务器。

### "Hello World" 应用程序

***flask***

```python
# flask_code.py

from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return {"Hello": "World"}

if __name__ == "__main__":
    app.run()
```

***fastAPI***

```python
# fastapi_code.py

import uvicorn
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def home():
    return {"Hello": "World"}

if __name__ == "__main__":
    uvicorn.run("fastapi_code:app")

```

可以传递诸如之类的参数以启用热重载以进行开发。

```python
reload=True uvicorn.run()
```

或者，您可以直接从终端启动服务器：

```shell
uvicorn run fastapi_code:app
```

对于热重载：

```shell
uvicorn run fastapi_code:app --reload
```

### 配置

Flask和FastAPI都提供了许多选项，用于处理不同环境的不同配置。两者都支持以下模式：

- 环境变量
- 配置文件
- 实例文件夹 (Instance Folder)
- 类和继承

有关详细信息，请参阅其各自的文档：

[Flask - 配置处理](https://flask.palletsprojects.com/en/2.0.x/config/)
[FastAPI - 设置和环境变量](https://fastapi.tiangolo.com/advanced/settings/)

***flask***

```python
import os
from flask import Flask

class Config(object):
    MESSAGE = os.environ.get("MESSAGE")

app = Flask(__name__)
app.config.from_object(Config)

@app.route("/settings")
def get_settings():
    return { "message": app.config["MESSAGE"] }

if __name__ == "__main__":
    app.run()
```

现在，在运行服务器之前，请设置相应的环境变量：

```shell
export MESSAGE="hello, world"
```

***fastAPI***

```python
import uvicorn
from fastapi import FastAPI
from pydantic import BaseSettings

class Settings(BaseSettings):
    message: str

settings = Settings()
app = FastAPI()

@app.get("/settings")
def get_settings():
    return { "message": settings.message }

if __name__ == "__main__":
    uvicorn.run("fastapi_code:app")

```

### 路由 Routes, 模板 Templates, 视图 Views

#### HTTP Methods

***flask***

```python
from flask import request

@app.route("/", methods=["GET", "POST"])
def home():
    # handle POST
    if request.method == "POST":
        return {"Hello": "POST"}
    # handle GET
    return {"Hello": "GET"}
```

***fastAPI***

```python
@app.get("/")
def home():
    return {"Hello": "GET"}

@app.post("/")
def home_post():
    return {"Hello": "POST"}
```

FastAPI 为每种方法提供了单独的装饰器：

```python
@app.get("/")
@app.post("/")
@app.delete("/")
@app.patch("/")
```

#### URL Parameters

通过 URL（如 /employee/1)  ）传入信息以管理状态，请执行以下操作：

***flask***

```python
@app.route("/employee/<int:id>")
def home():
    return {"id": id}
```

***fastAPI***

```python
@app.get("/employee/{id}")
def home(id: int):
    return {"id": id}
```

URL 参数的指定类似于 f 字符串表达式。此外，您还可以使用类型提示。在这里，我们在运行时告诉Pydantic，id 的类型是 int。在开发阶段，可以通过代码完成来完成，它有更好的体验。

#### 查询参数

与 URL 参数一样，查询参数（如/employee?department=sales ）也可用于管理状态（通常用于过滤筛选或排序）：


***flask***

```python
from flask import request

@app.route("/employee")
def home():
    department = request.args.get("department")
    return {"department": department}
```

***fastAPI***

```python
@app.get("/employee")
def home(department: str):
    return {"department": department}
```

#### 模板

***flask***

```python
from flask import render_template

@app.route("/")
def home():
    return render_template("index.html")
```

默认情况下，Flask 在 "templates" 文件夹中查找模板。

***fastAPI***

需要先安装 Jinja:

```shell
pip install jinja2
```

实现

```python
from fastapi import Request
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse

app = FastAPI()

templates = Jinja2Templates(directory="templates")

@app.get("/", response_class=HTMLResponse)
def home(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

```

对于 FastAPI，您需要显式定义"templates"文件夹。然后，对于每个响应，需要提供请求上下文。

#### 静态文件

***flask***
默认情况下，Flask 从"templates"文件夹中提供静态文件。

***fastAPI***
在 FastAPI 中，您需要为静态文件挂载一个文件夹：

```python
from fastapi.staticfiles import StaticFiles

app = FastAPI()

app.mount("/static", StaticFiles(directory="static"), name="static")

```

#### 异步任务

***flask***
从 Flask 2.0 开始，您可以使用 async/await 创建异步路由处理程序：

```python
@app.route("/")
async def home():
    result = await some_async_task()
    return result
```

有关 Flask 中的异步视图的详细信息，请查看 Flask 2.0 中的[异步文章](https://testdriven.io/blog/flask-async/)。

Flask中的异步也可以通过使用线程（并发）或多处理（并行性）或Celery或RQ等工具来实现：

- [使用 Flask 和 Celery 的异步任务](https://testdriven.io/blog/flask-and-celery/)
- [使用 Flask 和 Redis 队列的异步任务](https://testdriven.io/blog/asynchronous-tasks-with-flask-and-redis-queue/)

***fastAPI***
FastAPI极大地简化了异步任务，因为它对异步的本机支持。要使用，只需将关键字添加到视图函数中：async

```python
app.get("/")
async def home():
    result = await some_async_task()
    return result
```

FastAPI 还具有[后台任务](https://fastapi.tiangolo.com/tutorial/background-tasks/)功能，您可以使用该功能定义在返回响应后要运行的后台任务。这对于在发回响应之前不需要完成的操作非常有用。

```python
from fastapi import BackgroundTasks

def process_file(filename: str):
    # process file :: takes minimum 3 secs (just an example)
    pass

@app.post("/upload/{filename}")
async def upload_and_process(filename: str, background_tasks: BackgroundTasks):
    background_tasks.add_task(process_file, filename)
    return {"message": "processing file"}
```

此处，响应将立即发送，而不会使用户等待文件处理完成。

您可能在需要执行繁重的后台计算或需要任务队列来管理任务和工作人员时，希望使用 Celery 代替 BackgroundTasks。有关详细信息，请参阅[使用 FastAPI 和 Celery 的异步任务](https://testdriven.io/blog/fastapi-and-celery/)。

#### 依赖注入

***flask***

尽管您可以实现自己的依赖关系注入解决方案，但默认情况下，Flask 没有真正的内置支持。相反，您需要使用诸如[flask-injector](https://github.com/alecthomas/flask_injector)之类的外部包装。

***fastAPI***

另一方面，FastAPI具有处理依赖注入的强大解决方案。

```python
from databases import Database
from fastapi import Depends
from starlette.requests import Request

from db_helpers import get_all_data
def get_db(request: Request):
    return request.app.state._db

@app.get("/data")
def get_data(db: Database = Depends(get_db)):
    return get_all_data(db)

```

因此，到路由本身中。get_db将获取对在应用程序的启动事件处理程序中创建的数据库连接的引用。然后，[Depends}(https://fastapi.tiangolo.com/tutorial/dependencies/)用于向 FastAPI 指示路由依赖(depends) ***get_db***。因此，它应该在路由处理程序中的代码之前执行，并且结果应该是"注入"路由本身

#### 数据验证

***flask***

Flask 没有任何内部数据验证支持。您可以使用功能强大的Pydantic软件包通过Flask-Pydantic 进行数据验证。

***fastAPI***

使FastAPI如此强大的原因之一是它对Pydantic的支持。

```python
from pydantic import BaseModel

app = FastAPI()

class Request(BaseModel):
    username: str
    password: str

@app.post("/login")
async def login(req: Request):
    if req.username == "testdriven.io" and req.password == "testdriven.io":
        return {"message": "success"}
    return {"message": "Authentication Failed"}
```

下面是一個接收Request模型的输入，有效负载(payload )必须包含用户名和密码的代碼示例。

```shell
# correct payload format
✗ curl -X POST 'localhost:8000/login' \
    --header 'Content-Type: application/json' \
    --data-raw '{\"username\": \"testdriven.io\",\"password\":\"testdriven.io\"}'

{"message":"success"}

# incorrect payload format
✗ curl -X POST 'localhost:8000/login' \
    --header 'Content-Type: application/json' \
    --data-raw '{\"username\": \"testdriven.io\",\"passwords\":\"testdriven.io\"}'

{"detail":[{"loc":["body","password"],"msg":"field required","type":"value_error.missing"}]}

```

注意一下该请求。我们输入了 ***passwords*** 而不是 ***password*** .Pydantic 模型会自动告诉用户password字段已丢失。

#### 序列化和反序列化

***flask***

最简单的序列化方法是使用 [jsonify](https://flask.palletsprojects.com/en/2.0.x/api/#flask.json.jsonify)：

```python
from flask import jsonify
from data import get_data_as_dict

@app.route("/")
def send_data():
    return jsonify(get_data_as_dict)
```

对于复杂的对象，Flask开发人员通常使用[Flask-Marshmallow](https://flask-marshmallow.readthedocs.io/en/latest/)。

***fastAPI***

FastAPI 会自动序列化并返回 **dict**。对于更复杂和结构化的数据，使用Pydantic：

```python
from pydantic import BaseModel

app = FastAPI()

class Request(BaseModel):
    username: str
    email: str
    password: str

class Response(BaseModel):
    username: str
    email: str

@app.post("/login", response_model=Response)
async def login(req: Request):
    if req.username == "testdriven.io" and req.password == "testdriven.io":
        retu        rn req
    return {"message": "Authentication Failed"}
```

这里，我们添加了一个**Request** 模型：它包含用户名、电子邮件和密码。我们还定义了一个仅包含用户名和电子邮件的 Request 模型。输入模型处理反序列化，而输出模型处理对象序列化。然后，响应模型通过response_model参数传递给装饰器。RequestResponseRequestResponse

现在，如果我们返回请求本身作为响应，将省略 ，因为我们定义的响应模型不包含密码字段。Pydanticpassword

例：

```shell
# output
✗ curl -X POST 'localhost:8000/login' \
    --header 'Content-Type: application/json' \
    --data-raw '{\"username\":\"testdriven.io\",\"email\":\"admin@testdriven.io\",\"password\":\"testdriven.io\"}'

{"username":"testdriven.io","email":"admin@testdriven.io"}
```

####

***flask***

```python

```

***fastAPI***

```python

```
***flask***

```python

```

***fastAPI***

```python

```
***flask***

```python

```

***fastAPI***

```python

```
***flask***

```python

```

***fastAPI***

```python

```
***flask***

```python

```

***fastAPI***

```python

```
***flask***

```python

```

***fastAPI***

```python

```
***flask***

```python

```

***fastAPI***

```python

```
***flask***

```python

```

***fastAPI***

```python

```
***flask***

```python

```

***fastAPI***

```python

```
***flask***

```python

```

***fastAPI***

```python

```