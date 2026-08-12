FROM ubuntu:22.04


ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility


# -------------------------
# 基础工具
# -------------------------

RUN apt update && apt install -y \
    curl \
    wget \
    git \
    openssh-server \
    python3 \
    python3-pip \
    python3-venv \
    ca-certificates \
    sudo \
    vim \
    tmux \
    htop \
    && rm -rf /var/lib/apt/lists/*



# -------------------------
# s6-overlay
# -------------------------

ARG S6_OVERLAY_VERSION=3.2.0.0

RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH=amd64; fi && \
    wget -O /tmp/s6-overlay.tar.gz \
    https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay.tar.gz \
    && rm /tmp/s6-overlay.tar.gz


RUN wget -O /tmp/s6-overlay-x86.tar.gz \
    https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-x86.tar.gz \
    && rm /tmp/s6-overlay-x86.tar.gz



# -------------------------
# code-server
# -------------------------

RUN curl -fsSL https://code-server.dev/install.sh | sh


# -------------------------
# Jupyter
# -------------------------

RUN pip3 install \
    jupyterlab



# -------------------------
# workspace
# -------------------------

RUN mkdir -p \
    /root/develop/vscode-config \
    /root/develop/vscode-extensions \
    /root/develop/vscode-server \
    /root/develop/jupyter-config \
    /root/develop/jupyter-data



# -------------------------
# ssh
# -------------------------

RUN mkdir /run/sshd


# -------------------------
# s6 services
# -------------------------

COPY root/etc/services.d /etc/services.d


WORKDIR /root/develop
# s6入口

ENTRYPOINT ["/init"]