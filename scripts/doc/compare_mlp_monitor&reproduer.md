# 机器学习

## MLflow

https://github.com/mlflow/mlflow

### Pros

* UI (tracking and comparing)
* Run ML projects with different parameters
* Serving
* reproduce with conda config file

### Cons

* weak store (store in local file, slow to load)
* ugly code
* do not support save artifacts to user server
* model serving is weak

## Polyaxon

https://github.com/polyaxon/polyaxon

### Pros

* use Docker
* UI
* Notebook plugins
* Tensorboard
* Hyperparameters tuning

### Cons

* coupled to k8s
* hard to deploy and debug

## DVC

https://dvc.org/

### Pros

* built for large data version control
* data saved in cloud or local or HDFS
* support reproduce experiments with user histroy

### Cons

* not easy to use when user want to record the experiments
* beta
  
--------

# Design of Deep Learning Model Projects

Questions:

- How to organise different kinds of models?
- How to design user-friendly interface?
- How to make it easy to train and evaluation?
- Is it necessary to offer CLI?
- How to make it feasible for different frameworks?

## Fairseq

A sequence-to-sequence toolkitto train custom models for translation, summarization, language modeling and other text generation tasks.

### Features

- Friendly CLI
- Easy to define new models
- All the models registered can be used conveniently
- Models can be customized with different parameters
- Criterions and optimizer wrapper
- Learning rate schedulers

### Implementation

- Models are made up of modules
- Archs are the same model with different parameters
- Register modules, models, archs, even tasks
- Base config -> models add config -> fianl arch
- Base config -> scheduler

## FastAI

Offer "out of the box" support for vision, text, tabular, and collab models.

### Features

- Easy to save & load models
- Easy to download and load data
- Create model: `create_model_name(data, model_config, metrics)`
- Train for specified epoches with specified hyper parameters like learning rate
- Plot metrics
- Easy-to-use function for data loading

### Implementation

- Python type hints (can use tools to check, like [`mypy`](https://github.com/python/mypy). Details about type hints can be found in [PEP 484](https://www.python.org/dev/peps/pep-0484/)
- Ugly code
