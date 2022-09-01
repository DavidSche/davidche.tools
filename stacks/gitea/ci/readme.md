# 使用说明

# 是否使用外部网络
# 根据IP/域名 修改部署文件中的地址
# 
# gitea 正常初始化后，创建第一个管理员账户 如gitadmin/Qaz123!
# 设置中添加 已授权的 OAuth2 应用  drone--填写drone 访问地址
# 复制客户端ID和 客户端密钥  更新/修改drone-server 中的环境变量
# 在gitea中 创建仓库并设置.drone.yml 文件中。
# 在drone 中激活仓库，Project settings 选中 Trusted
# 提交代码激活pipline 流程


## 工单和拉取请求模板

有些项目具有标准的问题列表，用户在创建问题或请求请求时需要回答。Gitea支持将模板添加到资源库的主分支，以便在用户创建问题和提取请求时它们可以自动填充表单。这将减少获得一些澄清细节的最初来回过程。

问题模板的文件名:

ISSUE_TEMPLATE.md
issue_template.md
.gitea/ISSUE_TEMPLATE.md
.gitea/issue_template.md
.github/ISSUE_TEMPLATE.md
.github/issue_template.md

PR模板的文件名:

PULL_REQUEST_TEMPLATE.md
pull_request_template.md
.gitea/PULL_REQUEST_TEMPLATE.md
.gitea/pull_request_template.md
.github/PULL_REQUEST_TEMPLATE.md
.github/pull_request_template.md

Additionally, the New Issue page URL can be suffixed with ?body=Issue+Text and the form will be populated with that string. This string will be used instead of the template if there is one.

此外，“新工单/问题”页面的URL可以带有后缀，?body=Issue+Text并将使用该字符串填充表单。如果有的话，将使用该字符串代替模板。

------

自定义 Gitea 配置 
Gitea 引用 custom 目录中的自定义配置文件来覆盖配置、模板等默认配置。

如果从二进制部署 Gitea ，则所有默认路径都将相对于该 gitea 二进制文件；如果从发行版安装，则可能会将这些路径修改为Linux文件系统标准。Gitea 将会自动创建包括 custom/ 在内的必要应用目录，应用本身的配置存放在 custom/conf/app.ini 当中。在发行版中可能会以 /etc/gitea/ 的形式为 custom 设置一个符号链接，查看配置详情请移步：

快速备忘单
完整配置清单
如果您在 binary 同目录下无法找到 custom 文件夹，请检查您的 GITEA_CUSTOM 环境变量配置， 因为它可能被配置到了其他地方（可能被一些启动脚本设置指定了目录）。

环境变量清单
注： 必须完全重启 Gitea 以使配置生效。

使用自定义 /robots.txt
将 想要展示的内容 存放在 custom 目录中的 robots.txt 文件来让 Gitea 使用自定义的/robots.txt （默认：空 404）。

使用自定义的公共文件
将自定义的公共文件（比如页面和图片）作为 webroot 放在 custom/public/ 中来让 Gitea 提供这些自定义内容（符号链接将被追踪）。

举例说明：image.png 存放在 custom/public/中，那么它可以通过链接 http://gitea.domain.tld/image.png 访问。

修改默认头像
替换以下目录中的 png 图片： custom/public/img/avatar\_default.png

自定义 Gitea 页面
您可以改变 Gitea custom/templates 的每个单页面。您可以在 Gitea 源码的 templates 目录中找到用于覆盖的模板文件，应用将根据 custom/templates 目录下的路径结构进行匹配和覆盖。

包含在 {{ 和 }} 中的任何语句都是 Gitea 的模板语法，如果您不完全理解这些组件，不建议您对它们进行修改。

添加链接和页签
如果您只是想添加额外的链接到顶部导航栏或额外的选项卡到存储库视图，您可以将它们放在您 custom/templates/custom/ 目录下的 extra_links.tmpl 和 extra_tabs.tmpl 文件中。

举例说明：假设您需要在网站放置一个静态的“关于”页面，您只需将该页面放在您的 “custom/public/“目录下（比如 custom/public/impressum.html）并且将它与 custom/templates/custom/extra_links.tmpl 链接起来即可。

这个链接应当使用一个名为“item”的 class 来匹配当前样式，您可以使用 {{AppSubUrl}} 来获取 base URL: <a class="item" href="{{AppSubUrl}}/impressum.html">Impressum</a>

同理，您可以将页签添加到 extra_tabs.tmpl 中，使用同样的方式来添加页签。它的具体样式需要与 templates/repo/header.tmpl 中已有的其他选项卡的样式匹配 (source in GitHub)

页面的其他新增内容
除了 extra_links.tmpl 和 extra_tabs.tmpl，您可以在您的 custom/templates/custom/ 目录中存放一些其他有用的模板，例如：

header.tmpl，在 <head> 标记结束之前的模板，例如添加自定义CSS文件
body_outer_pre.tmpl，在 <body> 标记开始处的模板
body_inner_pre.tmpl，在顶部导航栏之前，但在主 container 内部的模板，例如添加一个 <div class="full height">
body_inner_post.tmpl，在主 container 结束处的模板
body_outer_post.tmpl，在底部 <footer> 元素之前.
footer.tmpl，在 <body> 标签结束处的模板，可以在这里填写一些附加的 Javascript 脚本。
自定义 gitignores，labels， licenses， locales 以及 readmes
将自定义文件放在 custom/options 下相应子的文件夹中即可

更改 Gitea 外观
Gitea 目前由两种内置主题，分别为默认 gitea 主题和深色主题 arc-green，您可以通过修改 app.ini ui 部分的 DEFAULT_THEME 的值来变更至一个可用的 Gitea 外观。

--------

## 初始化，安装

Go to Manage Jenkins -> Configure System and scroll down to Gitea Servers
Add a new server by name and URL, your URL field should be an accessible location of your Gitea instance via HTTP(s)
Optionally enable the "manage hooks" checkbox, this will allow Jenkins to configure your webhooks using an account of your choosing.
It is recommended to use a personal access token, you can do this by selecting "Add" next to the credentials dropdown and changing it's "Kind" to Gitea Personal Access Token and "Scope" to System.
Hint: you can ignore a "HTTP 403/Forbidden" error here in case your gitea instance is private.

## 配置 gitea user
login to your gitea instance with an administrator account.
create a new user, e.g. "jenkins". Set password to something secure - you will not need it for login.
add the jenkins user to the organization you want to build projects for in jenkins (either by adding him to an existing team or adding a new "ci"-team). Make sure that team is associated to the repositories you want to build.
log out of gitea.
log back in as the new "jenkins" user.
in user profile settings, go to "application" and add a new access token. Make sure to note the token shown.

## Add gitea organization item

In main menu, click "New Item". Note that gitea plugin depends on the multibranch pipeline plugin, so make sure to have that installed.
Select "Gitea organization" as the item type
In the "Gitea organzations" section, add a new credential of type "Gitea personal access token".
Add the access token created before for the jenkins user in gitea. Ignore the error about the token not having the correct length.
In the "Owner" field, add the name of the organization in gitea you want to build projects for (not the full name).
Fill the rest of the form as required. Click "Save". The following scan should list the repositories that the jenkins user can see in the organization selected.


##  DRONE 用 GITEA OAUTH2 登录时授权失败

报错：
授权失败
Unregistered Redirect URI
授权失败，这是一个无效的请求。请联系尝试授权应用的管理员。
运行drone时，传server参数DRONE_SERVER_HOST=www.myci.com
在gitea应用中指定Redirect URI为https://www.myci.com/login




