FROM maximedurand/stylegan3

# タイムゾーン設定
ENV SHELL=/bin/bash
# ENV TZ=Asia/Tokyo
# RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG USER_NAME=${USER_NAME}
ARG USER_UID=${USER_UID}
ARG USER_GID=${USER_GID}

WORKDIR /workspace


RUN groupadd --gid $USER_GID $USER_NAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USER_NAME && \
    apt-get update &&\
    apt-get install -y vim &&\
    pip install --upgrade pip

USER $USER_NAME