version: '2'

# starts 4 docker containers running minio server instances. Each
# minio server's web interface will be accessible on the host at port
# 9001 through 9004.
services:
 minio1:
  image: minio/minio:RELEASE.2018-12-13T02-04-19Z
  volumes:
   - data1:/data
  ports:
   - "9001:9000"
  environment:
   MINIO_ACCESS_KEY: minio
   MINIO_SECRET_KEY: minio123
  command: server http://minio1/data http://minio2/data http://minio3/data http://minio4/data 
 minio2:
  image: minio/minio:RELEASE.2018-12-13T02-04-19Z
  volumes:
   - data2:/data
  ports:
   - "9002:9000"
  environment:
   MINIO_ACCESS_KEY: minio
   MINIO_SECRET_KEY: minio123
  command: server http://minio1/data http://minio2/data http://minio3/data http://minio4/data 
 minio3:
  image: minio/minio:RELEASE.2018-12-13T02-04-19Z
  volumes:
   - data3:/data
  ports:
   - "9003:9000"
  environment:
   MINIO_ACCESS_KEY: minio
   MINIO_SECRET_KEY: minio123
  command: server http://minio1/data http://minio2/data http://minio3/data http://minio4/data 
 minio4:
  image: minio/minio:RELEASE.2018-12-13T02-04-19Z
  volumes:
   - data4:/data
  ports:
   - "9004:9000"
  environment:
   MINIO_ACCESS_KEY: minio
   MINIO_SECRET_KEY: minio123
  command: server http://minio1/data http://minio2/data http://minio3/data http://minio4/data 

## By default this config uses default local driver,
## For custom volumes replace with volume driver configuration.
volumes:
  data1:
  data2:
  data3:
  data4: