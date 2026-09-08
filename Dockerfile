FROM qwen-image-edit-2511:v1


ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

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
    nano \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

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

RUN curl -fsSL https://code-server.dev/install.sh | sh

RUN pip3 install \
    --break-system-packages \
    jupyterlab

RUN mkdir -p \
    /root/develop/vscode-config \
    /root/develop/vscode-extensions \
    /root/develop/vscode-server \
    /root/develop/jupyter-config \
    /root/develop/jupyter-data

RUN mkdir /run/sshd

COPY root/etc/services.d /etc/services.d

RUN find /etc/services.d -type f -name run -exec sed -i 's/\r$//' {} \; \
    && find /etc/services.d -type f -name run -exec chmod +x {} \;

WORKDIR /root/develop

ENTRYPOINT ["/init"]
