# 相关  命令

安装命令

```
npm install -g @vue/cli
```

卸载命令

```
npm uninstall -g vue-cli
```


创建项目

Initially, we would create a new project in the CLI with this command:

```
vue innit webpack-simple myapp
```

But now, to start a new Vue project with the new CLI version 3 we simple say:

```
vue create myapp
```

According to Vue Point, any Vue CLI 3 project by default ships with out-of-the-box support for:

- Pre-configured webpack features like code splitting.
- ES2017 transpilation.
- Support for PostCSS and all major CSS pre-processors
- Auto-generated HTML with hashed asset links and preload/prefetch resource hints
- Modes and cascading environment variables via .env files
- Modern mode: ship native ES2017+ bundle and legacy bundle in parallel
- Multi-page mode: build an app with multiple HTML/JS entry points
- Build targets: build Vue Single-File Components into a library or native web components


### Plugins

Remember that features scaffolded by the new CLI tool is plugin based, that means Babel, ESLint and every other custom feature is identified as a plugin. The naming convention is like this:

@vue/cli-plugin-pluginName 
Let us try adding a plugin say Typescript, to our default project. This can easily added using a line of command like thus:

```
vue add typescript
```


### instant Prototyping: Working with Components

With the new CLI version 3, you do not really need a full fledged project with all the configs. Sometimes, you just want to work on a single component and see it run on a local development server. Good news! the new Vue CLI 3 lets you do exactly that.

To be able to use Vue CLI 3’s instant prototyping you have to globally install the Vue CLI service on your machine like this:

```
npm install -g @vue/cli-service-global
```

Now we can literally prototype a Vue component anywhere in your machine. So let us say you have a helloworld.vue component like this:

```
<template>

 <div class=”hello”>

  <h1>{{ msg }}</h1>

  <p>

   For a guide and recipes on how to configure / customize this         project,<br> check out the 
   <a href=”https://cli.vuejs.org" target=”_blank”    rel=”noopener”>vue-cli documentation</a>.

  </p>

  <h3>Installed CLI Plugins</h3>

  <h3>Essential Links</h3>

  <h3>Ecosystem</h3>

 </div>

</template>

<script>

export default {

  name: ‘HelloWorld’,

  props: {

  msg: String

  }

 }

</script>
```

You can change directory to the folder where this is saved and then serve it as a standalone component like this:

```
vue serve helloWorld.vue
```

This would automatically spin up the component on your machine’s localhost, exactly like it would for a full project, awesome right?. This is definitely my favourite shiny new feature of the Vue CLI 3.0

###  Vue GUI**

To use this GUI tool, you have to run this command in your terminal:

```
vue ui
```

It would start the GUI tool on a dev server in your default browser. It is really intuitive and easy to use and ideal for beginners or developers who would not want to use the cli often.

###Conclusion

We have had a comprehensive look at the new Vue CLI version and all the features it shipped with. We also saw how easy anyone can get started using Vue with the new CLI. I would love to hear from your experience in the comments, and happy coding! Cheers.



### 安全方式启动portainer

#### 生成证书

```
$ mkdir -p /certs
$ cd /certs
$ openssl genrsa -out portainer.key 2048
$ openssl ecparam -genkey -name secp384r1 -out portainer.key
$ openssl req -new -x509 -sha256 -key portainer.key -out portainer.crt -days 3650
$ ls 

```

#### 启动 portainer

```
 docker run -d -p 443:9000 -p 8000:8000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock  -v /certs:/certs -v portainer_data:/data portainer/portainer --ssl --sslcert /certs/portainer.crt --sslkey /certs/portainer.key
```
 
 
 






