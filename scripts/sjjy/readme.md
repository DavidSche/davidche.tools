version: '3.6'

services:
  gateway:
    image: '192.168.9.10:5000/sjjy-gateway:1.0.0'
    ports:
      - '8700:8700'
    environment:
      - SPRING_PROFILES_ACTIVE=test
    volumes:
      - /home/cqy/log:/usr/cqy/log
    networks:
      - prod
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.labels.server == true]  # 部署标签约束

  config-manager:
    image: '192.168.9.10:5000/sjjy-config-manager:1.0.0'
#    ports:
#      - '8700:8700'
    environment:
      - SPRING_PROFILES_ACTIVE=test
    volumes:
      - /home/cqy/log:/usr/cqy/log
    networks:
      - prod
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.labels.server == true]  # 部署标签约束

  tool:
    image: '192.168.9.10:5000/sjjy-tool:1.0.0'
#    ports:
#      - '8700:8700'
    environment:
      - SPRING_PROFILES_ACTIVE=test
    volumes:
      - /home/cqy/log:/usr/cqy/log
    networks:
      - prod
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.labels.server == true]  # 部署标签约束        

  message-manager:
    image: '192.168.9.10:5000/sjjy-message-manager:1.0.0'
#    ports:
#      - '8700:8700'
    environment:
      - SPRING_PROFILES_ACTIVE=test
    volumes:
      - /home/cqy/log:/usr/cqy/log
    networks:
      - prod
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.labels.server == true]  # 部署标签约束 

  job-manager:
    image: '192.168.9.10:5000/sjjy-job-manager:1.0.0'
#    ports:
#      - '8700:8700'
    environment:
      - SPRING_PROFILES_ACTIVE=test
    volumes:
      - /home/cqy/log:/usr/cqy/log
    networks:
      - prod
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.labels.server == true]  # 部署标签约束 

  authentication-server:
    image: '192.168.9.10:5000/sjjy-authentication-server:1.0.0'
#    ports:
#      - '8700:8700'
    environment:
      - SPRING_PROFILES_ACTIVE=test
    volumes:
      - /home/cqy/log:/usr/cqy/log
    networks:
      - prod
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.labels.server == true]  # 部署标签约束 

  user-manager:
    image: '192.168.9.10:5000/sjjy-user-manager:1.0.0'
#    ports:
#      - '8700:8700'
    environment:
      - SPRING_PROFILES_ACTIVE=test
    volumes:
      - /home/cqy/log:/usr/cqy/log
    networks:
      - prod
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.labels.server == true]  # 部署标签约束 

  api-gateway:
    image: '192.168.9.10:5000/sjjy-api-gateway:1.0.0'
#    ports:
#      - '8900:8900'
    environment:
      - SPRING_PROFILES_ACTIVE=test
    volumes:
      - /home/cqy/log:/usr/cqy/log
    networks:
      - prod
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.labels.server == true]  # 部署标签约束 

  workflow-manager:
    image: '192.168.9.10:5000/sjjy-workflow-manager:1.0.0'
#    ports:
#      - '8700:8700'
    environment:
      - SPRING_PROFILES_ACTIVE=test
    volumes:
      - /home/cqy/log:/usr/cqy/log
    networks:
      - prod
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.labels.server == true]  # 部署标签约束 

  website-manager:
    image: '192.168.9.10:5000/sjjy-website-manager:1.0.0'
#    ports:
#      - '8700:8700'
    environment:
      - SPRING_PROFILES_ACTIVE=test
    volumes:
      - /home/cqy/log:/usr/cqy/log
    networks:
      - prod
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.labels.server == true]  # 部署标签约束
#
  website-ui:
    image: '192.168.9.10:5000/sjjy-website-ui:0.0.1-SNAPSHOT'
    ports:
      - '8888:8888'
#    environment:
#      - SPRING_PROFILES_ACTIVE=test
#    volumes:
#      - /home/cqy/log:/usr/cqy/log
    networks:
      - prod
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.labels.ui == true]  # 部署标签约束
#personal 
  portal-ui:
    image: '192.168.9.10:5000/sjjy-portal-ui:0.0.1-SNAPSHOT'
    ports:
      - '81:80'
#    environment:
#      - SPRING_PROFILES_ACTIVE=test
#    volumes:
#      - /home/cqy/log:/usr/cqy/log
    networks:
      - prod
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.labels.ui == true]  # 部署标签约束

  manager-ui:
    image: '192.168.9.10:5000/sjjy-manager-ui:0.0.1-SNAPSHOT'
    ports:
      - '8080:8080'
#    environment:
#      - SPRING_PROFILES_ACTIVE=test
#    volumes:
#      - /home/cqy/log:/usr/cqy/log
    networks:
      - prod
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.labels.ui == true]  # 部署标签约束
#volumes:
#  es-data:

networks:
  prod:
    external: true
