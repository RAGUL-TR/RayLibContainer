# Stage 1: Build
FROM alpine:latest AS builder

# Instala dependências de build
RUN apk update && apk add --no-cache \
    bash \
    build-base \
    git \
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
    libxkbcommon-dev

WORKDIR /tmp

# Compila raylib
RUN git clone --depth=1 https://github.com/raysan5/raylib.git && \
    cd raylib && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
    -DPLATFORM=Desktop \
    -DUSE_WAYLAND=ON \
    -DUSE_EXTERNAL_GLFW=OFF \
    .. && \
    make && \
    make install

# Se o raylib-quickstart for necessário para compilar sua aplicação, você pode compilá-la aqui
RUN git clone --depth=1 https://github.com/raylib-extras/raylib-quickstart.git /tmp/raylib-quickstart

# Se houver etapas de compilação da sua aplicação que dependam do raylib, inclua-as aqui.
# Por exemplo:
# WORKDIR /tmp/raylib-quickstart
# RUN make

# Stage 2: Runtime
FROM alpine:latest

# Instala somente as dependências necessárias para executar o que foi compilado.
RUN apk update && apk add --no-cache \
    bash \
    alsa-lib \
    libx11 \
    libxrandr \
    libxi \
    mesa \
    libxcursor \
    libxinerama \
    wayland \
    wayland-protocols \
    libxkbcommon \
    mesa-dri-gallium \
    xorg-server \
    xf86-video-dummy \
    xvfb \
    weston \
    dbus

# Copia os arquivos compilados do estágio builder.
# Ajuste os caminhos conforme o que foi compilado e instalado.
# Aqui estamos copiando os arquivos instalados a partir do /usr/local,
# que é onde o make install normalmente coloca os binários/bibliotecas.
COPY --from=builder /usr/local /usr/local

# Se precisar dos arquivos do raylib-quickstart para execução ou exemplos
RUN mkdir -p /app && \
    cp -R /tmp/raylib-quickstart /app/raylib-quickstart || true

RUN mkdir -p /app/user_code
WORKDIR /app/user_code

VOLUME ["/app/user_code"]

CMD ["/bin/bash"]
