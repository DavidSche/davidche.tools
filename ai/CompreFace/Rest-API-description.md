# Rest API descri描述

## 目录

- [Rest API descri描述](#rest-api-descri描述)
  - [目录](#目录)
  - [Postman 文档](#postman-文档)
  - [人脸识别服务](#人脸识别服务)
    - [管理主题](#管理主题)
    - [添加一个主题](#添加一个主题)
    - [重命名主题](#重命名主题)
    - [删除主题](#删除主题)
    - [删除所有主题](#删除所有主题)
    - [列出主题](#列出主题)
    - [管理主题示例](#管理主题示例)
    - [Add an Example of a Subject](#add-an-example-of-a-subject)
    - [List of All Saved Examples of the Subject](#list-of-all-saved-examples-of-the-subject)
    - [Delete All Examples of the Subject by Name](#delete-all-examples-of-the-subject-by-name)
    - [Delete an Example of the Subject by ID](#delete-an-example-of-the-subject-by-id)
    - [Delete Multiple Examples](#delete-multiple-examples)
    - [Direct Download an Image example of the Subject by ID](#direct-download-an-image-example-of-the-subject-by-id)
    - [Download an Image example of the Subject by ID](#download-an-image-example-of-the-subject-by-id)
    - [Recognize Faces from a Given Image](#recognize-faces-from-a-given-image)
    - [Verify Faces from a Given Image](#verify-faces-from-a-given-image)
  - [Face Detection Service](#face-detection-service)
  - [Face Verification Service](#face-verification-service)
  - [Base64 Support](#base64-support)
    - [Add an Example of a Subject, Base64](#add-an-example-of-a-subject-base64)
    - [Recognize Faces from a Given Image, Base64](#recognize-faces-from-a-given-image-base64)
    - [Verify Faces from a Given Image, Base64](#verify-faces-from-a-given-image-base64)
    - [Face Detection Service, Base64](#face-detection-service-base64)
    - [Face Verification Service, Base64](#face-verification-service-base64)

To know more about face services and face plugins visit [this page](Face-services-and-plugins.md).

## Postman 文档

There is a [Postman REST API documentation](https://documenter.getpostman.com/view/17578263/UUxzAnde)
that covers the same REST endpoint. Postman documentation supports snippets on the most popular programming languages.



## 人脸识别服务

### 管理主题

T这些端点（endpoints）允许您使用主题.

The most popular case of subject usage is to assign a subject to one person. 
So, to upload several images of one person, you need to upload them to one subject. 
As a result, when you perform face recognition, you find a person who is on the image.
主题用法中最受欢迎的情况是将主题分配给一个人。因此，要上传一个人的多张图片，您需要将它们上传到一个主题。因此，当您执行人脸识别时，您会找到图像上的人.

Another case of subject usage is assigning a photo of several people as a subject. 
In this case, you need to detect all faces on the image and then save them to one subject. 
主题使用的另一种场景是将几个人的照片指定为一个主题。在这种情况下，您需要检测图像上的所有人脸，然后将其保存到一个主体。因此，当您执行人脸识别时，您可以找到图像上有人的所有照片。
您不需要明确地使用主题。
您只需上传该主题的新示例，该主题将自动创建。或者，如果您删除了该主题的所有示例，它将自动删除。
As a result, when you perform face recognition, you find all photos on which there is the person who is on the image.
You don’t need to work with subjects explicitly. 
You can just upload a new example of the subject and the subject will be created automatically. 
Or if you delete all the examples of the subject, it will be deleted automatically.

### 添加一个主题

```since 0.6 version```

在 "人脸集合（Face Collection）" 中创建新主题。创建主题是一个可选步骤，你可以上传没有现有主题的[示例](#add-an-example-of-a-subject)，它会将自动创建主题。

```shell
curl -X POST "http://localhost:8000/api/v1/recognition/subjects" \
-H "Content-Type: application/json" \
-H "x-api-key: <service_api_key>" \
-d '{"subject": "<subject_name>"}'
```

| 元素      | 描述 | 类型   | 必选 | 备注                                                                         |
|--------------|-------------|--------|----------|-------------------------------------------------------------------------------|
| Content-Type | header      | 字符串 | 是 | application/json                                                              |
| x-api-key    | header      | 字符串 | 是 | 人脸识别服务 api key, 由用户创建                  |
| subject      | body param  | 字符串 | 是 | 主题名称. 可以是人的姓名, 也可以是任何字符串 |

成功响应正文:
```json
{
  "subject": "<subject_name>"
}
```

| 元素 | 类型   | 描述                |
|---------|--------|----------------------------|
| subject | 字符串 | 主题的名称 |

### 重命名主题
```since 0.6 version```
 
重命名现有主题.如果新主题名称已存在,则合并主题 - 旧主题名称中的所有人脸将**重新分配**给具有新名称的主题,并删除原有主题.

```shell
curl -X PUT "http://localhost:8000/api/v1/recognition/subjects/<subject>" \
-H "Content-Type: application/json" \
-H "x-api-key: <service_api_key>" \
-d '{"subject: <subject_name>"}'
```
| 元素      | 描述 | 类型   | 是 | 备注                                                                         |
|--------------|-------------|--------|----------|-------------------------------------------------------------------------------|
| Content-Type | header      | 字符串 | 是 | application/json                                                              |
| x-api-key    | header      | 字符串 | 是 | 人脸识别服务 api key, 由用户创建                  |
| subject      | body param  | 字符串 | 是 | 主题名称. 可以是人的姓名, 也可以是任何字符串 |

成功响应正文:
```json
{
  "updated": "true|false"
}
```

| 元素 | 类型    | 描述       |
|---------|---------|-------------------|
| updated | 布尔 | 失败或成功 |

### 删除主题
```since 0.6 version```

删除现有主题和所有保存的人脸.

```shell
curl -X DELETE "http://localhost:8000/api/v1/recognition/subjects/<subject>" \
-H "Content-Type: application/json" \
-H "x-api-key: <service_api_key>"
```
| 元素      | 描述 | 类型   | 是 | 备注                                                                         |
|--------------|-------------|--------|----------|-------------------------------------------------------------------------------|
| Content-Type | header      | 字符串 | 是 | application/json                                                              |
| x-api-key    | header      | 字符串 | 是 | 人脸识别服务 api key, 由用户创建                  |
| subject      | body param  | 字符串 | 是 | 主题名称. 可以是人的姓名, 也可以是任何字符串  |

成功响应正文:

```json
{
  "subject": "<subject_name>"
}
```

| 元素 | 类型   | 描述                |
|---------|--------|----------------------------|
| subject | 字符串 | 主题的名称 |

### 删除所有主题
```since 0.6 version```

删除所有主题和所有保存的人脸.

```shell
curl -X DELETE "http://localhost:8000/api/v1/recognition/subjects" \
-H "Content-Type: application/json" \
-H "x-api-key: <service_api_key>"
```
| 元素      | 描述 | 类型   | 是 | 备注                                                        |
|--------------|-------------|--------|----------|--------------------------------------------------------------|
| Content-Type | header      | 字符串 | 是 | application/json                                             |
| x-api-key    | header      |  字符串 | 是 | 人脸识别服务 api key, 由用户创建 |

成功响应正文:
```json
{
  "deleted": "<count>"
}
```

| 元素 | 类型    | 描述               |
|---------|---------|----------------------------|
| deleted | integer | 被删除主题的数量 |

### 列出主题
```since 0.6 version```

返回与人脸集合相关的所有主题


```shell
curl -X GET "http://localhost:8000/api/v1/recognition/subjects/" \
-H "Content-Type: application/json" \
-H "x-api-key: <service_api_key>"
```
| 元素      | 描述 | 类型   | 是 | 备注                                                        |
|--------------|-------------|--------|----------|--------------------------------------------------------------|
| Content-Type | header      | 字符串 | 是 | application/json                                             |
| x-api-key    | header      | 字符串 | 是 | 人脸识别服务 api key, 由用户创建 |

成功响应正文:
```json
{
  "subjects": [
    "<subject_name1>",
    "<subject_name2>"
    ]
}
```

| 元素 | 类型    | 描述                             |
|----------|-------|-----------------------------------------|
| subjects | array | 人脸集合的主题列表 |

### 管理主题示例




The subject example is basically an image of a known face that you want to save to face collection. 
主题示例基本上是要保存到人脸集合中的已知人脸的图像。

save_images_to_db
When you save a subject example, CompreFace calculates the embedding of the face (faceprint) and saves it into the database. 
By default, the image itself is also saved, it is needed for managing images, e.g. [download of the image](#direct-download-an-image-example-of-the-subject-by-id). You can change it using `save_images_to_db` parameter in [configuration](Configuration.md). 

保存主题示例时，CompreFace 会计算人脸的嵌入（面部指纹）并将其保存到数据库中。默认情况下，图像本身也被保存，它需要用于管理图像，例如下载图像。您可以使用配置中的参数进行更改。

One subject example is enough for face recognition, the accuracy will be high enough. But if you add more examples, the accuracy may be even better. 

一个主题示例就足以进行人脸识别，精度将足够高。但是，如果您添加更多示例，则准确性可能会更好。

### Add an Example of a Subject

This creates an example of the subject by saving images. You can add as many images as you want to train the system. Image should 
contain only one face.

```shell
curl -X POST "http://localhost:8000/api/v1/recognition/faces?subject=<subject>&det_prob_threshold=<det_prob_threshold>" \
-H "Content-Type: multipart/form-data" \
-H "x-api-key: <service_api_key>" \
-F file=@<local_file> 
```
| Element            | Description | Type   | 是 | Notes                                                                                                |
|--------------------|-------------|--------|----------|------------------------------------------------------------------------------------------------------|
| Content-Type       | header      | 字符串 | 是 | multipart/form-data                                                                                  |
| x-api-key          | header      | 字符串 | 是 | 人脸识别服务 api key, 由用户创建                                         |
| subject            | param       | 字符串 | 是 | is the name you assign to the image you save                                                         |
| det_prob_threshold | param       | 字符串 | optional | minimum required confidence that a recognized face is actually a face. Value is between 0.0 and 1.0. |
| file               | body        | image  | 是 | allowed image formats: jpeg, jpg, ico, png, bmp, gif, tif, tiff, webp. Max size is 5Mb               |

成功响应正文:  
```json
{
  "image_id": "6b135f5b-a365-4522-b1f1-4c9ac2dd0728",
  "subject": "subject1"
}
```

| 元素   | 类型   | 描述                |
|----------|--------|----------------------------|
| image_id | UUID   | UUID of uploaded image     |
| subject  | 字符串 | Subject of the saved image |


### List of All Saved Examples of the Subject

To retrieve a list of subjects saved in a Face Collection:

```shell
curl -X GET "http://localhost:8000/api/v1/recognition/faces?page=<page>&size=<size>&subject=<subject>" \
-H "x-api-key: <service_api_key>" \
```

| Element   | Description | Type    | 是 | Notes                                                                                                      |
|-----------|-------------|---------|----------|------------------------------------------------------------------------------------------------------------|
| x-api-key | header      | 字符串  | 是 | 人脸识别服务 api key, 由用户创建                                               |
| page      | param       | integer | optional | page number of examples to return. Can be used for pagination. Default value is 0. Since 0.6 version       |
| size      | param       | integer | optional | faces on page (page size). Can be used for pagination. Default value is 20. Since 0.6 version              |
| subject   | param       | 字符串  | optional | what subject examples endpoint should return. If empty, return examples for all subjects. Since 1.0 version|

成功响应正文:

```
{
  "faces": [
    {
      "image_id": <image_id>,
      "subject": <subject>
    },
    ...
  ],
  "page_number": 0,
  "page_size": 10,
  "total_pages": 2,
  "total_elements": 12
}
```

| Element        | Type    | Description                                                       |
|----------------|---------|-------------------------------------------------------------------|
| face.image_id  | UUID    | UUID of the face                                                  |
| faсe.subject   | 字符串  | <subject> of the person, whose picture was saved for this api key |
| page_number    | integer | page number                                                       |
| page_size      | integer | **requested** page size                                           |
| total_pages    | integer | total pages                                                       |
| total_elements | integer | total faces                                                       |


### Delete All Examples of the Subject by Name

To delete all image examples of the <subject>:

```shell
curl -X DELETE "http://localhost:8000/api/v1/recognition/faces?subject=<subject>" \
-H "x-api-key: <service_api_key>"
```

| 元素   | 描述   | 类型   | 是 | 备注                                                                                          |
|-----------|-------------|--------|----------|------------------------------------------------------------------------------------------------|
| x-api-key | header      | 字符串 | 是 | 人脸识别服务 api key, 由用户创建                                   |
| subject   | param       | 字符串 | optional | is the name subject. If this parameter is absent, all faces in Face Collection will be removed |

成功响应正文:
```
{
    "deleted": <count>
}
```

| 元素    | 类型    | 描述             |
|---------|---------|-------------------------|
| deleted | integer | Number of deleted faces |



### Delete an Example of the Subject by ID

Endpoint to delete an image by ID. If no image found by id - 404.

```shell
curl -X DELETE "http://localhost:8000/api/v1/recognition/faces/<image_id>" \
-H "x-api-key: <service_api_key>"
```

| 元素   | 描述   | 类型   | 是 | 备注                                                        |
|-----------|-------------|--------|----------|--------------------------------------------------------------|
| x-api-key | header      | 字符串 | 是 | 人脸识别服务 api key, 由用户创建 |
| image_id  | variable    | UUID   | 是 | UUID of the removing face                                    |

成功响应正文:
```
{
  "image_id": <image_id>,
  "subject": <subject>
}
```

| 元素   | 类型   | 描述                                                       |
|----------|--------|-------------------------------------------------------------------|
| image_id | UUID   | UUID of the removed face                                          |
| subject  | 字符串 | <subject> of the person, whose picture was saved for this api key |

  
### Delete Multiple Examples 删除多实例
  ```since 1.0 version```
  
To delete several subject examples:  
  ```shell
curl -X POST "http://localhost:8000/api/v1/recognition/faces/delete" \
-H "Content-Type: application/json" \
-H "x-api-key: <service_api_key>" \
-d '["<image_id1>","<image_id2>", ..., "<image_idN>"]'
```

| 元素   | 描述   | 类型   | 是 | 备注                                                        |
|-----------------|-------------|--------|----------|--------------------------------------------------------------|
| service_api_key | header      | 字符串 | 是 | 人脸识别服务 api key, 由用户创建 |
| image_id        | variable    | UUID   | 是 | UUID of the removing face                                    |
  

  
成功响应正文:
``` 
{
  "image_id": <image_id>,
  "subject": <subject>
}
``` 

| 元素   | 描述   | 类型   | 
|-----------------|-----------------------------------------------------------|--------|
| image_id        | UUID of the removed face                                  | UUID    | 
| subject         | of the person, whose picture was saved for this api key   | 字符串 | 
  
If some image ids are not exists, they will be ignored
  

### Direct Download an Image example of the Subject by ID
```since 0.6 version```

You can paste this URL into the <img> html tag to show the image.

```shell
curl -X GET "http://localhost:8000/api/v1/static/<service_api_key>/images/<image_id>"
```

| 元素   | 描述   | 类型   | 是 | 备注                                                        |
|-----------------|-------------|--------|----------|--------------------------------------------------------------|
| service_api_key | variable    | 字符串 | 是 | 人脸识别服务 api key, 由用户创建 |
| image_id        | variable    | UUID   | 是 | UUID of the image to download                                |

Response body is binary image. Empty bytes if image not found.


### Download an Image example of the Subject by ID
```since 0.6 version```

To download an image example of the Subject by ID:

```shell
curl -X GET "http://localhost:8000/api/v1/recognition/faces/<image_id>/img"
-H "x-api-key: <service_api_key>"
```

| 元素   | 描述   | 类型   | 是 | 备注                                                        |
|-----------|-------------|--------|----------|--------------------------------------------------------------|
| x-api-key | header      | 字符串 | 是 | 人脸识别服务 api key, 由用户创建 |
| image_id  | variable    | UUID   | 是 | UUID of the image to download                                |

Response body is binary image. Empty bytes if image not found.


### Recognize Faces from a Given Image

To recognize faces from the uploaded image:

```shell
curl  -X POST "http://localhost:8000/api/v1/recognition/recognize?limit=<limit>&prediction_count=<prediction_count>&det_prob_threshold=<det_prob_threshold>&face_plugins=<face_plugins>&status=<status>" \
-H "Content-Type: multipart/form-data" \
-H "x-api-key: <service_api_key>" \
-F file=<local_file>
```

| 元素            | 描述 | 类型    | 是 | 备注                                                                                                                                          |
|--------------------|-------------|---------|----------|------------------------------------------------------------------------------------------------------------------------------------------------|
| Content-Type       | header      | 字符串  | 是 | multipart/form-data                                                                                                                            |
| x-api-key          | header      | 字符串  | 是 | 人脸识别服务 api key, 由用户创建                                                                                   |
| file               | body        | image   | 是 | allowed image formats: jpeg, jpg, ico, png, bmp, gif, tif, tiff, webp. Max size is 5Mb                                                         |
| limit              | param       | integer | optional | maximum number of faces on the image to be recognized. It recognizes the biggest faces first. Value of 0 represents no limit. Default value: 0 |
| det_prob_threshold | param       | 字符串  | optional | minimum required confidence that a recognized face is actually a face. Value is between 0.0 and 1.0.                                           |
| prediction_count   | param       | integer | optional | maximum number of subject predictions per face. It returns the most similar subjects. Default value: 1                                         |
| face_plugins       | param       | 字符串  | optional | comma-separated slugs of face plugins. If empty, no additional information is returned. [Learn more](Face-services-and-plugins.md)             |
| status             | param       | boolean | optional | if true includes system information like execution_time and plugin_version fields. Default value is false                                      |

成功响应正文:
```json
{
  "result" : [ {
    "age" : {
      "probability": 0.9308982491493225,
      "high": 32,
      "low": 25
    },
    "gender" : {
      "probability": 0.9898611307144165,
      "value": "female"
    },
    "mask" : {
      "probability": 0.9999470710754395,
      "value": "without_mask"
    },
    "embedding" : [ 9.424854069948196E-4, "...", -0.011415496468544006 ],
    "box" : {
      "probability" : 1.0,
      "x_max" : 1420,
      "y_max" : 1368,
      "x_min" : 548,
      "y_min" : 295
    },
    "landmarks" : [ [ 814, 713 ], [ 1104, 829 ], [ 832, 937 ], [ 704, 1030 ], [ 1017, 1133 ] ],
    "subjects" : [ {
      "similarity" : 0.97858,
      "subject" : "subject1"
    } ],
    "execution_time" : {
      "age" : 28.0,
      "gender" : 26.0,
      "detector" : 117.0,
      "calculator" : 45.0,
      "mask": 36.0
    }
  } ],
  "plugins_versions" : {
    "age" : "agegender.AgeDetector",
    "gender" : "agegender.GenderDetector",
    "detector" : "facenet.FaceDetector",
    "calculator" : "facenet.Calculator",
    "mask": "facemask.MaskDetector"
  }
}
```

| 元素            | 类型 | 描述                                                                                                                                                 |
|----------------------------|---------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| age                        | object  | detected age range. Return only if [age plugin](Face-services-and-plugins.md#face-plugins) is enabled                                                       |
| gender                     | object  | detected gender. Return only if [gender plugin](Face-services-and-plugins.md#face-plugins) is enabled                                                       |
| mask                       | object  | detected mask. Return only if [face mask plugin](Face-services-and-plugins.md#face-plugins) is enabled.                                                     |
| embedding                  | array   | face embeddings. Return only if [calculator plugin](Face-services-and-plugins.md#face-plugins) is enabled                                                   |
| box                        | object  | list of parameters of the bounding box for this face                                                                                                        |
| probability                | float   | probability that a found face is actually a face                                                                                                            |
| x_max, y_max, x_min, y_min | integer | coordinates of the frame containing the face                                                                                                                |
| landmarks                  | array   | list of the coordinates of the frame containing the face-landmarks. Return only if [landmarks plugin](Face-services-and-plugins.md#face-plugins) is enabled |
| subjects                   | list    | list of similar subjects with size of <prediction_count> order by similarity                                                                                |
| similarity                 | float   | similarity that on that image predicted person                                                                                                              |
| subject                    | 字符串  | name of the subject in Face Collection                                                                                                                      |
| execution_time             | object  | execution time of all plugins                                                                                                                               |
| plugins_versions           | object  | contains information about plugin versions                                                                                                                  |


### Verify Faces from a Given Image

To compare faces from the uploaded images with the face in saved image ID:
```shell
curl -X POST "http://localhost:8000/api/v1/recognition/faces/<image_id>/verify?limit=<limit>&det_prob_threshold=<det_prob_threshold>&face_plugins=<face_plugins>&status=<status>" \
-H "Content-Type: multipart/form-data" \
-H "x-api-key: <service_api_key>" \
-F file=<local_file>
```


| 元素            | 描述 | 类型    | 是 | 备注                                                                                                                                                 |
|--------------------|-------------|---------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------------|
| Content-Type       | header      | 字符串  | 是 | multipart/form-data                                                                                                                                   |
| x-api-key          | header      | 字符串  | 是 | 人脸识别服务 api key, 由用户创建                                                                                          |
| image_id           | variable    | UUID    | 是 | UUID of the verifying face                                                                                                                            |
| file               | body        | image   | 是 | allowed image formats: jpeg, jpg, ico, png, bmp, gif, tif, tiff, webp. Max size is 5Mb                                                                |
| limit              | param       | integer | optional | maximum number of faces on the target image to be recognized. It recognizes the biggest faces first. Value of 0 represents no limit. Default value: 0 |
| det_prob_threshold | param       | 字符串  | optional | minimum required confidence that a recognized face is actually a face. Value is between 0.0 and 1.0.                                                  |
| face_plugins       | param       | 字符串  | optional | comma-separated slugs of face plugins. If empty, no additional information is returned. [Learn more](Face-services-and-plugins.md)                    |
| status             | param       | boolean | optional | if true includes system information like execution_time and plugin_version fields. Default value is false                                             |

成功响应正文:
```json
{
  "result": [
    {
      "age" : {
        "probability": 0.9308982491493225,
        "high": 32,
        "low": 25
      },
      "gender" : {
        "probability": 0.9898611307144165,
        "value": "female"
      },
      "mask" : {
        "probability": 0.9999470710754395,
        "value": "without_mask"
      },
      "embedding" : [ -0.049007344990968704, "...", -0.01753818802535534 ],
      "box" : {
        "probability" : 0.9997453093528748,
        "x_max" : 205,
        "y_max" : 167,
        "x_min" : 48,
        "y_min" : 0
      },
      "landmarks" : [ [ 260, 129 ], [ 273, 127 ], [ 258, 136 ], [ 257, 150 ], [ 269, 148 ] ],
      "similarity" : 0.97858,
      "execution_time" : {
        "age" : 59.0,
        "gender" : 30.0,
        "detector" : 177.0,
        "calculator" : 70.0,
        "mask": 36.0
      }
    }
  ],
  "plugins_versions" : {
    "age" : "agegender.AgeDetector",
    "gender" : "agegender.GenderDetector",
    "detector" : "facenet.FaceDetector",
    "calculator" : "facenet.Calculator",
    "mask": "facemask.MaskDetector"
  }
}
```

| 元素            | 类型 | 描述                                                                                                                                                 |
|----------------------------|---------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| age                        | object  | detected age range. Return only if [age plugin](Face-services-and-plugins.md#face-plugins) is enabled                                                       |
| gender                     | object  | detected gender. Return only if [gender plugin](Face-services-and-plugins.md#face-plugins) is enabled                                                       |
| mask                       | object  | detected mask. Return only if [face mask plugin](Face-services-and-plugins.md#face-plugins) is enabled                                                      |
| embedding                  | array   | face embeddings. Return only if [calculator plugin](Face-services-and-plugins.md#face-plugins) is enabled                                                   |
| box                        | object  | list of parameters of the bounding box for this face                                                                                                        |
| probability                | float   | probability that a found face is actually a face                                                                                                            |
| x_max, y_max, x_min, y_min | integer | coordinates of the frame containing the face                                                                                                                |
| landmarks                  | array   | list of the coordinates of the frame containing the face-landmarks. Return only if [landmarks plugin](Face-services-and-plugins.md#face-plugins) is enabled |
| similarity                 | float   | similarity that on that image predicted person                                                                                                              |
| execution_time             | object  | execution time of all plugins                                                                                                                               |
| plugins_versions           | object  | contains information about plugin versions                                                                                                                  |

## Face Detection Service 人脸探测服务

To detect faces from the uploaded image:

从上传的图片中探测人脸

```shell
curl  -X POST "http://localhost:8000/api/v1/detection/detect?limit=<limit>&det_prob_threshold=<det_prob_threshold>&face_plugins=<face_plugins>&status=<status>" \
-H "Content-Type: multipart/form-data" \
-H "x-api-key: <service_api_key>" \
-F file=<local_file>
```


| 元素            | 描述 | 类型    | 是 | 备注                                                                                                                                          |
|--------------------|-------------|---------|----------|------------------------------------------------------------------------------------------------------------------------------------------------|
| Content-Type       | header      | 字符串  | 是 | multipart/form-data                                                                                                                            |
| x-api-key          | header      | 字符串  | 是 | api key of the Face Detection service, created by the user                                                                                     |
| file               | body        | image   | 是 | image where to detect faces. Allowed image formats: jpeg, jpg, ico, png, bmp, gif, tif, tiff, webp. Max size is 5Mb                            |
| limit              | param       | integer | optional | maximum number of faces on the image to be recognized. It recognizes the biggest faces first. Value of 0 represents no limit. Default value: 0 |
| det_prob_threshold | param       | 字符串  | optional | minimum required confidence that a recognized face is actually a face. Value is between 0.0 and 1.0                                            |
| face_plugins       | param       | 字符串  | optional | comma-separated slugs of face plugins. If empty, no additional information is returned. [Learn more](Face-services-and-plugins.md)             |
| status             | param       | boolean | optional | if true includes system information like execution_time and plugin_version fields. Default value is false                                      |

成功响应正文:
```json
{
  "result" : [ {
    "age" : {
      "probability": 0.9308982491493225,
      "high": 32,
      "low": 25
    },
    "gender" : {
      "probability": 0.9898611307144165,
      "value": "female"
    },
    "mask" : {
      "probability": 0.9999470710754395,
      "value": "without_mask"
    },
    "embedding" : [ -0.03027934394776821, "...", -0.05117142200469971 ],
    "box" : {
      "probability" : 0.9987509250640869,
      "x_max" : 376,
      "y_max" : 479,
      "x_min" : 68,
      "y_min" : 77
    },
    "landmarks" : [ [ 156, 245 ], [ 277, 253 ], [ 202, 311 ], [ 148, 358 ], [ 274, 365 ] ],
    "execution_time" : {
      "age" : 30.0,
      "gender" : 26.0,
      "detector" : 130.0,
      "calculator" : 49.0,
      "mask": 36.0
    }
  } ],
  "plugins_versions" : {
    "age" : "agegender.AgeDetector",
    "gender" : "agegender.GenderDetector",
    "detector" : "facenet.FaceDetector",
    "calculator" : "facenet.Calculator",
    "mask": "facemask.MaskDetector"
  }
}
```

| 元素            | 类型 | 描述                                                                                                                                                 |
|----------------------------|---------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| age                        | object  | detected age range. Return only if [age plugin](Face-services-and-plugins.md#face-plugins) is enabled                                                       |
| gender                     | object  | detected gender. Return only if [gender plugin](Face-services-and-plugins.md#face-plugins) is enabled                                                       |
| mask                       | object  | detected mask. Return only if [face mask plugin](Face-services-and-plugins.md#face-plugins) is enabled                                                      |
| embedding                  | array   | face embeddings. Return only if [calculator plugin](Face-services-and-plugins.md#face-plugins) is enabled                                                   |
| box                        | object  | list of parameters of the bounding box for this face (on processedImage)                                                                                    |
| probability                | float   | probability that a found face is actually a face (on processedImage)                                                                                        |
| x_max, y_max, x_min, y_min | integer | coordinates of the frame containing the face (on processedImage)                                                                                            |
| landmarks                  | array   | list of the coordinates of the frame containing the face-landmarks. Return only if [landmarks plugin](Face-services-and-plugins.md#face-plugins) is enabled |
| execution_time             | object  | execution time of all plugins                                                                                                                               |
| plugins_versions           | object  | contains information about plugin versions                                                                                                                  |


## Face Verification Service 人脸验证服务

To compare faces from given two images:
从给出的两张图片比较人脸


```shell
curl  -X POST "http://localhost:8000/api/v1/verification/verify?limit=<limit>&prediction_count=<prediction_count>&det_prob_threshold=<det_prob_threshold>&face_plugins=<face_plugins>&status=<status>" \
-H "Content-Type: multipart/form-data" \
-H "x-api-key: <service_api_key>" \
-F source_image=<local_check_file>
-F target_image=<local_process_file>
```


| 元素            | 描述 | 类型    | 是 | 备注                                                                                                                                                 |
|--------------------|-------------|---------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------------|
| Content-Type       | header      | 字符串  | 是 | multipart/form-data                                                                                                                                   |
| x-api-key          | header      | 字符串  | 是 | api key of the Face verification service, created by the user                                                                                         |
| source_image       | body        | image   | 是 | file to be verified. Allowed image formats: jpeg, jpg, ico, png, bmp, gif, tif, tiff, webp. Max size is 5Mb                                           |
| target_image       | body        | image   | 是 | reference file to check the source file. Allowed image formats: jpeg, jpg, ico, png, bmp, gif, tif, tiff, webp. Max size is 5Mb                       |
| limit              | param       | integer | optional | maximum number of faces on the target image to be recognized. It recognizes the biggest faces first. Value of 0 represents no limit. Default value: 0 |
| det_prob_threshold | param       | 字符串  | optional | minimum required confidence that a recognized face is actually a face. Value is between 0.0 and 1.0.                                                  |
| face_plugins       | param       | 字符串  | optional | comma-separated slugs of face plugins. If empty, no additional information is returned. [Learn more](Face-services-and-plugins.md)                    |
| status             | param       | boolean | optional | if true includes system information like execution_time and plugin_version fields. Default value is false                                             |

成功响应正文:
```json
{
  "result" : [{
    "source_image_face" : {
      "age" : {
        "probability": 0.9308982491493225,
        "high": 32,
        "low": 25
      },
      "gender" : {
        "probability": 0.9898611307144165,
        "value": "female"
      },
      "mask" : {
        "probability": 0.9999470710754395,
        "value": "without_mask"
      },
      "embedding" : [ -0.0010271212086081505, "...", -0.008746841922402382 ],
      "box" : {
        "probability" : 0.9997453093528748,
        "x_max" : 205,
        "y_max" : 167,
        "x_min" : 48,
        "y_min" : 0
      },
      "landmarks" : [ [ 92, 44 ], [ 130, 68 ], [ 71, 76 ], [ 60, 104 ], [ 95, 125 ] ],
      "execution_time" : {
        "age" : 85.0,
        "gender" : 51.0,
        "detector" : 67.0,
        "calculator" : 116.0,
        "mask": 36.0
      }
    },
    "face_matches": [
      {
        "age" : {
          "probability": 0.9308982491493225,
          "high": 32,
          "low": 25
        },
        "gender" : {
          "probability": 0.9898611307144165,
          "value": "female"
        },
        "mask" : {
          "probability": 0.9999470710754395,
          "value": "without_mask"
        },
        "embedding" : [ -0.049007344990968704, "...", -0.01753818802535534 ],
        "box" : {
          "probability" : 0.99975,
          "x_max" : 308,
          "y_max" : 180,
          "x_min" : 235,
          "y_min" : 98
        },
        "landmarks" : [ [ 260, 129 ], [ 273, 127 ], [ 258, 136 ], [ 257, 150 ], [ 269, 148 ] ],
        "similarity" : 0.97858,
        "execution_time" : {
          "age" : 59.0,
          "gender" : 30.0,
          "detector" : 177.0,
          "calculator" : 70.0,
          "mask": 36.0
        }
      }],
    "plugins_versions" : {
      "age" : "agegender.AgeDetector",
      "gender" : "agegender.GenderDetector",
      "detector" : "facenet.FaceDetector",
      "calculator" : "facenet.Calculator",
      "mask": "facemask.MaskDetector"
    }
  }]
}
```

| 元素            | 类型 | 描述                                                                                                                                                 |
|----------------------------|---------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| source_image_face          | object  | additional info about source image face                                                                                                                     |
| face_matches               | array   | result of face verification                                                                                                                                 |
| age                        | object  | detected age range. Return only if [age plugin](Face-services-and-plugins.md#face-plugins) is enabled                                                       |
| gender                     | object  | detected gender. Return only if [gender plugin](Face-services-and-plugins.md#face-plugins) is enabled                                                       |
| mask                       | object  | detected mask. Return only if [face mask plugin](Face-services-and-plugins.md#face-plugins) is enabled                                                      |
| embedding                  | array   | face embeddings. Return only if [calculator plugin](Face-services-and-plugins.md#face-plugins) is enabled                                                   |
| box                        | object  | list of parameters of the bounding box for this face                                                                                                        |
| probability                | float   | probability that a found face is actually a face                                                                                                            |
| x_max, y_max, x_min, y_min | integer | coordinates of the frame containing the face                                                                                                                |
| landmarks                  | array   | list of the coordinates of the frame containing the face-landmarks. Return only if [landmarks plugin](Face-services-and-plugins.md#face-plugins) is enabled |
| similarity                 | float   | similarity between this face and the face on the source image                                                                                               |
| execution_time             | object  | execution time of all plugins                                                                                                                               |
| plugins_versions           | object  | contains information about plugin versions                                                                                                                  |



## Base64 支持
`since 0.5.1 version`

Except `multipart/form-data`, all CompreFace endpoints, that require images as input, accept images in `Base64` format. 
The base rule is to use `Content-Type: application/json` header and send JSON in the body. 
The name of the JSON parameter coincides with the name of the `multipart/form-data` parameter.

### 添加一个主题示例, Base64
Full description [here](#add-an-example-of-a-subject).

```shell
curl -X POST "http://localhost:8000/api/v1/recognition/faces?subject=<subject>&det_prob_threshold=<det_prob_threshold>" \
-H "Content-Type: application/json" \
-H "x-api-key: <service_api_key>" \
-d {"file": "<base64_value>"}
```

### 给出图片识别人脸, Base64
Full description [here](#recognize-faces-from-a-given-image).

```shell
curl  -X POST "http://localhost:8000/api/v1/recognition/recognize?limit=<limit>&prediction_count=<prediction_count>&det_prob_threshold=<det_prob_threshold>&face_plugins=<face_plugins>&status=<status>" \
-H "Content-Type: application/json" \
-H "x-api-key: <service_api_key>" \
-d {"file": "<base64_value>"}
```

### 给出图片验证人脸, Base64
Full description [here](#verify-faces-from-a-given-image).

```shell
curl -X POST "http://localhost:8000/api/v1/recognition/faces/<image_id>/verify?
limit=<limit>&det_prob_threshold=<det_prob_threshold>&face_plugins=<face_plugins>&status=<status>" \
-H "Content-Type: application/json" \
-H "x-api-key: <service_api_key>" \
-d {"file": "<base64_value>"}
```

### 人脸探测服务, Base64
Full description [here](#face-detection-service).

```shell
curl  -X POST "http://localhost:8000/api/v1/detection/detect?limit=<limit>&det_prob_threshold=<det_prob_threshold>&face_plugins=<face_plugins>&status=<status>" \
-H "Content-Type: application/json" \
-H "x-api-key: <service_api_key>" \
-d {"file": "<base64_value>"}
```

### 人脸验证服务, Base64
Full description [here](#face-verification-service).

```shell
curl -X POST "http://localhost:8000/api/v1/verification/verify?limit=<limit>&prediction_count=<prediction_count>&det_prob_threshold=<det_prob_threshold>&face_plugins=<face_plugins>&status=<status>" \
-H "Content-Type: application/json" \
-H "x-api-key: <service_api_key>" \
-d {"source_image": "<source_image_base64_value>", "target_image": "<target_image_base64_value>"}
```

