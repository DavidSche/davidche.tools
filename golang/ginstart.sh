#!/bin/bash
# author:David
# url:davidsche.github.io

echo "设置Aliyun代理";

go env -w  GO111MODULE=on

go env -w CGO_ENABLED=0

go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/

echo "创建 $1 应用";

echo "创建目录：$1";
mkdir $1
cd ./$1

echo "初始化应用：$1";
go mod init $1
mkdir inits controllers middlewares migrations models

echo "获取$1 依赖:";
echo "github.com/githubnemo/CompileDaemon:";
go get github.com/githubnemo/CompileDaemon
go install github.com/githubnemo/CompileDaemon

echo "github.com/joho/godotenv:";
go get github.com/joho/godotenv

echo "github.com/gin-gonic/gin:";
go get -u github.com/gin-gonic/gin

echo "gorm.io/gorm:";
go get -u gorm.io/gorm

echo "gorm.io/driver/mysql:";
go get -u gorm.io/driver/mysql

echo "golang.org/x/crypto/bcrypt:";
go get -u golang.org/x/crypto/bcrypt

echo "github.com/golang-jwt/jwt/v5:";
go get -u github.com/golang-jwt/jwt/v5


echo "write  project $1 source code files :";

cat << EOF > ./.env

PORT=6060
DB_URL="root:rootroot@tcp(192.168.108.180:3306)/mydemo?charset=utf8mb4&parseTime=True&loc=Local"


EOF
echo "-------./.env-----------";

cat << EOF > ./inits/envLoader.go

package inits

import (
 "log"

 "github.com/joho/godotenv"
)

func LoadEnv() {
 err := godotenv.Load()
 if err != nil {
  log.Fatal("Error loading .env file")
 }
}

EOF

echo "------./inits/envLoader.go------------";
echo "write ./init/db.go";

cat << EOF > ./inits/db.go

package inits

import (
 "os"

 "gorm.io/driver/mysql"
 "gorm.io/gorm"
)

var DB *gorm.DB

func DBInit() {
 dsn := os.Getenv("DB_URL")
 db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
 if err != nil {
  panic("failed to connect database")
 }

 DB = db
}

EOF

echo "------./init/db.go------------";

cat << EOF > ./main.go
package main

import (

     "$1/inits"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func IndexHandler(c *gin.Context) {
	name := c.Params.ByName("name")
	c.JSON(200, gin.H{
		"message": "Welcome to Building RESTful API using Gin and Gorm! " + name,
	})
}

func init() {

 //
 inits.LoadEnv()
 //
 inits.DBInit()
 
}

func main() {
	router := gin.Default()
	router.GET("/", IndexHandler)
	router.Run()
	//http.ListenAndServe(":6060", router)
}

EOF


echo "-------./main.go-----------";


echo "write dockfile:";

cat << EOF > ./Dockerfile

FROM golang:latest

ENV PROJECT_DIR=/app \
    GO111MODULE=on \
    CGO_ENABLED=0

WORKDIR /app
RUN mkdir "/build"
COPY . .
RUN go get github.com/githubnemo/CompileDaemon
RUN go install github.com/githubnemo/CompileDaemon
ENTRYPOINT CompileDaemon -build="go build -o /build/app" -command="/build/app"


EOF

echo "-------./Dockerfile-----------";

echo "write dockfile:";

cat << EOF > ./docker-compose.yml
version: '3'

services:
  app:
    build:
      context: .
      dockerfile: ./Dockerfile
    volumes:
      - ./:/app
	
EOF
echo "-------./docker-compose.yml-----------";

echo "Run CompileDaemon:";

CompileDaemon -command="./$1"
