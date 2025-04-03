# Stage 1: Build (Compilação)
FROM alpine:latest AS builder

RUN apk update && apk upgrade && \
    apk add --no-cache \
    git \
    cmake \
    make \
    gcc \
    g++ \
    linux-headers \
    mesa-dev \
    alsa-lib-dev \
    libx11-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxi-dev && \
    rm -rf /var/cache/apk/*


WORKDIR /tmp

RUN git clone --depth=1 https://github.com/raysan5/raylib.git && \
    cd raylib && \
    mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DPLATFORM=Desktop \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX=/usr/local && \
    make -j$(nproc) && \
    make install
RUN git clone --depth=1 https://github.com/raylib-extras/raylib-quickstart.git /tmp/raylib-quickstart

# Stage 2: Runtime (Execução)
FROM alpine:latest

RUN apk update && apk upgrade && \
    apk add --no-cache \
    mesa-gl \
    alsa-lib \
    libx11 \
    mesa-dev \
    libx11-dev \
    libxrandr \
    libxinerama \
    libxcursor \
    libxi \
    xeyes \
    gcc \
    g++ \
    make && \
    rm -rf /var/cache/apk/*

COPY --from=builder /usr/local /usr/local

RUN mkdir -p /app && \
    cp -R /tmp/raylib-quickstart /app/raylib-quickstart || true

RUN mkdir -p /app/user_code
WORKDIR /app/user_code

VOLUME ["/app/user_code"]

