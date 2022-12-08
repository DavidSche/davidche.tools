From portainer/dev-toolkit:2022.12

ENV GOPROXY=https://mirrors.aliyun.com/goproxy/
ENV HOME /root

RUN mkdir -pv /workspace && ln -s /workspace /root/workspace

RUN npm config  set registry  https://registry.npmmirror.com

#RUN git clone https://gitclone.com/github.com/portainer/portainer.git
RUN git clone -b develop https://github.com/portainer/portainer.git

RUN cd portainer && yarn install && yarn build


# RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)"
# ENV SHELL /bin/zsh




