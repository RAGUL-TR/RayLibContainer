# Raylib on Docker (Container)

Container criado por Gabriel Miguel ([@gm64x](https://github.com/gm64x)) focado no desenvolvimento de jogos com [Raylib](https://www.raylib.com/). O objetivo é fornecer um ambiente de desenvolvimento consistente e isolado, minimizando problemas de configuração no sistema hospedeiro (host).

Você pode ver a imagem do Container aqui: \
[Raylib-Container](https://hub.docker.com/r/gmaia325/raylib_container)

**[English Version](readme.md)**

## Pré-requisitos

Antes de usar o container, você precisa configurar seu sistema hospedeiro para permitir a execução de aplicações gráficas do container e para gerenciar o Docker sem `sudo` (recomendado).

### 1. Habilitando Acesso ao Display X11/Wayland

Permita que containers Docker locais se conectem ao seu servidor gráfico (X11 ou Wayland via XWayland).

```bash
# Permite conexões do Docker
xhost +local:docker
```

> **Nota:** Este comando geralmente precisa ser executado a cada nova sessão do seu ambiente gráfico ou após reiniciar o sistema. Você pode adicioná-lo aos seus scripts de inicialização (como `.profile`, `.xinitrc`, etc.) se desejar.

### 2. Adicionando seu Usuário ao Grupo Docker (Recomendado)

Adicionar seu usuário ao grupo docker com o comando abaixo geralmente remove a necessidade de usar `sudo` para executar comandos docker:
```bash
sudo usermod -aG docker $USER
```
No entanto, é importante mencionar que, dependendo da configuração específica da sua distribuição Linux, pode haver situações (por exemplo, ao tentar interagir com a interface gráfica ou "abrir o display" a partir de um container) onde o uso de `sudo` ainda se faça necessário para algumas tarefas, independentemente de o usuário pertencer ao grupo docker.

> **Importante:** Após executar este comando, você **precisa fazer logout e login novamente** ou **reiniciar o sistema** para que a mudança de grupo tenha efeito.

## Construindo a Imagem (Se necessário)

Se você ainda não tem a imagem Docker localmente, ou se deseja atualizá-la (por exemplo, após modificar o `Dockerfile` ou para obter uma nova versão do Raylib), use o comando `build`:

```bash
# Navegue até o diretório que contém o arquivo 'Dockerfile'
# cd /caminho/para/o/projeto
docker build -t raylib_container .
```

## Executando o Container

Para iniciar um container interativo com acesso ao seu display e com o código do seu projeto montado:

**Opção 1: Com Aceleração de Hardware Gráfico (Recomendado)**

Esta opção tenta usar a GPU do seu sistema hospedeiro para melhor performance.

```bash
docker run -it --rm \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ./user_code:/app/user_code \
    --device /dev/dri:/dev/dri \
    raylib_container
```

**Opção 2: Com Renderização via Software (Fallback)**

Use esta opção se a aceleração de hardware não funcionar (você pode ver erros relacionados a `dri`, `glx`, `mesa` ou drivers gráficos). A performance será menor.

```bash
docker run -it --rm \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ./user_code:/app/user_code \
    -e LIBGL_ALWAYS_SOFTWARE=1 \
    raylib_container
```

**Explicação dos Parâmetros:**

- `-it`: Inicia o container em modo interativo com um terminal.
- `--rm`: Remove o container automaticamente quando ele for finalizado.
- `-e DISPLAY=$DISPLAY`: Passa a variável de ambiente `DISPLAY` do host para o container, indicando qual tela usar.
- `-v /tmp/.X11-unix:/tmp/.X11-unix`: Monta o socket do X11 do host dentro do container, permitindo a comunicação gráfica.
- `-v ./user_code:/app/user_code`: Monta um diretório chamado `user_code` (que será criado no diretório atual do host se não existir) dentro do container em `/app/user_code`. **Este é o local onde você deve colocar o código-fonte do seu jogo.** Os arquivos são sincronizados entre o host e o container.
- `--device /dev/dri:/dev/dri` (Opção 1): Mapeia os dispositivos de renderização direta (Direct Rendering Infrastructure) do host para o container, permitindo o acesso à GPU.
- `-e LIBGL_ALWAYS_SOFTWARE=1` (Opção 2): Força a biblioteca gráfica Mesa a usar renderização por software (CPU).
- `raylib_container`: O nome da imagem Docker a ser usada.

## Verificando a Conexão Gráfica

Uma vez dentro do terminal do container (após executar `docker run`), teste se a conexão gráfica está funcionando:

```bash
xeyes
```

Uma janela com olhos que seguem o mouse deve aparecer. Você pode fechá-la (geralmente clicando com o botão direito ou fechando a janela normalmente).

## Desenvolvendo Dentro do Container

Seu código-fonte deve ser colocado na pasta `user_code` no seu sistema hospedeiro, que está mapeada para `/app/user_code` dentro do container. O container já tem o GCC e as bibliotecas Raylib instaladas.

**Exemplo de Compilação:**

Navegue até o diretório do seu código dentro do container (`cd /app/user_code` se necessário) e compile seu arquivo C:

```bash
# Exemplo para um arquivo chamado 'meu_jogo.c'
gcc meu_jogo.c -o meu_jogo -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
```

> **Nota:** As bibliotecas (`-l...`) podem variar ligeiramente dependendo das funcionalidades do Raylib que você usar.

**Executando o Programa Compilado:**

```bash
./meu_jogo
```

## Revertendo as Configurações do Host

Caso queira reverter as alterações feitas nos pré-requisitos:

1.  **Revogar Acesso ao Display:**

    ```bash
    xhost -local:docker
    ```

2.  **Remover Usuário do Grupo Docker:**

    ```bash
    sudo gpasswd -d $USER docker
    ```

    > Lembre-se de fazer logout/login ou reiniciar após isso.

3.  **Permissões do Socket Docker:**
    - **Não altere as permissões do socket Docker (`/var/run/docker.sock`) para `666`!** Isso é uma falha grave de segurança. A maneira correta e segura de evitar o `sudo` é adicionar seu usuário ao grupo `docker` (Pré-requisito 2).
    - Se você _acidentalmente_ alterou as permissões, o padrão geralmente é `660` com proprietário `root` e grupo `docker`. Você pode tentar restaurar com:
      ```bash
      # Apenas se você alterou as permissões incorretamente antes!
      sudo chmod 660 /var/run/docker.sock
      sudo chown root:docker /var/run/docker.sock
      ```
    - Mas a melhor abordagem é **nunca** usar `chmod 666` no socket.

## Troubleshooting

- **Erro `docker: Cannot connect to the Docker daemon... Permission denied.`:** Você provavelmente não adicionou seu usuário ao grupo `docker` ou não fez logout/login após adicioná-lo. Tente usar `sudo docker ...` ou siga o Pré-requisito 2.
- **Erro `docker: invalid reference format`:** Verifique se o nome da imagem (`raylib_container`) está digitado corretamente no comando `docker run` e se a imagem realmente existe (verifique com `docker images`).
- **Janela não aparece / Erro `cannot open display: :0`:** Verifique se você executou `xhost +local:docker` na sessão gráfica atual do host. Verifique também se a variável `DISPLAY` está sendo passada corretamente (`-e DISPLAY=$DISPLAY`).
- **Erro `MESA: error: Failed to query drm device.`, `glx: failed to create dri3 screen`, `failed to load driver: iris/radeon/etc.`:** A aceleração de hardware não está funcionando. Certifique-se de que a flag `--device /dev/dri:/dev/dri` foi usada. Se ainda falhar, tente a **Opção 2** do `docker run` (renderização via software com `-e LIBGL_ALWAYS_SOFTWARE=1`).
- **Necessário Reconstruir a Imagem:** Se a imagem parecer desatualizada ou corrompida, reconstrua-a:
  ```bash
  docker build -t raylib_container .
  ```
  ou se preferir:

```bash
    docker build --pull --rm -f 'Dockerfile' -t 'raylib_container:test' '.'
```
