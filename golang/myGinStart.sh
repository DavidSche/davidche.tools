#!/bin/bash
# author:David
# url:davidsche.github.io

echo "设置Aliyun代理";

go env -w  GO111MODULE=on

go env -w CGO_ENABLED=0

#go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
go env -w GOPROXY=https://goproxy.cn,direct

echo "创建 $1 应用";

echo "创建目录：$1";
mkdir $1
cd ./$1

echo "初始化应用：$1";
go mod init $1
mkdir -p  cmd config  deployments internal test pkg/inits
mkdir -p  pkg/controllers/ pkg/repository pkg/helpers pkg/models pkg/routers  pkg/routers/middleware pkg/migrations
mkdir -p  internal/infra/database internal/infra/logger

echo "获取$1 依赖:";
echo "github.com/githubnemo/CompileDaemon:";
go get github.com/githubnemo/CompileDaemon

go install github.com/githubnemo/CompileDaemon

echo "github.com/joho/godotenv:";
go get github.com/joho/godotenv

echo "github.com/sirupsen/logrus:";
go get -u github.com/sirupsen/logrus

echo "github.com/spf13/viper:";
go get -u github.com/spf13/viper

echo "github.com/gin-gonic/gin:";
go get -u github.com/gin-gonic/gin

echo "gorm.io/gorm:";
go get -u gorm.io/gorm

echo "gorm.io/driver/mysql:";
go get -u gorm.io/driver/mysql

echo "gorm.io/driver/postgres:";
go get gorm.io/driver/postgres
#go get gorm.io/driver/postgres

echo "gorm.io/plugin/dbresolver:";
go get  gorm.io/plugin/dbresolver
# go get gorm.io/plugin/dbresolver

echo "golang.org/x/crypto/bcrypt:";
go get -u golang.org/x/crypto/bcrypt

echo "github.com/golang-jwt/jwt/v5:";
go get -u github.com/golang-jwt/jwt/v5

echo "write  project $1 source code files :";

echo "write  ./.env source code files :";

cat << EOF > ./internal/infra/database/database.go
package database

import (
	"github.com/spf13/viper"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"gorm.io/plugin/dbresolver"
	"log"
)

var (
	DB  *gorm.DB
	err error
)

// DbConnection create database connection
func DbConnection(masterDSN, replicaDSN string) error {
	var db = DB

	logMode := viper.GetBool("DB_LOG_MODE")
	debug := viper.GetBool("DEBUG")

	loglevel := logger.Silent
	if logMode {
		loglevel = logger.Info
	}

	db, err = gorm.Open(postgres.Open(masterDSN), &gorm.Config{
		Logger: logger.Default.LogMode(loglevel),
	})
	if !debug {
		db.Use(dbresolver.Register(dbresolver.Config{
			Replicas: []gorm.Dialector{
				postgres.Open(replicaDSN),
			},
			Policy: dbresolver.RandomPolicy{},
		}))
	}
	if err != nil {
		log.Fatalf("Db connection error")
		return err
	}
	DB = db
	return nil
}

// GetDB connection
func GetDB() *gorm.DB {
	return DB
}

EOF

echo "------ ./internal/infra/database/database.go ------------";

echo "write  ./internal/infra/logger source code files :";

cat << EOF > ./internal/infra/logger/logger.go
package logger

import (
	"bytes"
	"github.com/sirupsen/logrus"
	"strings"
	"time"
)

var logger = logrus.New()

func init() {
	logger.Level = logrus.InfoLevel
	logger.Formatter = &formatter{}

	logger.SetReportCaller(true)
}

func SetLogLevel(level logrus.Level) {
	logger.Level = level
}

type Fields logrus.Fields

// Debugf logs a message at level Debug on the standard logger.
func Debugf(format string, args ...interface{}) {
	if logger.Level >= logrus.DebugLevel {
		entry := logger.WithFields(logrus.Fields{})
		entry.Debugf(format, args...)
	}
}

// Infof logs a message at level Info on the standard logger.
func Infof(format string, args ...interface{}) {
	if logger.Level >= logrus.InfoLevel {
		entry := logger.WithFields(logrus.Fields{})
		entry.Infof(format, args...)
	}
}

// Warnf logs a message at level Warn on the standard logger.
func Warnf(format string, args ...interface{}) {
	if logger.Level >= logrus.WarnLevel {
		entry := logger.WithFields(logrus.Fields{})
		entry.Warnf(format, args...)
	}
}

// Errorf logs a message at level Error on the standard logger.
func Errorf(format string, args ...interface{}) {
	if logger.Level >= logrus.ErrorLevel {
		entry := logger.WithFields(logrus.Fields{})
		entry.Errorf(format, args...)
	}
}

// Fatalf logs a message at level Fatal on the standard logger.
func Fatalf(format string, args ...interface{}) {
	if logger.Level >= logrus.FatalLevel {
		entry := logger.WithFields(logrus.Fields{})
		entry.Fatalf(format, args...)
	}
}

// Formatter implements logrus.Formatter interface.
type formatter struct {
	prefix string
}

// Format building log message.
func (f *formatter) Format(entry *logrus.Entry) ([]byte, error) {
	var sb bytes.Buffer

	sb.WriteString(strings.ToUpper(entry.Level.String()))
	sb.WriteString(" ")
	sb.WriteString(entry.Time.Format(time.RFC3339))
	sb.WriteString(" ")
	sb.WriteString(f.prefix)
	sb.WriteString(entry.Message)

	return sb.Bytes(), nil
}

EOF

echo "------  ------------";


echo "write  ./.env  files :";

cat << EOF > ./.env

# Server Config

SECRET=h9wt*pasj6796j##w(w8=xaje8tpi6h*r&hzgrz065u&ed+k2)
DEBUG=False
ALLOWED_HOSTS=0.0.0.0
SERVER_HOST=0.0.0.0
SERVER_PORT=6060

# Database Config
DB_TYPE=MYSQL
MASTER_DB_NAME=mydemo
MASTER_DB_USER=root
MASTER_DB_PASSWORD=rootroot
MASTER_DB_HOST=192.168.108.180
MASTER_DB_PORT=3306
MASTER_DB_LOG_MODE=True
MASTER_SSL_MODE=disable

REPLICA_DB_NAME=mydemo
REPLICA_DB_USER=root
REPLICA_DB_PASSWORD=rootroot
REPLICA_DB_HOST=192.168.108.180
REPLICA_DB_PORT=3306
REPLICA_SSL_MODE=disable

EOF
echo "-------./.env-----------";

echo "begin *** ./config/ source code files :";

echo "write  ./config/config.go source code files :";
cat << EOF > ./config/config.go
package config

import (
	"$1/internal/infra/logger"
	"github.com/spf13/viper"
)

type Configuration struct {
	Server   ServerConfiguration
	Database DatabaseConfiguration
}

// SetupConfig configuration
func SetupConfig() error {
	var configuration *Configuration

	viper.SetConfigFile(".env")
	if err := viper.ReadInConfig(); err != nil {
		logger.Errorf("Error to reading config file, %s", err)
		return err
	}

	err := viper.Unmarshal(&configuration)
	if err != nil {
		logger.Errorf("error to decode, %v", err)
		return err
	}

	return nil
}

EOF

echo "------./config/config.go------------";

echo "write  ./config/db.go source code files :";

cat << EOF > ./config/db.go
package config

import (
	"fmt"
	"github.com/spf13/viper"
)

type DatabaseConfiguration struct {
	Driver   string
	Dbname   string
	Username string
	Password string
	Host     string
	Port     string
	LogMode  bool
}

func DbConfiguration() (string, string) {
	masterDBName := viper.GetString("MASTER_DB_NAME")
	masterDBUser := viper.GetString("MASTER_DB_USER")
	masterDBPassword := viper.GetString("MASTER_DB_PASSWORD")
	masterDBHost := viper.GetString("MASTER_DB_HOST")
	masterDBPort := viper.GetString("MASTER_DB_PORT")
	masterDBSslMode := viper.GetString("MASTER_SSL_MODE")

	replicaDBName := viper.GetString("REPLICA_DB_NAME")
	replicaDBUser := viper.GetString("REPLICA_DB_USER")
	replicaDBPassword := viper.GetString("REPLICA_DB_PASSWORD")
	replicaDBHost := viper.GetString("REPLICA_DB_HOST")
	replicaDBPort := viper.GetString("REPLICA_DB_PORT")
	replicaDBSslMode := viper.GetString("REPLICA_SSL_MODE")

	var masterDBDSN, replicaDBDSN string

	dbType := viper.GetString("DB_TYPE")

	if dbType == "MYSQL" {
		masterDBDSN = fmt.Sprintf("%s:%s@(%s:%s)/%s?charset=utf8",
			masterDBUser,
			masterDBPassword,
			masterDBHost,
			masterDBPort,
			masterDBName)
		replicaDBDSN = fmt.Sprintf("%s:%s@(%s:%s)/%s?charset=utf8",
			replicaDBUser,
			replicaDBPassword,
			replicaDBHost,
			replicaDBPort,
			replicaDBName)

		return masterDBDSN, replicaDBDSN
	} else if dbType == "POSTGRESQL" {
		masterDBDSN = fmt.Sprintf(
			"host=%s user=%s password=%s dbname=%s port=%s sslmode=%s",
			masterDBHost, masterDBUser, masterDBPassword, masterDBName, masterDBPort, masterDBSslMode,
		)

		replicaDBDSN = fmt.Sprintf(
			"host=%s user=%s password=%s dbname=%s port=%s sslmode=%s",
			replicaDBHost, replicaDBUser, replicaDBPassword, replicaDBName, replicaDBPort, replicaDBSslMode,
		)
	} else {

	}
	return masterDBDSN, replicaDBDSN
}


EOF

echo "------ ./config/db.go   ------------";
echo "write  ./config/server.go source code files :";

cat << EOF > ./config/server.go
 package config

 import (
 	"fmt"
 	"github.com/spf13/viper"
 	"log"
 )

 type ServerConfiguration struct {
 	Port                 string
 	Secret               string
 	LimitCountPerRequest int64
 }

 func ServerConfig() string {
 	viper.SetDefault("SERVER_HOST", "0.0.0.0")
 	viper.SetDefault("SERVER_PORT", "8000")

 	appServer := fmt.Sprintf("%s:%s", viper.GetString("SERVER_HOST"), viper.GetString("SERVER_PORT"))
 	log.Print("Server Running at :", appServer)
 	return appServer
 }

EOF

echo "------ ./config/server.go ------------";

echo "end *** ./config/ source code files :";

echo "begin *** ./internal/ source code files:";

echo "write  ./internal/infra/database/database.go source code files :";

cat << EOF > ./internal/infra/database/database.go
package database

import (
	"github.com/spf13/viper"
	"gorm.io/driver/mysql"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"gorm.io/plugin/dbresolver"
	"log"
)

var (
	DB  *gorm.DB
	err error
)

// DbConnection create database connection
func DbConnection(masterDSN, replicaDSN string) error {
	var db = DB

	logMode := viper.GetBool("DB_LOG_MODE")
	debug := viper.GetBool("DEBUG")

	loglevel := logger.Silent
	if logMode {
		loglevel = logger.Info
	}

	dbType := viper.GetString("DB_TYPE")

	var replicaDb gorm.Dialector

	if dbType == "MYSQL" {
		db, err = gorm.Open(mysql.Open(masterDSN), &gorm.Config{
			Logger: logger.Default.LogMode(loglevel),
		})
		replicaDb = mysql.Open(replicaDSN)
	} else if dbType == "POSTGRESQL" {
		db, err = gorm.Open(postgres.Open(masterDSN), &gorm.Config{
			Logger: logger.Default.LogMode(loglevel),
		})
		replicaDb = postgres.Open(replicaDSN)
	}

	if !debug {
		err = db.Use(dbresolver.Register(dbresolver.Config{
			Replicas: []gorm.Dialector{
				replicaDb,
			},
			Policy: dbresolver.RandomPolicy{},
		}))
	}
	if err != nil {
		log.Fatalf("Db connection error")
		return err
	}
	DB = db
	return nil
}

// GetDB connection
func GetDB() *gorm.DB {
	return DB
}

EOF

echo "------ ./internal/infra/database/database.go ------------";

echo "write  ./internal/infra/logger/logger.go source code files :";

cat << EOF > ./internal/infra/logger/logger.go
 package logger

 import (
 	"bytes"
 	"github.com/sirupsen/logrus"
 	"strings"
 	"time"
 )

 var logger = logrus.New()

 func init() {
 	logger.Level = logrus.InfoLevel
 	logger.Formatter = &formatter{}

 	logger.SetReportCaller(true)
 }

 func SetLogLevel(level logrus.Level) {
 	logger.Level = level
 }

 type Fields logrus.Fields

 // Debugf logs a message at level Debug on the standard logger.
 func Debugf(format string, args ...interface{}) {
 	if logger.Level >= logrus.DebugLevel {
 		entry := logger.WithFields(logrus.Fields{})
 		entry.Debugf(format, args...)
 	}
 }

 // Infof logs a message at level Info on the standard logger.
 func Infof(format string, args ...interface{}) {
 	if logger.Level >= logrus.InfoLevel {
 		entry := logger.WithFields(logrus.Fields{})
 		entry.Infof(format, args...)
 	}
 }

 // Warnf logs a message at level Warn on the standard logger.
 func Warnf(format string, args ...interface{}) {
 	if logger.Level >= logrus.WarnLevel {
 		entry := logger.WithFields(logrus.Fields{})
 		entry.Warnf(format, args...)
 	}
 }

 // Errorf logs a message at level Error on the standard logger.
 func Errorf(format string, args ...interface{}) {
 	if logger.Level >= logrus.ErrorLevel {
 		entry := logger.WithFields(logrus.Fields{})
 		entry.Errorf(format, args...)
 	}
 }

 // Fatalf logs a message at level Fatal on the standard logger.
 func Fatalf(format string, args ...interface{}) {
 	if logger.Level >= logrus.FatalLevel {
 		entry := logger.WithFields(logrus.Fields{})
 		entry.Fatalf(format, args...)
 	}
 }

 // Formatter implements logrus.Formatter interface.
 type formatter struct {
 	prefix string
 }

 // Format building log message.
 func (f *formatter) Format(entry *logrus.Entry) ([]byte, error) {
 	var sb bytes.Buffer

 	sb.WriteString(strings.ToUpper(entry.Level.String()))
 	sb.WriteString(" ")
 	sb.WriteString(entry.Time.Format(time.RFC3339))
 	sb.WriteString(" ")
 	sb.WriteString(f.prefix)
 	sb.WriteString(entry.Message)

 	return sb.Bytes(), nil
 }

EOF

echo "------ ./internal/infra/logger/logger.go ------------";

echo "end *** ./internal/ source code files:";

echo "begin *** ./pkg/ source code files:";
echo "write  ./pkg/controllers/userController.go source code files :";

cat << EOF > ./pkg/controllers/userController.go
 package controllers

 import (
 	"$1/pkg/models"
 	"$1/pkg/repository"
 	"github.com/gin-gonic/gin"
 	"net/http"
 )

 func GetData(ctx *gin.Context) {
 	var user []*models.User
 	repository.Get(&user)
 	ctx.JSON(http.StatusOK, &user)

 }

EOF

echo "------ ./pkg/controllers/userController.go ------------";

echo "write  ./pkg/helpers/helpers.go source code files :";

cat << EOF > ./pkg/helpers/helpers.go
package helpers

type Response struct {
	Code    int
	Message string
	Data    interface{}
}

EOF

echo "------ ./pkg/helpers/helpers.go ------------";

echo "write  ./pkg/helpers/search.go source code files :";

cat << EOF > ./pkg/helpers/search.go
package helpers

import "gorm.io/gorm"

func Search(search, field string) func(db *gorm.DB) *gorm.DB {
	return func(db *gorm.DB) *gorm.DB {
		if search != "" {
			db = db.Where("%"+field+"% ? LIKE", "%"+search+"%")
			//db = db.Or("description LIKE ?", "%"+search+"%")
		}
		return db
	}
}
EOF

echo "------ ./pkg/helpers/search.go ------------";

echo "write  ./pkg/models/userModel.go source code files :";

cat << EOF > ./pkg/models/userModel.go
package models

import (
	"time"
)

type User struct {
	Id        int        `json:"id"`
	name      string     `json:"name" binding:"required"`
	password  string     `json:"password" binding:"required"`
	Data      string     `json:"data" binding:"required"`
	CreatedAt *time.Time `json:"created_at,string,omitempty"`
	UpdatedAt *time.Time `json:"updated_at_at,string,omitempty"`
}

// TableName is Database TableName of this model
func (e *User) TableName() string {
	return "user"
}

EOF

echo "------ ./pkg/models/userModel.go ------------";

echo "write  ./pkg/repository/sqlRepo source code files :";

cat << EOF > ./pkg/repository/sqlRepo.go
package repository

import (
	"gin-boilerplate/internal/infra/database"
	"gin-boilerplate/internal/infra/logger"
)

func Save(model interface{}) interface{} {
	err := database.DB.Create(model).Error
	if err != nil {
		logger.Errorf("error, not save data %v", err)
	}
	return err
}

func Get(model interface{}) interface{} {
	err := database.DB.Find(model).Error
	return err
}

func GetOne(model interface{}) interface{} {
	err := database.DB.Last(model).Error
	return err
}

func Update(model interface{}) interface{} {
	err := database.DB.Find(model).Error
	return err
}

EOF

echo "------ ./pkg/repository/sqlRepo.go ------------";

echo "write  ./pkg/routers/middleware/cors.go source code files :";

cat << EOF > ./pkg/routers/middleware/cors.go
package middleware

import (
	"github.com/gin-gonic/gin"
	"log"
)

func CORSMiddleware() gin.HandlerFunc {
	return func(ctx *gin.Context) {
		ctx.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		ctx.Writer.Header().Set("Access-Control-Max-Age", "86400")
		ctx.Writer.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE, UPDATE")
		ctx.Writer.Header().Set("Access-Control-Allow-Headers", "Origin, Content-Type, api_key, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
		ctx.Writer.Header().Set("Access-Control-Expose-Headers", "Content-Length")
		ctx.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		ctx.Writer.Header().Set("Cache-Control", "no-cache")

		if ctx.Request.Method == "OPTIONS" {
			log.Println("OPTIONS")
			ctx.AbortWithStatus(200)
		} else {
			ctx.Next()
		}
	}
}
EOF

echo "------ ./pkg/routers/middleware/cors.go ------------";

echo "write  ./pkg/routers/router.go source code files :";

cat << EOF > ./pkg/routers/router.go
package routers

import (
	"$1/internal/infra/logger"
	"$1/pkg/routers/middleware"
	"github.com/gin-gonic/gin"
	"github.com/spf13/viper"
)

func SetupRoute() *gin.Engine {

	environment := viper.GetBool("DEBUG")
	if environment {
		gin.SetMode(gin.DebugMode)
	} else {
		gin.SetMode(gin.ReleaseMode)
	}

	allowedHosts := viper.GetString("ALLOWED_HOSTS")
	router := gin.New()
	err := router.SetTrustedProxies([]string{allowedHosts})
	if err != nil {
		logger.Errorf("SetTrustedProxies error!!! ")
	}
	router.Use(gin.Logger())
	router.Use(gin.Recovery())
	router.Use(middleware.CORSMiddleware())

	RegisterRoutes(router) //routes register

	return router
}

EOF

echo "------ ./pkg/routers/router.go ------------";

echo "write  ./pkg/routers/index.go source code files :";

cat << EOF > ./pkg/routers/index.go
package routers

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

//RegisterRoutes add all routing list here automatically get main router
func RegisterRoutes(route *gin.Engine) {
	route.NoRoute(func(ctx *gin.Context) {
		ctx.JSON(http.StatusNotFound, gin.H{"status": http.StatusNotFound, "message": "Route Not Found"})
	})
	route.GET("/health", func(ctx *gin.Context) { ctx.JSON(http.StatusOK, gin.H{"live": "ok"}) })

	//Add All route
	//TestRoutes(route)
}
EOF

echo "------ ./pkg/routers/index.go ------------";

echo "write  ./main.go source code files :";

cat << EOF > ./main.go
 package main

 import (
 	"$1/config"
 	"$1/internal/infra/database"
 	"$1/internal/infra/logger"
 	"$1/pkg/migrations"
 	"$1/pkg/routers"
 	"github.com/spf13/viper"
 	"time"
 )

 func main() {

 	//set timezone
 	viper.SetDefault("SERVER_TIMEZONE", "Asia/Dhaka")
 	loc, _ := time.LoadLocation(viper.GetString("SERVER_TIMEZONE"))
 	time.Local = loc

 	if err := config.SetupConfig(); err != nil {
 		logger.Fatalf("config SetupConfig() error: %s", err)
 	}
 	masterDSN, replicaDSN := config.DbConfiguration()

 	if err := database.DbConnection(masterDSN, replicaDSN); err != nil {
 		logger.Fatalf("database DbConnection error: %s", err)
 	}
 	//later separate migration
 	//migrations.Migrate()

 	router := routers.SetupRoute()
 	logger.Fatalf("%v", router.Run(config.ServerConfig()))

 }

EOF

echo "------ ./main.go ------------";

echo "write  ./pkg/migrations/migration.go source code files :";

cat << EOF > ./pkg/migrations/migration.go
package migrations

import (
	"$1/internal/infra/database"
	"$1/pkg/models"
)

// Migrate Add list of model add for migrations
// TODO later separate migration each models
func Migrate() {
	var migrationModels = []interface{}{&models.User{}}
	err := database.DB.AutoMigrate(migrationModels...)
	if err != nil {
		return
	}
}

EOF

echo "------ ./pkg/migrations/migration.go ------------";

echo "write test/test.http:";

cat << EOF > ./test/test.http

###
###
POST http://localhost:6060/users
Accept: application/json

{
    "name": "Adams Adebayo",
    "email":"adea@ml.com",
    "password": "12345"
}

###
GET http://localhost:6060/users
Accept: application/json

###
POST http://localhost.50:6060/login
Accept: application/json

{
    "email":"adea@ml.com",
    "password": "12345"
}

###
GET http://localhost:6060/auth
Accept: application/json

EOF

echo "-------./Dockerfile-----------";


echo "write deployments/dockfile:";

cat << EOF > ./deployments/Dockerfile
# Start from golang base image
FROM golang:1.17-alpine as builder

# Install git.
RUN apk update && apk add --no-cache git

# Working directory
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies
RUN go mod download

# Copy everythings
COPY . .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -mod=readonly -v -o main .

# Start a new stage from scratch
FROM alpine:latest
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the Pre-built binary file from the previous stage. Also copy config yml file
COPY --from=builder /app/main .
COPY --from=builder /app/.env.example .env

# Expose port 8080 to the outside world
EXPOSE 8000

#Command to run the executable
CMD ["./main"]

EOF

echo "-------./Dockerfile-----------";

echo "write deployments/dockfile-dev:";

cat << EOF > ./deployments/Dockerfile-dev
# Choose whatever you want, version >= 1.16
FROM golang:1.20-alpine

WORKDIR /app

RUN go install github.com/cosmtrek/air@latest

COPY go.mod go.sum ./
RUN go mod download

CMD ["air"]

EOF

echo "-------./deployments/Dockerfile-dev-----------";

echo "write ./deployments/docker-compose-prod.yml:";

cat << EOF > ./deployments/docker-compose-prod.yml
version: "3.8"

services:
  postgres_db:
    container_name: core_pg_db
    image: postgres:13-alpine
    environment:
      - POSTGRES_USER=${MASTER_DB_USER}
      - POSTGRES_PASSWORD=${MASTER_DB_PASSWORD}
      - POSTGRES_DB=${MASTER_DB_NAME}
    volumes:
      - prod_postgres_data:/var/lib/postgresql/data/
    restart: always

  server:
    container_name: go_server
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - ${SERVER_PORT}:${SERVER_PORT}
    depends_on:
      - postgres_db
    links:
      - postgres_db:postgres_db
    restart: on-failure

volumes:
  prod_postgres_data:

EOF
echo "-------./docker-compose.yml-----------";


echo "write ./deployments/docker-compose-dev.yml:";

cat << EOF > ./deployments/docker-compose-dev.yml
version: "3.8"

services:
  postgres_db:
    container_name: dev_pg_db
    image: postgres:13-alpine
    environment:
      - POSTGRES_USER=${MASTER_DB_USER}
      - POSTGRES_PASSWORD=${MASTER_DB_PASSWORD}
      - POSTGRES_DB=${MASTER_DB_NAME}
    volumes:
      - dev_postgres_data:/var/lib/postgresql/data/
    restart: always

  pgadmin:
    container_name: pgadmin4_container
    image: dpage/pgadmin4
    restart: always
    ports:
      - "5050:80"
    environment:
      - PGADMIN_DEFAULT_EMAIL=admin@admin.com
      - PGADMIN_DEFAULT_PASSWORD=root
    logging:
      driver: none
    volumes:
      - pgadmin_data:/var/lib/pgadmin

  server:
    container_name: dev_go_server
    build:
      context: .
      dockerfile: Dockerfile-dev
    ports:
      - ${SERVER_PORT}:${SERVER_PORT}
    depends_on:
      - postgres_db
    links:
      - postgres_db:postgres_db
    volumes:
      - .:/app
    restart: always

volumes:
  dev_postgres_data:
  pgadmin_data:
EOF
echo "-------./docker-compose.yml-----------";

echo "Run ./cmd/migrations.sh:";
#bash ./cmd/migrations.sh

echo "Run CompileDaemon:";

CompileDaemon -command="./$1"
