FROM bitnami/postgresql:10.7.0
LABEL maintainer "David <davidche@outlook.com>"
ENV BITNAMI_PKG_CHMOD="-R g+rwX" \
    HOME="/" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="debian-9" \
    OS_NAME="linux" \
    TIMEZONE="Asia/Hongkong" \
    DEBIAN_FRONTEND="noninteractive" \
    DOWNLOAD_URL="https://www.zombodb.com/releases/v10-1.0.3/zombodb_jessie_pg10-10-1.0.3_amd64.deb"

# User root is required for installing packages
USER root

RUN echo $TIMEZONE > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata
	
RUN install_packages  wget curl -y
RUN wget $DOWNLOAD_URL
RUN dpkg -i zombodb_jessie_pg10-10-1.0.3_amd64.deb
# Return to previous non-root user
USER 1001