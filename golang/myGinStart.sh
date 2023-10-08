#!/bin/bash
# author:David
# url:davidsche.github.io
#ps aux |grep  wvp

  PROJECT=$1

echo "设置 Aliyun 代理";

go env -w  GO111MODULE=on

go env -w CGO_ENABLED=0

#go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
go env -w GOPROXY=https://goproxy.cn,direct

echo "创建 $PROJECT 应用";

echo "创建目录：$PROJECT";
mkdir "$PROJECT"
cd ./$PROJECT || exit

echo "初始化应用：$PROJECT";
go mod init $PROJECT
mkdir -p  docs cmd config  deployments internal test pkg/inits
mkdir -p  pkg/common/ pkg/common/crud pkg/crud/ pkg/controllers/ pkg/forms pkg/service pkg/repository
mkdir -p  pkg/routers pkg/helpers pkg/models pkg/routers  pkg/routers/middleware pkg/migrations
mkdir -p  internal/infra/database internal/infra/logger

echo "获取 $PROJECT 依赖:";
echo "--- github.com/githubnemo/CompileDaemon:";
go get github.com/githubnemo/CompileDaemon

go install github.com/githubnemo/CompileDaemon

echo "--- github.com/joho/godotenv:";
go get github.com/joho/godotenv

echo "--- github.com/sirupsen/logrus:";
go get -u github.com/sirupsen/logrus

echo "--- github.com/spf13/viper:";
go get -u github.com/spf13/viper

echo "--- github.com/gin-gonic/gin:";
go get -u github.com/gin-gonic/gin

echo "--- gorm.io/gorm:";
go get -u gorm.io/gorm

echo "--- gorm.io/driver/mysql:";
go get -u gorm.io/driver/mysql

echo "--- gorm.io/driver/postgres:";
go get gorm.io/driver/postgres
#go get gorm.io/driver/postgres

echo "--- gorm.io/plugin/dbresolver:";
go get  gorm.io/plugin/dbresolver
# go get gorm.io/plugin/dbresolver

echo "--- golang.org/x/crypto/bcrypt:";
go get -u golang.org/x/crypto/bcrypt

echo "--- github.com/golang-jwt/jwt/v5:";
go get -u github.com/golang-jwt/jwt/v5

echo "--- github.com/google/uuid:";
go get -u github.com/google/uuid

echo "--- github.com/redis/go-redis/v9:";
go get -u github.com/redis/go-redis/v9

echo "--- golang.org/x/mod/modfile:";
go get -u golang.org/x/mod/modfile

echo "--- github.com/go-playground/validator/v10:";
go get -u github.com/go-playground/validator/v10

echo "--- github.com/swaggo/swag:";
go get -u github.com/swaggo/swag


echo "---  BEGIN WRITE  PROJECT $PROJECT SOURCE CODE FILES :";

echo "--- WRITE  ./internal/infra/database/database.go SOURCE CODE FILE :";

cat << EOF > ./internal/infra/database/database.go
package database

import (
	_redis "github.com/redis/go-redis/v9"
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

var RedisClient *_redis.Client

// InitRedis ...
func InitRedis(selectDB ...int) {

	var redisHost = viper.GetString("REDIS_HOST")
	var redisPassword = viper.GetString("REDIS_PASSWORD")
	var redisDb = viper.GetInt("REDIS_DB")

	RedisClient = _redis.NewClient(&_redis.Options{
		Addr:     redisHost,
		Password: redisPassword,
		DB:       selectDB[redisDb],
		// DialTimeout:        10 * time.Second,
		// ReadTimeout:        30 * time.Second,
		// WriteTimeout:       30 * time.Second,
		// PoolSize:           10,
		// PoolTimeout:        30 * time.Second,
		// IdleTimeout:        500 * time.Millisecond,
		// IdleCheckFrequency: 500 * time.Millisecond,
		// TLSConfig: &tls.Config{
		// 	InsecureSkipVerify: true,
		// },
	})

}

// GetRedis ...
func GetRedis() *_redis.Client {
	return RedisClient
}

EOF

echo "------ ./internal/infra/database/database.go ------------";

echo "WRITE  ./internal/infra/logger SOURCE CODE FILE :";

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

echo "WRITE  ./.env  FILE :";

cat << EOF > ./.env

# Server Config

SECRET=h9wt*pasj6796j##w(w8=xaje8tpi6h*r&hzgrz065u&ed+k2)
DEBUG=False
ALLOWED_HOSTS=0.0.0.0
SERVER_HOST=0.0.0.0
SERVER_PORT=6060

#gorm:gorm@tcp(localhost:9910)/gorm?charset=utf8&parseTime=True&loc=Local
# Database Config  parseTime=True&loc=Local
DB_TYPE=MYSQL
MASTER_DB_NAME=mydemo
MASTER_DB_USER=root
MASTER_DB_PASSWORD=rootroot
MASTER_DB_HOST=192.168.108.180
MASTER_DB_PORT=3306
MASTER_DB_LOG_MODE=True
MASTER_DB_PARAM=charset=utf8&parseTime=True&loc=Local
MASTER_SSL_MODE=disable

REPLICA_DB_NAME=mydemo
REPLICA_DB_USER=root
REPLICA_DB_PASSWORD=rootroot
REPLICA_DB_HOST=192.168.108.180
REPLICA_DB_PORT=3306
REPLICA_DB_PARAM=charset=utf8&parseTime=True&loc=Local
REPLICA_SSL_MODE=disable

ACCESS_SECRET="ashasdjhjhjadhasdaa123"
REFERSH_SECRET="hjsajdhkjhf41jhagggdga"

REDIS_SECRET="hjfhjhasdfkyuy2"
REDIS_HOST=127.0.0.1:6379
REDIS_PASSWORD=

EOF
echo "-------./.env-----------";

echo "BEGIN *** ./config/ SOURCE CODE FILES :";

echo "WRITE  ./config/config.go SOURCE CODE FILE :";
cat << EOF > ./config/config.go
package config

import (
	"$PROJECT/internal/infra/logger"
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

echo "WRITE  ./config/db.go SOURCE CODE FILE :";

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
	masterDBParam := viper.GetString("MASTER_DB_PARAM")
	masterDBSslMode := viper.GetString("MASTER_SSL_MODE")

	replicaDBName := viper.GetString("REPLICA_DB_NAME")
	replicaDBUser := viper.GetString("REPLICA_DB_USER")
	replicaDBPassword := viper.GetString("REPLICA_DB_PASSWORD")
	replicaDBHost := viper.GetString("REPLICA_DB_HOST")
	replicaDBPort := viper.GetString("REPLICA_DB_PORT")
	replicaDBParam := viper.GetString("REPLICA_DB_PARAM")
	replicaDBSslMode := viper.GetString("REPLICA_SSL_MODE")

	var masterDBDSN, replicaDBDSN string

	dbType := viper.GetString("DB_TYPE")

	if dbType == "MYSQL" {
		masterDBDSN = fmt.Sprintf("%s:%s@(%s:%s)/%s?%s",
			masterDBUser,
			masterDBPassword,
			masterDBHost,
			masterDBPort,
			masterDBName,
			masterDBParam)
		replicaDBDSN = fmt.Sprintf("%s:%s@(%s:%s)/%s?%s",
			replicaDBUser,
			replicaDBPassword,
			replicaDBHost,
			replicaDBPort,
			replicaDBName,
			replicaDBParam)

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
echo "WRITE  ./config/server.go SOURCE CODE FILE :";

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

echo "END *** ./config/ SOURCE CODE FILES :";

echo "BEGIN *** ./internal/ SOURCE CODE FILES:";

echo "WRITE  ./internal/infra/database/database.go SOURCE CODE FILES :";

cat << EOF > ./internal/infra/database/database.go
package database

import (
	_redis "github.com/redis/go-redis/v9"
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

var RedisClient *_redis.Client

// InitRedis ...
func InitRedis(selectDB ...int) {

	var redisHost = viper.GetString("REDIS_HOST")
	var redisPassword = viper.GetString("REDIS_PASSWORD")
	var redisDb = viper.GetInt("REDIS_DB")

	RedisClient = _redis.NewClient(&_redis.Options{
		Addr:     redisHost,
		Password: redisPassword,
		DB:       selectDB[redisDb],
		// DialTimeout:        10 * time.Second,
		// ReadTimeout:        30 * time.Second,
		// WriteTimeout:       30 * time.Second,
		// PoolSize:           10,
		// PoolTimeout:        30 * time.Second,
		// IdleTimeout:        500 * time.Millisecond,
		// IdleCheckFrequency: 500 * time.Millisecond,
		// TLSConfig: &tls.Config{
		// 	InsecureSkipVerify: true,
		// },
	})

}

// GetRedis ...
func GetRedis() *_redis.Client {
	return RedisClient
}

EOF

echo "------ ./internal/infra/database/database.go ------------";

echo "WRITE  ./internal/infra/logger/logger.go SOURCE CODE FILE :";

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

echo "END *** ./internal/ SOURCE CODE FILE:";

echo "BEGIN *** ./pkg/ SOURCE CODE FILE:";


echo "WRITE ./pkg/common/env_keys.go:";

cat << EOF > ./pkg/common/env_keys.go
package common

const (
	KJwtSecret  string = "JWT_SECRET"
	KUserHeader string = "user_id"
	KAWSSession string = "aws_session"
)

EOF
echo "-------./pkg/common/env_keys -----------";

echo "BEGIN WRITE ./pkg/common/helper.go:";

cat << EOF > ./pkg/common/helper.go
package common

import (
	"golang.org/x/mod/modfile"
	"os"
	"reflect"
)

func Unique(intSlice []uint) []uint {
	keys := make(map[uint]bool)
	var list []uint
	for _, entry := range intSlice {
		if _, value := keys[entry]; !value {
			keys[entry] = true
			list = append(list, entry)
		}
	}
	return list
}

func GetIdFromCtx(id interface{}) uint {
	idFloat, _ := id.(float64)
	return uint(idFloat)
}

func Contains(val interface{}, slice interface{}) bool {
	found := false
	for _, v := range slice.([]uint) {
		if v == val {
			found = true
		}
	}
	return found
}
func StringsContains(val string, slice []string) bool {
	found := false
	for _, v := range slice {
		if v == val {
			found = true
		}
	}
	return found
}

func HashIntersection(a interface{}, b interface{}) []interface{} {
	set := make([]interface{}, 0)
	hash := make(map[interface{}]bool)
	av := reflect.ValueOf(a)
	bv := reflect.ValueOf(b)

	for i := 0; i < av.Len(); i++ {
		el := av.Index(i).Interface()
		hash[el] = true
	}

	for i := 0; i < bv.Len(); i++ {
		el := bv.Index(i).Interface()
		if _, found := hash[el]; found {
			set = append(set, el)
		}
	}

	return set
}

func removeDuplicateAdjacent(checkText string) string {
	newText := ""
	for i := range []rune(checkText) {
		if i+1 < len([]rune(checkText)) {
			if []rune(checkText)[i] != []rune(checkText)[i+1] {
				newText += string([]rune(checkText)[i])
			}

		} else {
			newText += string([]rune(checkText)[i])
		}

	}
	return newText
}

func GetModuleName() string {
	goModBytes, err := os.ReadFile("go.mod")
	if err != nil {
		panic(err)
	}

	modName := modfile.ModulePath(goModBytes)

	return modName
}

EOF
echo "------- END ./pkg/common/helper.go -----------";

echo "BEGIN WRITE ./pkg/common/modelStruct.go:";

cat << EOF > ./pkg/common/modelStruct.go
package common

type ById struct {
	ID string \`uri:"id" binding:"required"\`
}

EOF
echo "-------END ./pkg/common/modelStruct.go -----------";

echo "BEGIN WRITE ./pkg/common/crud/repository.go:";

cat << EOF > ./pkg/common/crud/repository.go
package crud

import (
	"gorm.io/gorm"
)

type Repo[T any] interface {
	FindOne(cond *T, dest *T) error
	Update(cond *T, updatedColumns *T) error
	Delete(cond *T) error
	Create(data *T) error
	getTx() *gorm.DB
}

type Repository[T any] struct {
	DB    *gorm.DB
	Model T
}

func (r *Repository[T]) FindOne(cond *T, dest *T) error {
	return r.DB.Where(cond).First(dest).Error
}

func (r *Repository[T]) Update(cond *T, updatedColumns *T) error {
	return r.DB.Model(r.Model).Select("*").Where(cond).Updates(updatedColumns).Error
}

func (r *Repository[T]) Delete(cond *T) error {
	if err := r.DB.Model(r.Model).Delete(cond); err != nil {
		return err.Error
	}
	return nil
}

func (r *Repository[T]) Create(data *T) error {
	return r.DB.Create(data).Error
}

func (r *Repository[T]) getTx() *gorm.DB {
	return r.DB.Model(r.Model)
}

func NewRepository[T any](db *gorm.DB, model T) Repo[T] {
	return &Repository[T]{
		DB:    db,
		Model: model,
	}
}

EOF
echo "-------END ./pkg/common/crud/repository.go -----------";

echo "BEGIN WRITE ./pkg/common/crud/service.go:";

cat << EOF > ./pkg/common/crud/service.go
package crud

import (
	"encoding/json"
	"gorm.io/gorm"
	"strings"
)

type Service[T any] struct {
	Repo Repo[T]
	Qtb  *QueryToDBConverter
}

func (svc *Service[T]) FindTrx(api GetAllRequest) (error, *gorm.DB) {
	var s map[string]interface{}
	if len(api.S) > 0 {
		err := json.Unmarshal([]byte(api.S), &s)
		if err != nil {
			return err, nil
		}
	}

	tx := svc.Repo.getTx()
	if len(api.Fields) > 0 {
		fields := strings.Split(api.Fields, ",")
		tx.Select(fields)
	}
	if len(api.Join) > 0 {
		svc.Qtb.relationsMapper(api.Join, tx)
	}

	if len(api.Filter) > 0 {
		svc.Qtb.filterMapper(api.Filter, tx)
	}

	if len(api.Sort) > 0 {
		svc.Qtb.sortMapper(api.Sort, tx)
	}

	err := svc.Qtb.searchMapper(s, tx)
	if err != nil {
		return err, nil
	}

	tx.Limit(api.Limit)

	return nil, tx
}

func (svc *Service[T]) Find(api GetAllRequest, result interface{}, totalRows *int64) error {
	err, tx := svc.FindTrx(api)
	tx.Count(totalRows)
	if api.Page > 0 {
		tx.Offset((api.Page - 1) * api.Limit)
	}
	if err != nil {
		return err
	}
	return tx.Find(result).Error
}

func (svc *Service[T]) FindOne(api GetAllRequest, result interface{}) error {
	var s map[string]interface{}
	if len(api.S) > 0 {
		err := json.Unmarshal([]byte(api.S), &s)
		if err != nil {
			return err
		}
	}

	tx := svc.Repo.getTx()

	if len(api.Fields) > 0 {
		fields := strings.Split(api.Fields, ",")
		tx.Select(fields)
	}
	if len(api.Join) > 0 {
		svc.Qtb.relationsMapper(api.Join, tx)
	}

	if len(api.Filter) > 0 {
		svc.Qtb.filterMapper(api.Filter, tx)
	}

	if len(api.Sort) > 0 {
		svc.Qtb.sortMapper(api.Sort, tx)
	}

	err := svc.Qtb.searchMapper(s, tx)
	if err != nil {
		return err
	}
	return tx.First(result).Error
}

func (svc *Service[T]) Create(data *T) error {
	return svc.Repo.Create(data)
}

func (svc *Service[T]) Delete(cond *T) error {
	return svc.Repo.Delete(cond)
}

func (svc *Service[T]) Update(cond *T, updatedColumns *T) error {
	return svc.Repo.Update(cond, updatedColumns)
}

func NewService[T any](repo Repo[T]) *Service[T] {
	return &Service[T]{
		Repo: repo,
		Qtb:  &QueryToDBConverter{},
	}
}

EOF
echo "-------END ./pkg/common/crud/service.go -----------";

echo "BEGIN WRITE ./pkg/common/crud/crudStruct.go:";

cat << EOF > ./pkg/common/crud/crudStruct.go
package crud

const (
	AND           = ""
	OR            = ""
	SEPARATOR     = "||"
	SortSeparator = ","
)

type GetAllRequest struct {
	Page   int
	Limit  int
	Join   string
	S      string
	Fields string
	Filter []string
	Sort   []string
}

var filterConditions = map[string]string{
	"eq":      "=",
	"ne":      "!=",
	"gt":      ">",
	"lt":      "<",
	"gte":     ">=",
	"lte":     "<=",
	"":        "in",
	"cont":    "ILIKE",
	"isnull":  "IS NULL",
	"notnull": "IS NOT NULL",
}

type ById struct {
	ID string \`uri:"id" binding:"required"\`
}

EOF
echo "-------END ./pkg/common/crud/crudStruct.go -----------";

echo "BEGIN WRITE ./pkg/crud/utils.go:";

cat << EOF > ./pkg/common/crud/utils.go
package crud

import (
	"errors"
	"fmt"
	"golang.org/x/text/cases"
	"golang.org/x/text/language"
	"strings"

	"gorm.io/gorm"
)

const (
	ContainOperator = "cont"
	NotNullOperator = "notnull"
	IsNullOperator  = "isnull"
	InOperator      = "\$in"
)

var AndValueNotSlice = errors.New("the value of \$and or \$or not array")

type QueryToDBConverter struct {
}

func (q *QueryToDBConverter) searchMapper(s map[string]interface{}, tx *gorm.DB) error {
	for k := range s {
		if k == AND {
			vals, ok := s[k].([]interface{})
			if !ok {
				return AndValueNotSlice
			}
			for _, field := range vals {
				keyAndVal, ok := field.(map[string]interface{})
				if ok {
					for whereField, whereVal := range keyAndVal {
						whereValMap, ok := whereVal.(map[string]interface{})
						if ok {
							for operatorKey, value := range whereValMap {
								operator, ok := filterConditions[operatorKey]
								if ok {
									if operatorKey == NotNullOperator || operatorKey == IsNullOperator {
										tx.Where(fmt.Sprintf("%s %s", whereField, operator))
									} else if operatorKey == InOperator {
										valSlice := strings.Split(value.(string), ",")
										tx.Where(fmt.Sprintf("%s IN ?", whereField), valSlice)
									} else {

										if operatorKey == ContainOperator {
											value = fmt.Sprintf("%%%s%%", value)
										}
										tx.Where(fmt.Sprintf("%s %s ?", whereField, operator), value)
									}
								}
							}

						} else {

							tx.Where(whereField, whereVal)
						}
					}
				}
			}
		} else if k == OR {
			vals, ok := s[k].([]interface{})
			if !ok {
				return AndValueNotSlice
			}
			for i, field := range vals {
				keyAndVal, ok := field.(map[string]interface{})
				if ok {
					for whereField, whereVal := range keyAndVal {
						whereValMap, ok := whereVal.(map[string]interface{})
						if ok {
							for operatorKey, value := range whereValMap {
								operator, ok := filterConditions[operatorKey]
								if ok {
									if operatorKey == NotNullOperator || operatorKey == IsNullOperator {
										if i == 0 {
											tx.Where(fmt.Sprintf("%s %s", whereField, operator))
										} else {
											tx.Or(fmt.Sprintf("%s %s", whereField, operator))
										}
									} else if operatorKey == InOperator {
										if i == 0 {
											valSlice := strings.Split(value.(string), ",")
											tx.Where(fmt.Sprintf("%s IN ?", whereField), valSlice)
										} else {
											valSlice := strings.Split(value.(string), ",")
											tx.Or(fmt.Sprintf("%s IN ?", whereField), valSlice)
										}
									} else {
										if operatorKey == ContainOperator {
											value = fmt.Sprintf("%%%s%%", value)
										}
										if i == 0 {
											tx.Where(fmt.Sprintf("%s %s ?", whereField, operator), value)
										} else {
											tx.Or(fmt.Sprintf("%s %s ?", whereField, operator), value)
										}
									}
								}
							}

						} else {
							if i == 0 {
								tx.Where(whereField, whereVal)
							} else {
								tx.Or(whereField, whereVal)
							}
						}
					}
				}
			}

		}

	}
	return nil
}

func (q *QueryToDBConverter) relationsMapper(joinString string, tx *gorm.DB) {
	relations := strings.Split(joinString, ",")
	for _, relation := range relations {
		nestedRelationsSlice := strings.Split(relation, ".")
		titledSlice := make([]string, len(nestedRelationsSlice))
		for i, relation := range nestedRelationsSlice {
			titledSlice[i] = cases.Title(language.English, cases.NoLower).String(relation)
		}
		nestedRelation := strings.Join(titledSlice, ".")
		if len(nestedRelation) > 0 {
			tx.Preload(nestedRelation)
		}
	}
}

func (q *QueryToDBConverter) filterMapper(filters []string, tx *gorm.DB) {
	for _, filter := range filters {
		filterParams := strings.Split(filter, SEPARATOR)
		if len(filterParams) >= 2 {
			operator, ok := filterConditions[filterParams[1]]
			if ok {
				if filterParams[1] == NotNullOperator || filterParams[1] == IsNullOperator {
					tx.Where(fmt.Sprintf("%s %s", filterParams[0], operator))
				} else {
					if len(filterParams) == 3 {

						if filterParams[1] == ContainOperator {
							tx.Where(fmt.Sprintf("%s %s ?", filterParams[0], operator), fmt.Sprintf("%%%s%%", filterParams[2]))
						} else if filterParams[1] == InOperator {
							valSlice := strings.Split(filterParams[2], ",")
							tx.Where(fmt.Sprintf("%s IN ?", filterParams[0]), valSlice)
						} else {
							tx.Where(fmt.Sprintf("%s %s ?", filterParams[0], operator), filterParams[2])

						}
					}
				}
			}
		}
	}
}

func (q *QueryToDBConverter) sortMapper(sorts []string, tx *gorm.DB) {
	for _, sort := range sorts {
		sortParams := strings.Split(sort, SortSeparator)
		if len(sortParams) == 2 {
			tx.Order(fmt.Sprintf("%s %s", sortParams[0], strings.ToLower(sortParams[1])))
		} else {
			tx.Order(fmt.Sprintf("%s desc", sortParams[0]))
		}
	}
}

EOF
echo "-------END ./pkg/common/crud/utils.go -----------";

echo "WRITE  ./pkg/forms/validator.go.go SOURCE CODE FILE :";

cat << EOF > ./pkg/forms/validator.go
package forms

import (
	"reflect"
	"regexp"
	"strings"
	"sync"

	"github.com/gin-gonic/gin/binding"
	"github.com/go-playground/validator/v10"
)

//DefaultValidator ...
type DefaultValidator struct {
	once     sync.Once
	validate *validator.Validate
}

var _ binding.StructValidator = &DefaultValidator{}

//ValidateStruct ...
func (v *DefaultValidator) ValidateStruct(obj interface{}) error {

	if kindOfData(obj) == reflect.Struct {

		v.lazyinit()

		if err := v.validate.Struct(obj); err != nil {
			return err
		}
	}

	return nil
}

//Engine ...
func (v *DefaultValidator) Engine() interface{} {
	v.lazyinit()
	return v.validate
}

func (v *DefaultValidator) lazyinit() {
	v.once.Do(func() {

		v.validate = validator.New()
		v.validate.SetTagName("binding")

		// add any custom validations etc. here

		//Custom rule for user full name
		v.validate.RegisterValidation("fullName", ValidateFullName)
	})
}

func kindOfData(data interface{}) reflect.Kind {

	value := reflect.ValueOf(data)
	valueType := value.Kind()

	if valueType == reflect.Ptr {
		valueType = value.Elem().Kind()
	}
	return valueType
}

//ValidateFullName implements validator.Func
func ValidateFullName(fl validator.FieldLevel) bool {
	//Remove the extra space
	space := regexp.MustCompile(\`\s+\`)
	name := space.ReplaceAllString(fl.Field().String(), " ")

	//Remove trailing spaces
	name = strings.TrimSpace(name)

	//To support all possible languages
	matched, _ := regexp.Match(\`^[^±!@£$%^&*_+§¡€#¢§¶•ªº«\\/<>?:;'"|=.,0123456789]{3,20}$\`, []byte(name))
	return matched
}

EOF

echo "------ ./pkg/forms/validator.go ------------";

echo "WRITE  ./pkg/forms/auth.go SOURCE CODE FILE :";

cat << EOF > ./pkg/forms/auth.go
package forms

//Token ...
type Token struct {
	RefreshToken string \`form:"refresh_token" json:"refresh_token" binding:"required"\`
}
EOF

echo "------ ./pkg/forms/auth.go ------------";

echo "WRITE  ./pkg/forms/user.go SOURCE CODE FILE :";

cat << EOF > ./pkg/forms/user.go
package forms

import (
	"encoding/json"
	"errors"
	"github.com/go-playground/validator/v10"
)


//UserForm ...
type UserForm struct{}

//LoginForm ...
type LoginForm struct {
	Email    string \`form:"email" json:"email" binding:"required,email"\`
	Password string \`form:"password" json:"password" binding:"required,min=3,max=50"\`
}

//RegisterForm ...
type RegisterForm struct {
	Name     string \`form:"name" json:"name" binding:"required,min=3,max=20,fullName"\` //fullName rule is in validator.go
	Email    string \`form:"email" json:"email" binding:"required,email"\`
	Password string \`form:"password" json:"password" binding:"required,min=3,max=50"\`
}

//Name ...
func (f UserForm) Name(tag string, errMsg ...string) (message string) {
	switch tag {
	case "required":
		if len(errMsg) == 0 {
			return "Please enter your name"
		}
		return errMsg[0]
	case "min", "max":
		return "Your name should be between 3 to 20 characters"
	case "fullName":
		return "Name should not include any special characters or numbers"
	default:
		return "Something went wrong, please try again later"
	}
}

//Email ...
func (f UserForm) Email(tag string, errMsg ...string) (message string) {
	switch tag {
	case "required":
		if len(errMsg) == 0 {
			return "Please enter your email"
		}
		return errMsg[0]
	case "min", "max", "email":
		return "Please enter a valid email"
	default:
		return "Something went wrong, please try again later"
	}
}

//Password ...
func (f UserForm) Password(tag string) (message string) {
	switch tag {
	case "required":
		return "Please enter your password"
	case "min", "max":
		return "Your password should be between 3 and 50 characters"
	case "eqfield":
		return "Your passwords does not match"
	default:
		return "Something went wrong, please try again later"
	}
}

//Signin ...
func (f UserForm) Login(err error) string {
	var validationErrors validator.ValidationErrors
	switch {
	case errors.As(err, &validationErrors):

		var unmarshalTypeError *json.UnmarshalTypeError
		if errors.As(err, &unmarshalTypeError) {
			return "Something went wrong, please try again later"
		}

		for _, err := range err.(validator.ValidationErrors) {
			if err.Field() == "Email" {
				return f.Email(err.Tag())
			}
			if err.Field() == "Password" {
				return f.Password(err.Tag())
			}
		}
	default:
		return "Invalid request"
	}

	return "Something went wrong, please try again later"
}

//Register ...
func (f UserForm) Register(err error) string {
	switch err.(type) {
	case validator.ValidationErrors:

		if _, ok := err.(*json.UnmarshalTypeError); ok {
			return "Something went wrong, please try again later"
		}

		for _, err := range err.(validator.ValidationErrors) {
			if err.Field() == "Name" {
				return f.Name(err.Tag())
			}

			if err.Field() == "Email" {
				return f.Email(err.Tag())
			}

			if err.Field() == "Password" {
				return f.Password(err.Tag())
			}

		}
	default:
		return "Invalid request"
	}

	return "Something went wrong, please try again later"
}

EOF

echo "------ ./pkg/forms/user.go ------------";

echo "WRITE  ./pkg/forms/article.go SOURCE CODE FILE :";

cat << EOF > ./pkg/forms/article.go
package forms

import (
	"encoding/json"
	"errors"

	"github.com/go-playground/validator/v10"
)

//ArticleForm ...
type ArticleForm struct{}

//CreateArticleForm ...
type CreateArticleForm struct {
	Title   string \`form:"title" json:"title" binding:"required,min=3,max=100"\`
	Content string \`form:"content" json:"content" binding:"required,min=3,max=1000"\`
}

//Title ...
func (f ArticleForm) Title(tag string, errMsg ...string) (message string) {
	switch tag {
	case "required":
		if len(errMsg) == 0 {
			return "Please enter the article title"
		}
		return errMsg[0]
	case "min", "max":
		return "Title should be between 3 to 100 characters"
	default:
		return "Something went wrong, please try again later"
	}
}

//Content ...
func (f ArticleForm) Content(tag string, errMsg ...string) (message string) {
	switch tag {
	case "required":
		if len(errMsg) == 0 {
			return "Please enter the article content"
		}
		return errMsg[0]
	case "min", "max":
		return "Content should be between 3 to 1000 characters"
	default:
		return "Something went wrong, please try again later"
	}
}

//Create ...
func (f ArticleForm) Create(err error) string {
	var validationErrors validator.ValidationErrors
	switch {
	case errors.As(err, &validationErrors):

		var unmarshalTypeError *json.UnmarshalTypeError
		if errors.As(err, &unmarshalTypeError) {
			return "Something went wrong, please try again later"
		}

		for _, err := range err.(validator.ValidationErrors) {
			if err.Field() == "Title" {
				return f.Title(err.Tag())
			}
			if err.Field() == "Content" {
				return f.Content(err.Tag())
			}
		}
	default:
		return "Invalid request"
	}

	return "Something went wrong, please try again later"
}

//Update ...
func (f ArticleForm) Update(err error) string {
	switch err.(type) {
	case validator.ValidationErrors:

		if _, ok := err.(*json.UnmarshalTypeError); ok {
			return "Something went wrong, please try again later"
		}

		for _, err := range err.(validator.ValidationErrors) {
			if err.Field() == "Title" {
				return f.Title(err.Tag())
			}
			if err.Field() == "Content" {
				return f.Content(err.Tag())
			}
		}

	default:
		return "Invalid request"
	}

	return "Something went wrong, please try again later"
}

EOF

echo "------ ./pkg/forms/article.go ------------";


echo "WRITE  ./pkg/controllers/authController.go SOURCE CODE FILE :";

cat << EOF > ./pkg/controllers/authController.go
package controllers

import (
	"fmt"
	"github.com/gin-gonic/gin"
	jwt "github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"$PROJECT/pkg/forms"
	"$PROJECT/pkg/models"
	"net/http"
	"os"
)

// AuthController ...
type AuthController struct{}

var authModel = new(models.AuthModel)

// TokenValid ...
func (ctl AuthController) TokenValid(c *gin.Context) {

	tokenAuth, err := authModel.ExtractTokenMetadata(c.Request)
	if err != nil {
		//Token either expired or not valid
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"message": "Please login first"})
		return
	}

	userID, err := authModel.FetchAuth(tokenAuth)
	if err != nil {
		//Token does not exists in Redis (User logged out or expired)
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"message": "Please login first"})
		return
	}

	//To be called from GetUserID()
	c.Set("userID", userID)
}

// Refresh ...
func (ctl AuthController) Refresh(c *gin.Context) {
	var tokenForm forms.Token

	if c.ShouldBindJSON(&tokenForm) != nil {
		c.JSON(http.StatusNotAcceptable, gin.H{"message": "Invalid form", "form": tokenForm})
		c.Abort()
		return
	}

	//verify the token
	token, err := jwt.Parse(tokenForm.RefreshToken, func(token *jwt.Token) (interface{}, error) {
		//Make sure that the token method conform to "SigningMethodHMAC"
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(os.Getenv("REFRESH_SECRET")), nil
	})
	//if there is an error, the token must have expired
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Invalid authorization, please login again"})
		return
	}
	//is token valid?
	if _, ok := token.Claims.(jwt.Claims); !ok && !token.Valid {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Invalid authorization, please login again"})
		return
	}
	//Since token is valid, get the uuid:
	claims, ok := token.Claims.(jwt.MapClaims) //the token claims should conform to MapClaims
	if ok && token.Valid {
		refreshUUID, ok := claims["refresh_uuid"].(string) //convert the interface to string
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"message": "Invalid authorization, please login again"})
			return
		}
		//userID, err := strconv.ParseInt(fmt.Sprintf("%.f", claims["user_id"]), 10, 64)
		userID, err := uuid.Parse(fmt.Sprintf("%.f", claims["user_id"]))
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"message": "Invalid authorization, please login again"})
			return
		}
		//Delete the previous Refresh Token
		deleted, delErr := authModel.DeleteAuth(refreshUUID)
		if delErr != nil || deleted == 0 { //if any goes wrong
			c.JSON(http.StatusUnauthorized, gin.H{"message": "Invalid authorization, please login again"})
			return
		}

		//Create new pairs of refresh and access tokens
		ts, createErr := authModel.CreateToken(userID)
		if createErr != nil {
			c.JSON(http.StatusForbidden, gin.H{"message": "Invalid authorization, please login again"})
			return
		}
		//save the tokens metadata to redis
		saveErr := authModel.CreateAuth(userID, ts)
		if saveErr != nil {
			c.JSON(http.StatusForbidden, gin.H{"message": "Invalid authorization, please login again"})
			return
		}
		tokens := map[string]string{
			"access_token":  ts.AccessToken,
			"refresh_token": ts.RefreshToken,
		}
		c.JSON(http.StatusOK, tokens)
	} else {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Invalid authorization, please login again"})
	}
}

EOF

echo "------ ./pkg/controllers/authController.go ------------";

echo "WRITE  ./pkg/controllers/userController.go SOURCE CODE FILE :";

cat << EOF > ./pkg/controllers/userController.go
package controllers

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"$PROJECT/pkg/forms"
	"$PROJECT/pkg/models"
	"$PROJECT/pkg/repository"
	"$PROJECT/pkg/service"
	"net/http"
)

func (ctrl UserController) UserGetData(ctx *gin.Context) {
	var user []*models.User
	repository.Get(&user)
	ctx.JSON(http.StatusOK, &user)

}
func (ctrl UserController) UserCreate(c *gin.Context) {
	var loginForm forms.LoginForm

	if validationErr := c.ShouldBindJSON(&loginForm); validationErr != nil {
		message := userForm.Login(validationErr)
		c.AbortWithStatusJSON(http.StatusNotAcceptable, gin.H{"message": message})
		return
	}

	user := new(models.User)
	user.ID = uuid.New()
	user.Password = loginForm.Password
	user.Email = loginForm.Email
	user.Name = loginForm.Email

	repository.Save(&user)
	c.JSON(http.StatusOK, &user)
}

// UserController ...
type UserController struct {
	service *service.UserService
}

// var userModel = new(models.UserModel)
var userForm = new(forms.UserForm)

// getUserID ...
func (ctrl UserController) getUserID(c *gin.Context) (userID int64) {
	//MustGet returns the value for the given key if it exists, otherwise it panics.
	return c.MustGet("userID").(int64)
}

// Login ...
func (ctrl UserController) Login(c *gin.Context) {
	var loginForm forms.LoginForm

	if validationErr := c.ShouldBindJSON(&loginForm); validationErr != nil {
		message := userForm.Login(validationErr)
		c.AbortWithStatusJSON(http.StatusNotAcceptable, gin.H{"message": message})
		return
	}

	user, token, err := ctrl.service.Login(loginForm)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusNotAcceptable, gin.H{"message": "Invalid login details"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Successfully logged in", "user": user, "token": token})
}

// Register ...
func (ctrl UserController) Register(c *gin.Context) {
	var registerForm forms.RegisterForm

	if validationErr := c.ShouldBindJSON(&registerForm); validationErr != nil {
		message := userForm.Register(validationErr)
		c.AbortWithStatusJSON(http.StatusNotAcceptable, gin.H{"message": message})
		return
	}

	user, err := ctrl.service.Register(registerForm)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusNotAcceptable, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Successfully registered", "user": user})
}

// Logout ...
func (ctrl UserController) Logout(c *gin.Context) {

	au, err := authModel.ExtractTokenMetadata(c.Request)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"message": "User not logged in"})
		return
	}

	deleted, delErr := authModel.DeleteAuth(au.AccessUUID)
	if delErr != nil || deleted == 0 { //if any goes wrong
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"message": "Invalid request"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Successfully logged out"})
}

func NewUserController(service *service.UserService) *UserController {
	return &UserController{
		service: service,
	}
}

EOF

echo "------ ./pkg/controllers/userController.go ------------";

echo "BEGIN WRITE ./pkg/controllers/postController.go:";

cat << EOF > ./pkg/controllers/postController.go
package controllers

import (
	"fmt"
	"math"
	"$PROJECT/pkg/common/crud"
	"$PROJECT/pkg/repository"
	"$PROJECT/pkg/service"
	"$PROJECT/pkg/common"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type PostController struct {
	service *service.PostService
}

// @Success  200  {array}  model
// @Tags     posts
// @param    s       query  string    false  "{'\$and': [ {'title': { '\$cont':'cul' } } ]}"
// @param    fields  query  string    false  "fields to select eg: name,age"
// @param    page    query  int       false  "page of pagination"
// @param    limit   query  int       false  "limit of pagination"
// @param    join    query  string    false  "join relations eg: category, parent"
// @param    filter  query  []string  false  "filters eg: name||\$eq||ad price||\$gte||200"
// @param    sort    query  []string  false  "filters eg: created_at,desc title,asc"
// @Router   /posts [get]
func (c *PostController) FindAll(ctx *gin.Context) {
	var api crud.GetAllRequest
	if api.Limit == 0 {
		api.Limit = 20
	}
	if err := ctx.ShouldBindQuery(&api); err != nil {
		ctx.JSON(400, gin.H{"message": err.Error()})
		return
	}

	var result []repository.PostMo
	var totalRows int64
	api.Join = api.Join + ",category"
	err := c.service.Find(api, &result, &totalRows)
	if err != nil {
		ctx.JSON(400, gin.H{"message": err.Error()})
		return
	}

	var data interface{}
	if api.Page > 0 {
		data = map[string]interface{}{
			"data":       result,
			"total":      totalRows,
			"totalPages": int(math.Ceil(float64(totalRows) / float64(api.Limit))),
		}
	} else {
		data = result
	}
	ctx.JSON(200, data)
}

// @Success  200  {object}  model
// @Tags     posts
// @param    id    path  string  true  "uuid of item"
// @Router   /posts/{id} [get]
func (c *PostController) FindOne(ctx *gin.Context) {
	var api crud.GetAllRequest
	var item common.ById
	if err := ctx.ShouldBindQuery(&api); err != nil {
		ctx.JSON(400, gin.H{"message": err.Error()})
		return
	}
	if err := ctx.ShouldBindUri(&item); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}

	api.Filter = append(api.Filter, fmt.Sprintf("id||eq||%s", item.ID))

	var result repository.PostMo

	err := c.service.FindOne(api, &result)
	if err != nil {
		ctx.JSON(400, gin.H{"message": err.Error()})
		return
	}
	ctx.JSON(200, result)
}

// @Success  201  {object}  model
// @Tags     posts
// @param    {object}  body  model  true  "item to create"
// @Router   /posts [post]
func (c *PostController) Create(ctx *gin.Context) {
	var item repository.PostMo
	if err := ctx.ShouldBind(&item); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}
	item.ID = uuid.New()
	err := c.service.Create(&item)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"message": err.Error()})
		return
	}
	ctx.JSON(http.StatusCreated, gin.H{"data": item})
}

// @Success  200  {string}  string  "ok"
// @Tags     posts
// @param    id  path  string  true  "uuid of item"
// @Router   /posts/{id} [delete]
func (c *PostController) Delete(ctx *gin.Context) {
	var item common.ById
	if err := ctx.ShouldBindUri(&item); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}

	id, err := uuid.ParseBytes([]byte(item.ID))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}

	err = c.service.Delete(&repository.PostMo{ID: id})
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"message": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"message": "deleted"})
}

// @Success  200  {string}  string  "ok"
// @Tags     posts
// @param    id  path  string  true  "uuid of item"
// @param    item  body  model   true  "update body"
// @Router   /posts/{id} [put]
func (c *PostController) Update(ctx *gin.Context) {
	var item repository.PostMo
	var byId common.ById
	if err := ctx.ShouldBind(&item); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}
	if err := ctx.ShouldBindUri(&byId); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}
	id, err := uuid.Parse(byId.ID)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}
	if err := ctx.ShouldBindUri(&byId); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}
	err = c.service.Update(&repository.PostMo{ID: id}, &item)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"message": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, item)
}

func NewPostController(service *service.PostService) *PostController {
	return &PostController{
		service: service,
	}
}

EOF
echo "-------END ./pkg/controllers/postController.go -----------";

echo "WRITE  ./pkg/helpers/helpers.go SOURCE CODE FILE :";

cat << EOF > ./pkg/helpers/helpers.go
package helpers

type Response struct {
	Code    int
	Message string
	Data    interface{}
}

EOF

echo "------ ./pkg/helpers/helpers.go ------------";

echo "WRITE  ./pkg/helpers/search.go SOURCE CODE FILE :";

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

echo "WRITE  ./pkg/helpers/auth.go SOURCE CODE FILE :";

cat << EOF > ./pkg/helpers/auth.go
package helpers

import (
	"context"
	"fmt"
	jwt "github.com/golang-jwt/jwt/v5"
	uuid "github.com/google/uuid"
	"$PROJECT/internal/infra/database"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

// TokenDetails ...
type TokenDetails struct {
	AccessToken  string
	RefreshToken string
	AccessUUID   string
	RefreshUUID  string
	AtExpires    int64
	RtExpires    int64
}

// AccessDetails ...
type AccessDetails struct {
	AccessUUID string
	UserID     int64
}

// Token ...
type Token struct {
	AccessToken  string \`json:"access_token"\`
	RefreshToken string \`json:"refresh_token"\`
}

// AuthModel ...
type AuthModel struct{}

var ctx = context.Background()

// CreateToken ...
func (m AuthModel) CreateToken(userID int64) (*TokenDetails, error) {

	td := &TokenDetails{}
	td.AtExpires = time.Now().Add(time.Minute * 15).Unix()
	td.AccessUUID = uuid.New().String()

	td.RtExpires = time.Now().Add(time.Hour * 24 * 7).Unix()
	td.RefreshUUID = uuid.New().String()

	var err error
	//Creating Access Token
	atClaims := jwt.MapClaims{}
	atClaims["authorized"] = true
	atClaims["access_uuid"] = td.AccessUUID
	atClaims["user_id"] = userID
	atClaims["exp"] = td.AtExpires

	at := jwt.NewWithClaims(jwt.SigningMethodHS256, atClaims)
	td.AccessToken, err = at.SignedString([]byte(os.Getenv("ACCESS_SECRET")))
	if err != nil {
		return nil, err
	}
	//Creating Refresh Token
	rtClaims := jwt.MapClaims{}
	rtClaims["refresh_uuid"] = td.RefreshUUID
	rtClaims["user_id"] = userID
	rtClaims["exp"] = td.RtExpires
	rt := jwt.NewWithClaims(jwt.SigningMethodHS256, rtClaims)
	td.RefreshToken, err = rt.SignedString([]byte(os.Getenv("REFRESH_SECRET")))
	if err != nil {
		return nil, err
	}
	return td, nil
}

// CreateAuth ...
func (m AuthModel) CreateAuth(userid int64, td *TokenDetails) error {
	at := time.Unix(td.AtExpires, 0) //converting Unix to UTC(to Time object)
	rt := time.Unix(td.RtExpires, 0)
	now := time.Now()

	errAccess := database.GetRedis().Set(ctx, td.AccessUUID, strconv.Itoa(int(userid)), at.Sub(now)).Err()
	if errAccess != nil {
		return errAccess
	}
	errRefresh := database.GetRedis().Set(ctx, td.RefreshUUID, strconv.Itoa(int(userid)), rt.Sub(now)).Err()
	if errRefresh != nil {
		return errRefresh
	}
	return nil
}

// ExtractToken ...
func (m AuthModel) ExtractToken(r *http.Request) string {
	bearToken := r.Header.Get("Authorization")
	//normally Authorization the_token_xxx
	strArr := strings.Split(bearToken, " ")
	if len(strArr) == 2 {
		return strArr[1]
	}
	return ""
}

// VerifyToken ...
func (m AuthModel) VerifyToken(r *http.Request) (*jwt.Token, error) {
	tokenString := m.ExtractToken(r)
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		//Make sure that the token method conform to "SigningMethodHMAC"
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(os.Getenv("ACCESS_SECRET")), nil
	})
	if err != nil {
		return nil, err
	}
	return token, nil
}

// TokenValid ...
func (m AuthModel) TokenValid(r *http.Request) error {
	token, err := m.VerifyToken(r)
	if err != nil {
		return err
	}
	if _, ok := token.Claims.(jwt.Claims); !ok && !token.Valid {
		return err
	}
	return nil
}

// ExtractTokenMetadata ...
func (m AuthModel) ExtractTokenMetadata(r *http.Request) (*AccessDetails, error) {
	token, err := m.VerifyToken(r)
	if err != nil {
		return nil, err
	}
	claims, ok := token.Claims.(jwt.MapClaims)
	if ok && token.Valid {
		accessUUID, ok := claims["access_uuid"].(string)
		if !ok {
			return nil, err
		}
		userID, err := strconv.ParseInt(fmt.Sprintf("%.f", claims["user_id"]), 10, 64)
		if err != nil {
			return nil, err
		}
		return &AccessDetails{
			AccessUUID: accessUUID,
			UserID:     userID,
		}, nil
	}
	return nil, err
}

// FetchAuth ...
func (m AuthModel) FetchAuth(authD *AccessDetails) (int64, error) {
	userid, err := database.GetRedis().Get(ctx, authD.AccessUUID).Result()
	if err != nil {
		return 0, err
	}
	userID, _ := strconv.ParseInt(userid, 10, 64)
	return userID, nil
}

// DeleteAuth ...
func (m AuthModel) DeleteAuth(givenUUID string) (int64, error) {
	deleted, err := database.GetRedis().Del(ctx, givenUUID).Result()
	if err != nil {
		return 0, err
	}
	return deleted, nil
}

EOF

echo "------ ./pkg/helpers/auth.go ------------";

echo "WRITE  ./pkg/models/authModel.go SOURCE CODE FILE:";

cat << EOF > ./pkg/models/authModel.go
package models

import (
	"context"
	"fmt"
	jwt "github.com/golang-jwt/jwt/v5"
	uuid "github.com/google/uuid"
	"github.com/spf13/viper"
	"$PROJECT/internal/infra/database"
	"net/http"
	"strconv"
	"strings"
	"time"
)

// TokenDetails ...
type TokenDetails struct {
	AccessToken  string
	RefreshToken string
	AccessUUID   string
	RefreshUUID  string
	AtExpires    int64
	RtExpires    int64
}

// AccessDetails ...
type AccessDetails struct {
	AccessUUID string
	UserID     int64
}

// Token ...
type Token struct {
	AccessToken  string \`json:"access_token"\`
	RefreshToken string \`json:"refresh_token"\`
}

// AuthModel ...
type AuthModel struct{}

var ctx = context.Background()

// CreateToken ...
func (m AuthModel) CreateToken(userID uuid.UUID) (*TokenDetails, error) {

	td := &TokenDetails{}
	td.AtExpires = time.Now().Add(time.Minute * 15).Unix()
	td.AccessUUID = uuid.New().String()

	td.RtExpires = time.Now().Add(time.Hour * 24 * 7).Unix()
	td.RefreshUUID = uuid.New().String()

	var err error
	//Creating Access Token
	atClaims := jwt.MapClaims{}
	atClaims["authorized"] = true
	atClaims["access_uuid"] = td.AccessUUID
	atClaims["user_id"] = userID
	atClaims["exp"] = td.AtExpires

	at := jwt.NewWithClaims(jwt.SigningMethodHS256, atClaims)
	td.AccessToken, err = at.SignedString([]byte(viper.GetString("ACCESS_SECRET")))
	if err != nil {
		return nil, err
	}
	//Creating Refresh Token
	rtClaims := jwt.MapClaims{}
	rtClaims["refresh_uuid"] = td.RefreshUUID
	rtClaims["user_id"] = userID
	rtClaims["exp"] = td.RtExpires
	rt := jwt.NewWithClaims(jwt.SigningMethodHS256, rtClaims)
	td.RefreshToken, err = rt.SignedString([]byte(viper.GetString("REFRESH_SECRET")))
	if err != nil {
		return nil, err
	}
	return td, nil
}

// CreateAuth ...
func (m AuthModel) CreateAuth(userid uuid.UUID, td *TokenDetails) error {
	at := time.Unix(td.AtExpires, 0) //converting Unix to UTC(to Time object)
	rt := time.Unix(td.RtExpires, 0)
	now := time.Now()

	errAccess := database.GetRedis().Set(ctx, td.AccessUUID, userid, at.Sub(now)).Err()
	if errAccess != nil {
		return errAccess
	}
	errRefresh := database.GetRedis().Set(ctx, td.RefreshUUID, userid, rt.Sub(now)).Err()
	if errRefresh != nil {
		return errRefresh
	}
	return nil
}

// ExtractToken ...
func (m AuthModel) ExtractToken(r *http.Request) string {
	bearToken := r.Header.Get("Authorization")
	//normally Authorization the_token_xxx
	strArr := strings.Split(bearToken, " ")
	if len(strArr) == 2 {
		return strArr[1]
	}
	return ""
}

// VerifyToken ...
func (m AuthModel) VerifyToken(r *http.Request) (*jwt.Token, error) {
	tokenString := m.ExtractToken(r)
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		//Make sure that the token method conform to "SigningMethodHMAC"
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(viper.GetString("ACCESS_SECRET")), nil
	})
	if err != nil {
		return nil, err
	}
	return token, nil
}

// TokenValid ...
func (m AuthModel) TokenValid(r *http.Request) error {
	token, err := m.VerifyToken(r)
	if err != nil {
		return err
	}
	if _, ok := token.Claims.(jwt.Claims); !ok && !token.Valid {
		return err
	}
	return nil
}

// ExtractTokenMetadata ...
func (m AuthModel) ExtractTokenMetadata(r *http.Request) (*AccessDetails, error) {
	token, err := m.VerifyToken(r)
	if err != nil {
		return nil, err
	}
	claims, ok := token.Claims.(jwt.MapClaims)
	if ok && token.Valid {
		accessUUID, ok := claims["access_uuid"].(string)
		if !ok {
			return nil, err
		}
		userID, err := strconv.ParseInt(fmt.Sprintf("%.f", claims["user_id"]), 10, 64)
		if err != nil {
			return nil, err
		}
		return &AccessDetails{
			AccessUUID: accessUUID,
			UserID:     userID,
		}, nil
	}
	return nil, err
}

// FetchAuth ...
func (m AuthModel) FetchAuth(authD *AccessDetails) (uuid.UUID, error) {
	userid, err := database.GetRedis().Get(ctx, authD.AccessUUID).Result()
	if err != nil {
		return uuid.UUID{}, err
	}
	//userID, _ := strconv.ParseInt(userid, 10, 64)
	userID, _ := uuid.Parse(userid)
	return userID, nil
}

// DeleteAuth ...
func (m AuthModel) DeleteAuth(givenUUID string) (int64, error) {
	deleted, err := database.GetRedis().Del(ctx, givenUUID).Result()
	if err != nil {
		return 0, err
	}
	return deleted, nil
}



EOF

echo "------ pkg/models/authModel.go ------------";


echo "BEGIN write  ./pkg/models/userModel.go SOURCE CODE FILE :";

cat << EOF > ./pkg/models/userModel.go
package models

import (
	"github.com/google/uuid"
	"time"
)

type User struct {
	ID        uuid.UUID  \`json:"id,omitempty" gorm:"type:char(128);primaryKey"\`
	Name      string     \`json:"name" binding:"required"\`
	Password  string     \`json:"password" binding:"required"\`
	Email     string     \`json:"email" binding:"required"\`
	Data      string     \`json:"data" binding:"required"\`
	CreatedAt *time.Time \`json:"created_at,string,omitempty"\`
	UpdatedAt *time.Time \`json:"updated_at_at,string,omitempty"\`
}

// TableName is Database TableName of this model
func (e *User) TableName() string {
	return "user"
}

EOF

echo "------ END ./pkg/models/userModel.go ------------";

echo "BEGIN WRITE ./pkg/models/postModel.go:";

cat << EOF > ./pkg/models/postModel.go
package models

import (
	"github.com/google/uuid"
	"time"
)

type Post struct {
	//ID          uuid.UUID     \`json:"id,omitempty" gorm:"type:uuid; default:uuid_generate_v4()"\`
	//CategoryID uint64 \`gorm:"primaryKey;autoIncrement:false"\`
	//aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee
	//gorm.Model
	ID          uuid.UUID \`json:"id,omitempty" gorm:"type:char(128);primaryKey"\`
	Title       string    \`json:"title,omitempty"\`
	Description string    \`json:"description,omitempty"\`
	CategoryID  uuid.UUID \`json:"category_id,omitempty" gorm:"type:char(128)"\`
	Category    *Category \`json:"category,omitempty"\`
	Price       uint32    \`json:"price,omitempty"\`
	UpdatedAt   time.Time \`json:"updated_at,omitempty"\`
	CreatedAt   time.Time \`json:"created_at,omitempty"\`
}

type Category struct {
	//ID        uuid.UUID \`json:"id,omitempty" gorm:"type:uuid; default:uuid_generate_v4()"\`
	//gorm.Model
	ID    uuid.UUID \`json:"id,omitempty" gorm:"type:char(128);primaryKey"\`
	Name  string    \`json:"name,omitempty"\`
	Posts *[]Post   \`json:"posts,omitempty"\`
	UpdatedAt time.Time \`json:"updated_at,omitempty"\`
	CreatedAt time.Time \`json:"created_at,omitempty"\`
}
EOF
echo "-------END ./pkg/models/postModel.go -----------";

echo "BEGIN WRITE ./pkg/repository/userRepository.go:";

cat << EOF > ./pkg/repository/userRepository.go
package repository

import (
	"$PROJECT/internal/infra/database"
	"$PROJECT/pkg/common/crud"
	"$PROJECT/pkg/models"
)

type UserMo = models.User

type UserRepository struct {
	crud.Repository[UserMo]
	user interface{}
}

func InitUserRepository() *UserRepository {
	return &UserRepository{
		Repository: crud.Repository[UserMo]{
			DB:    database.DB,
			Model: UserMo{},
		},
	}
}

EOF
echo "-------END ./pkg/repository/userRepository.go -----------";

echo "BEGIN WRITE ./pkg/repository/postRepository.go:";

cat << EOF > ./pkg/repository/postRepository.go
package repository

import (
	"$PROJECT/internal/infra/database"
	"$PROJECT/pkg/common/crud"
	"$PROJECT/pkg/models"
)

type PostMo = models.Post

type PostRepository struct {
	crud.Repository[PostMo]
	post interface{}
}

func InitPostRepository() *PostRepository {
	return &PostRepository{
		Repository: crud.Repository[PostMo]{
			DB:    database.DB,
			Model: PostMo{},
		},
	}
}
EOF
echo "-------END ./pkg/repository/postRepository.go -----------";

echo "BEGIN write  ./pkg/repository/sqlRepo source code files :";

cat << EOF > ./pkg/repository/sqlRepo.go
package repository

import (
	"$PROJECT/internal/infra/database"
	"$PROJECT/internal/infra/logger"
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

echo "------ END ./pkg/repository/sqlRepo.go ------------";

echo "BEGIN WRITE ./pkg/service/postService.go:";

cat << EOF > ./pkg/service/postService.go
package service

import (
	"$PROJECT/pkg/common/crud"
	rep "$PROJECT/pkg/repository"
)

type PostService struct {
	crud.Service[rep.PostMo]
	repo *rep.PostRepository
}

func NewPostService(repository *rep.PostRepository) *PostService {
	return &PostService{
		Service: *crud.NewService[rep.PostMo](repository),
		repo:    repository,
	}
}

func InitPostService() *PostService {
	return &PostService{
		repo:    rep.InitPostRepository(),
		Service: *crud.NewService[rep.PostMo](rep.InitPostRepository()),
	}
}
EOF

echo "------ END ./pkg/service/postService.go ------------";

echo "BEGIN WRITE ./pkg/service/userService.go:";

cat << EOF > ./pkg/service/userService.go
package service

import (
	"errors"
	"golang.org/x/crypto/bcrypt"
	"$PROJECT/internal/infra/database"
	"$PROJECT/pkg/common/crud"
	"$PROJECT/pkg/forms"
	"$PROJECT/pkg/models"
	rep "$PROJECT/pkg/repository"
)

type UserService struct {
	crud.Service[rep.UserMo]
	repo *rep.UserRepository
}

func NewUserService(repository *rep.UserRepository) *UserService {
	return &UserService{
		Service: *crud.NewService[rep.UserMo](repository),
		repo:    repository,
	}
}

func InitUserService() *UserService {
	return &UserService{
		repo:    rep.InitUserRepository(),
		Service: *crud.NewService[rep.UserMo](rep.InitUserRepository()),
	}
}

// UserModel ...
type UserModel struct{}

var authModel = new(models.AuthModel)

func (s UserService) Login(form forms.LoginForm) (user models.User, token models.Token, err error) {

	//err = db.GetDB().SelectOne(&user, "SELECT id, email, password, name, updated_at, created_at FROM public.user WHERE email=LOWER($1) LIMIT 1", form.Email)
	// Get first matched record
	result := database.DB.Find(&user)
	//result = database.DB.Where("email = ?", form.Email)

	if err != nil {
		return user, token, result.Error
	}

	//Compare the password form and database if match
	bytePassword := []byte(form.Password)
	byteHashedPassword := []byte(user.Password)

	err = bcrypt.CompareHashAndPassword(byteHashedPassword, bytePassword)

	if err != nil {
		return user, token, err
	}

	//Generate the JWT auth token
	tokenDetails, err := authModel.CreateToken(user.ID)
	if err != nil {
		return user, token, err
	}

	saveErr := authModel.CreateAuth(user.ID, tokenDetails)
	if saveErr == nil {
		token.AccessToken = tokenDetails.AccessToken
		token.RefreshToken = tokenDetails.RefreshToken
	}

	return user, token, nil
}

// Register ...
func (s UserService) Register(form forms.RegisterForm) (user models.User, err error) {

	//Check if the user exists in database
	//result, err := getDb.SelectInt("SELECT count(id) FROM public.user WHERE email=LOWER($1) LIMIT 1", form.Email)

	// Get first matched record
	result := database.DB.Where("email = ?", form.Email).Find(&user)
	checkUser := result.RowsAffected

	if result.Error != nil {
		return user, errors.New("something went wrong, please try again later")
	}

	if checkUser > 0 {
		return user, errors.New("email already exists")
	}

	bytePassword := []byte(form.Password)
	hashedPassword, err := bcrypt.GenerateFromPassword(bytePassword, bcrypt.DefaultCost)
	if err != nil {
		return user, errors.New("something went wrong, please try again later")
	}

	//Create the user and return back the user ID
	// err = getDb.QueryRow("INSERT INTO public.user(email, password, name) VALUES($1, $2, $3) RETURNING id", form.Email, string(hashedPassword), form.Name).Scan(&user.ID)

	user.Email = form.Email
	user.Password = string(hashedPassword)
	user.Name = form.Name

	result = database.DB.Create(&user) // 通过数据的指针来创建

	//user.ID             // 返回插入数据的主键

	if result.Error != nil {
		return user, errors.New("something went wrong, please try again later")
	}

	return user, err
}

EOF
echo "-------END ./pkg/service/userService.go -----------";

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
	"$PROJECT/internal/infra/logger"
	"$PROJECT/pkg/routers/middleware"
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
	"$PROJECT/pkg/controllers"
	"$PROJECT/pkg/service"
	"net/http"
)

// RegisterRoutes add all routing list here automatically get main router
func RegisterRoutes(route *gin.Engine) {
	userService := service.InitUserService()
	userController := controllers.NewUserController(userService)

	route.NoRoute(func(ctx *gin.Context) {
		ctx.JSON(http.StatusNotFound, gin.H{"status": http.StatusNotFound, "message": "Route Not Found"})
	})
	route.GET("/health", func(ctx *gin.Context) { ctx.JSON(http.StatusOK, gin.H{"live": "ok"}) })
	//added new
	route.GET("/v1/user/", userController.UserGetData)
	route.POST("/v1/user/", userController.UserCreate)
	route.POST("/v1/user/register", userController.Register)
	route.POST("/v1/user/login", userController.Login)

	//Add All route
	//TestRoutes(route)
	//Add All route
	//TestRoutes(route)
	postGroup := route.Group("/v1/post")
	RegisterPostRoutes(postGroup)
}

EOF

echo "------ ./pkg/routers/index.go ------------";

echo "write  ./pkg/routers/postRoute.go source code files :";

cat << EOF > ./pkg/routers/postRoute.go
package routers

import (
	"github.com/gin-gonic/gin"
	"$PROJECT/pkg/controllers"
	"$PROJECT/pkg/service"
)

func RegisterPostRoutes(routerGroup *gin.RouterGroup) {
	postService := service.InitPostService()
	postController := controllers.NewPostController(postService)

	routerGroup.GET("", postController.FindAll)
	routerGroup.GET(":id", postController.FindOne)
	routerGroup.POST("", postController.Create)
	routerGroup.DELETE(":id", postController.Delete)
	routerGroup.PATCH(":id", postController.Update)
}

EOF

echo "------ ./pkg/routers/postRoute.go ------------";


echo "write  ./main.go source code files :";

cat << EOF > ./main.go
 package main

 import (
 	"$PROJECT/config"
 	"$PROJECT/internal/infra/database"
 	"$PROJECT/internal/infra/logger"
 	"$PROJECT/pkg/migrations"
 	"$PROJECT/pkg/routers"
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
 	migrations.Migrate()

 	router := routers.SetupRoute()
 	logger.Fatalf("%v", router.Run(config.ServerConfig()))

 }

EOF

echo "------ ./main.go ------------";

echo "write  ./pkg/migrations/migration.go source code files :";

cat << EOF > ./pkg/migrations/migration.go
package migrations

import (
	"$PROJECT/internal/infra/database"
	"$PROJECT/pkg/models"
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

echo "BEGIN WRITE ./docs/docs.go:";

cat << EOF > ./docs/docs.go
// Package docs GENERATED BY SWAG; DO NOT EDIT
// This file was generated by swaggo/swag
package docs

import "github.com/swaggo/swag"

const docTemplate = \`{
    "schemes": {{ marshal .Schemes }},
    "swagger": "2.0",
    "info": {
        "description": "{{escape .Description}}",
        "title": "{{.Title}}",
        "contact": {
            "name": "API Support",
            "url": "http://www.swagger.io/support",
            "email": "support@swagger.io"
        },
        "license": {
            "name": "Apache 2.0",
            "url": "http://www.apache.org/licenses/LICENSE-2.0.html"
        },
        "version": "{{.Version}}"
    },
    "host": "{{.Host}}",
    "basePath": "{{.BasePath}}",
    "paths": {
        "/posts": {
            "get": {
                "tags": [
                    "posts"
                ],
                "parameters": [
                    {
                        "type": "string",
                        "description": "{'\$and': [ {'title': { '\$cont':'cul' } } ]}",
                        "name": "s",
                        "in": "query"
                    },
                    {
                        "type": "string",
                        "description": "fields to select eg: name,age",
                        "name": "fields",
                        "in": "query"
                    },
                    {
                        "type": "integer",
                        "description": "page of pagination",
                        "name": "page",
                        "in": "query"
                    },
                    {
                        "type": "integer",
                        "description": "limit of pagination",
                        "name": "limit",
                        "in": "query"
                    },
                    {
                        "type": "string",
                        "description": "join relations eg: category, parent",
                        "name": "join",
                        "in": "query"
                    },
                    {
                        "type": "array",
                        "items": {
                            "type": "string"
                        },
                        "description": "filters eg: name||\$eq||ad price||\$gte||200",
                        "name": "filter",
                        "in": "query"
                    },
                    {
                        "type": "array",
                        "items": {
                            "type": "string"
                        },
                        "description": "filters eg: created_at,desc title,asc",
                        "name": "sort",
                        "in": "query"
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "type": "array",
                            "items": {
                                "\$ref": "#/definitions/posts.model"
                            }
                        }
                    }
                }
            },
            "post": {
                "tags": [
                    "posts"
                ],
                "parameters": [
                    {
                        "description": "item to create",
                        "name": "{object}",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "\$ref": "#/definitions/posts.model"
                        }
                    }
                ],
                "responses": {
                    "201": {
                        "description": "Created",
                        "schema": {
                            "\$ref": "#/definitions/posts.model"
                        }
                    }
                }
            }
        },
        "/posts/{id}": {
            "get": {
                "tags": [
                    "posts"
                ],
                "parameters": [
                    {
                        "type": "string",
                        "description": "uuid of item",
                        "name": "id",
                        "in": "path",
                        "required": true
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "\$ref": "#/definitions/posts.model"
                        }
                    }
                }
            },
            "put": {
                "tags": [
                    "posts"
                ],
                "parameters": [
                    {
                        "type": "string",
                        "description": "uuid of item",
                        "name": "id",
                        "in": "path",
                        "required": true
                    },
                    {
                        "description": "update body",
                        "name": "item",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "\$ref": "#/definitions/posts.model"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "ok",
                        "schema": {
                            "type": "string"
                        }
                    }
                }
            },
            "delete": {
                "tags": [
                    "posts"
                ],
                "parameters": [
                    {
                        "type": "string",
                        "description": "uuid of item",
                        "name": "id",
                        "in": "path",
                        "required": true
                    }
                ],
                "responses": {
                    "200": {
                        "description": "ok",
                        "schema": {
                            "type": "string"
                        }
                    }
                }
            }
        }
    },
    "definitions": {
        "models.Category": {
            "type": "object",
            "properties": {
                "created_at": {
                    "type": "string"
                },
                "id": {
                    "type": "string"
                },
                "name": {
                    "type": "string"
                },
                "posts": {
                    "type": "array",
                    "items": {
                        "\$ref": "#/definitions/models.Post"
                    }
                },
                "updated_at": {
                    "type": "string"
                }
            }
        },
        "models.Post": {
            "type": "object",
            "properties": {
                "category": {
                    "\$ref": "#/definitions/models.Category"
                },
                "category_id": {
                    "type": "string"
                },
                "created_at": {
                    "type": "string"
                },
                "description": {
                    "type": "string"
                },
                "id": {
                    "type": "string"
                },
                "price": {
                    "type": "integer"
                },
                "title": {
                    "type": "string"
                },
                "updated_at": {
                    "type": "string"
                }
            }
        },
        "posts.model": {
            "type": "object",
            "properties": {
                "category": {
                    "\$ref": "#/definitions/models.Category"
                },
                "category_id": {
                    "type": "string"
                },
                "created_at": {
                    "type": "string"
                },
                "description": {
                    "type": "string"
                },
                "id": {
                    "type": "string"
                },
                "price": {
                    "type": "integer"
                },
                "title": {
                    "type": "string"
                },
                "updated_at": {
                    "type": "string"
                }
            }
        }
    }
}\`

// SwaggerInfo holds exported Swagger Info so clients can modify it
var SwaggerInfo = &swag.Spec{
	Version:          "",
	Host:             "",
	BasePath:         "",
	Schemes:          []string{},
	Title:            "",
	Description:      "",
	InfoInstanceName: "swagger",
	SwaggerTemplate:  docTemplate,
}

func init() {
	swag.Register(SwaggerInfo.InstanceName(), SwaggerInfo)
}

EOF
echo "-------END ./pkg/common/AAA.go -----------";

echo "write cmd/generate-certificate.sh:";

cat << EOF > ./cmd/generate-certificate.sh
#!/usr/bin/bash
#ps aux |grep  wvp

cd .. && mkdir -p cert

cd cert/

ip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
echo \$ip

openssl genrsa -out myCA.key 2048

openssl req -x509 -new -key myCA.key -out myCA.cer -days 730 -subj /CN=\$ip

openssl genrsa -out mycert1.key 2048

openssl req -new -out mycert1.req -key mycert1.key -subj /CN=\$ip

openssl x509 -req -in mycert1.req -out mycert1.cer -CAkey myCA.key -CA myCA.cer -days 365 -CAcreateserial -CAserial serial

cd ../

EOF

echo "-------./cmd/generate-certificate.sh-----------";

echo "write test/test.http:";

cat << EOF > ./test/test.http

### TEST REST API 
### CREATE USER
POST http://localhost:6060/v1/user/
Accept: application/json

{
    "email":"dav@ml.com",
    "password": "12345"
}
### GET ALL USER
GET http://localhost:6060/v1/user/
Accept: application/json

### GET ALL POST
GET http://localhost:6060/v1/post/
Accept: application/json

### USER REGISTER
POST http://localhost:6060/v1/user/register
Accept: application/json

{
    "name":"adea@ml.com",
    "email":"adea@ml.com",
    "password": "12345"
}


###
POST http://localhost:6060/v1/user/login
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


echo "write deployments/Dockerfile:";

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

# Copy everything
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

echo "WRITE deployments/Dockerfile-dev:";

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

echo "WRITE ./deployments/docker-compose-prod.yml:";

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


echo "WRITE ./deployments/docker-compose-dev.yml:";

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

CompileDaemon -command="./$PROJECT"
