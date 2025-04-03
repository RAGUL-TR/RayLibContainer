## Compatibilidade MacOSX para o Container Raylib

**[English Version](MacOSX-Compatibilty.md)**

Para executar aplicações gráficas dentro de um container Docker no macOS, alguns passos adicionais são necessários para permitir que o container acesse o display do macOS. Veja como fazer:

### 1. Instale o XQuartz

XQuartz é uma implementação do X Window System para macOS. Ele é necessário para encaminhar o display gráfico do container Docker para o seu ambiente macOS.

- Baixe o XQuartz do site oficial: [https://www.xquartz.org/](https://www.xquartz.org/)
- Instale o XQuartz seguindo as instruções fornecidas no pacote baixado.
- **Importante:** Após a instalação, você deve sair da sua conta macOS e entrar novamente para que as alterações tenham efeito.

### 2. Configure o XQuartz

Após instalar e fazer login novamente, configure o XQuartz para permitir conexões de clientes de rede:

- Abra o XQuartz.
- Vá para as Preferências do XQuartz (XQuartz → Preferências).
- Na aba "Segurança", certifique-se de que a opção "Permitir conexões de clientes de rede" esteja marcada.

### 3. Abra o Display

Abra um terminal e execute o seguinte comando para permitir conexões do Docker:

```bash
xhost + 127.0.0.1
```

Este comando permite conexões da máquina local, o que é necessário para que o Docker encaminhe o display gráfico.

### 4. Execute o Container Docker

Agora você pode executar o container Docker com os parâmetros necessários para encaminhar o display. Aqui está um exemplo:

```bash
docker run -it --rm \
    -e DISPLAY=127.0.0.1:0 \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ./user_code:/app/user_code \
    raylib_container
```

**Explicação dos Parâmetros:**

- `-e DISPLAY=127.0.0.1:0`: Define a variável de ambiente `DISPLAY` para o endereço correto para XQuartz no macOS.
- `-v /tmp/.X11-unix:/tmp/.X11-unix`: Monta o diretório de socket X11 para permitir a comunicação com o servidor X.
- `-v ./user_code:/app/user_code`: Monta seu diretório local `user_code` no diretório `/app/user_code` dentro do container. Coloque os arquivos do seu projeto Raylib no diretório `user_code`.
- `raylib_container`: O nome da imagem Docker.

### 5. Verifique a Conexão

Dentro do container, execute `xeyes` para verificar se o display gráfico está funcionando corretamente:

```bash
xeyes
```

Se `xeyes` abrir uma janela e os olhos seguirem o cursor do mouse, a configuração está correta e você pode prosseguir com o desenvolvimento do seu projeto Raylib.

### Notas Adicionais

- Certifique-se de que o XQuartz esteja em execução antes de iniciar o container Docker.
- Se você encontrar algum problema, verifique se seguiu todos os passos corretamente, especialmente sair e entrar novamente após instalar o XQuartz e configurar suas configurações de segurança.

Se você tiver alguma dificuldade, por favor, leia o arquivo [README](readme.md) principal primeiro. Se o problema persistir, sinta-se à vontade para abrir uma issue no repositório do projeto para obter ajuda.
