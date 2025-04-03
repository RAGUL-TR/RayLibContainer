FROM alpine:latest

RUN apk update && apk add --no-cache \
    bash \
    build-base \
    git \
    xeyes\
    gcc \
    cmake \
    pkgconfig \
    alsa-lib-dev \
    libx11-dev \
    libxrandr-dev \
    libxi-dev \
    mesa-dev \
    libxcursor-dev \
    libxinerama-dev \
    wayland-dev \
    wayland-protocols \
    libxkbcommon-dev \
    mesa-dri-gallium \
    xorg-server \
    xf86-video-dummy \
    xvfb \
    weston \
    dbus

WORKDIR /app

RUN mkdir -p /tmp/raylib && \
    cd /tmp/raylib && \
    git clone https://github.com/raysan5/raylib.git && \
    cd raylib && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
    -DPLATFORM=Desktop \
    -DUSE_WAYLAND=ON \
    -DUSE_EXTERNAL_GLFW=OFF \
    .. && \
    make && \
    make install && \
    cd /app && \
    rm -rf /tmp/raylib

RUN git clone https://github.com/raylib-extras/raylib-quickstart.git /app/raylib-quickstart

RUN mkdir -p /app/user_code

VOLUME ["/app/user_code"]
WORKDIR /app/user_code
