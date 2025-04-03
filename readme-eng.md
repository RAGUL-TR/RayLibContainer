# Raylib on Docker (Container)

Container created by Gabriel Miguel ([@gm64x](https://github.com/gm64x)) focused on game development using [Raylib](https://www.raylib.com/). The goal is to provide a consistent and isolated development environment, minimizing configuration issues on the host system.

You can see the Container image here: \
[Raylib-Container](https://hub.docker.com/r/gmaia325/raylib_container)

**[Versão em Português](readme.md)**

## Prerequisites

Before using the container, you need to configure your host system to allow graphical applications from the container to run and to manage Docker without `sudo` (recommended).

### 1. Enabling Display Access (X11/Wayland)

Allow local Docker containers to connect to your graphics server (X11 or Wayland via XWayland).

```bash
# Allow connections from Docker
xhost +local:docker
```

> **Note:** This command usually needs to be run in each new graphical session or after rebooting the system. You might want to add it to your startup scripts (like `.profile`, `.xinitrc`, etc.).

### 2. Adding Your User to the Docker Group (Recommended)

This allows you to run `docker` commands without constantly needing `sudo`.

```bash
sudo usermod -aG docker $USER
```

> **Important:** After running this command, you **must log out and log back in** or **reboot the system** for the group change to take effect.

## Building the Image (If Necessary)

If you don't have the Docker image locally yet, or if you want to update it (e.g., after modifying the `Dockerfile` or to get a new Raylib version), use the `build` command:

```bash
# Navigate to the directory containing the 'Dockerfile'
# cd /path/to/project
docker build -t raylib_container .
```

## Running the Container

To start an interactive container with access to your display and your project code mounted:

**Option 1: With Graphics Hardware Acceleration (Recommended)**

This option attempts to use your host system's GPU for better performance.

```bash
docker run -it --rm \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ./user_code:/app/user_code \
    --device /dev/dri:/dev/dri \
    raylib_container
```

**Option 2: With Software Rendering (Fallback)**

Use this option if hardware acceleration doesn't work (you might see errors related to `dri`, `glx`, `mesa`, or graphics drivers). Performance will be lower.

```bash
docker run -it --rm \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ./user_code:/app/user_code \
    -e LIBGL_ALWAYS_SOFTWARE=1 \
    raylib_container
```

**Parameter Explanation:**

- `-it`: Starts the container in interactive mode with a terminal attached.
- `--rm`: Automatically removes the container when it exits.
- `-e DISPLAY=$DISPLAY`: Passes the host's `DISPLAY` environment variable to the container, telling it which screen to use.
- `-v /tmp/.X11-unix:/tmp/.X11-unix`: Mounts the host's X11 socket into the container, allowing graphical communication.
- `-v ./user_code:/app/user_code`: Mounts a directory named `user_code` (which will be created in the current host directory if it doesn't exist) into the container at `/app/user_code`. **This is where you should place your game's source code.** Files are synchronized between the host and the container.
- `--device /dev/dri:/dev/dri` (Option 1): Maps the host's Direct Rendering Infrastructure devices into the container, allowing GPU access.
- `-e LIBGL_ALWAYS_SOFTWARE=1` (Option 2): Forces the Mesa graphics library to use software (CPU) rendering.
- `raylib_container`: The name of the Docker image to use.

## Verifying the Graphics Connection

Once inside the container's terminal (after running `docker run`), test if the graphics connection is working:

```bash
xeyes
```

A window with eyes that follow the mouse should appear. You can close it (usually by right-clicking or closing the window normally).

## Developing Inside the Container

Your source code should be placed in the `user_code` folder on your host system, which is mapped to `/app/user_code` inside the container. The container already has GCC and Raylib libraries installed.

**Compilation Example:**

Navigate to your code directory inside the container (`cd /app/user_code` if needed) and compile your C file:

```bash
# Example for a file named 'my_game.c'
gcc my_game.c -o my_game -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
```

> **Note:** The linked libraries (`-l...`) might vary slightly depending on the Raylib features you use.

**Running the Compiled Program:**

```bash
./my_game
```

## Reverting Host Configuration Changes

If you want to undo the changes made in the prerequisites:

1.  **Revoke Display Access:**

    ```bash
    xhost -local:docker
    ```

2.  **Remove User from Docker Group:**

    ```bash
    sudo gpasswd -d $USER docker
    ```

    > Remember to log out/log in or reboot afterwards.

3.  **Docker Socket Permissions:**
    - **Do not change the Docker socket (`/var/run/docker.sock`) permissions to `666`!** This is a severe security risk. The correct and secure way to avoid `sudo` is to add your user to the `docker` group (Prerequisite 2).
    - If you _accidentally_ changed the permissions, the default is usually `660` with owner `root` and group `docker`. You might try to restore it with:
      ```bash
      # Only if you incorrectly changed permissions before!
      sudo chmod 660 /var/run/docker.sock
      sudo chown root:docker /var/run/docker.sock
      ```
    - But the best approach is **never** to use `chmod 666` on the socket.

## Troubleshooting

- **Error `docker: Cannot connect to the Docker daemon... Permission denied.`:** You likely haven't added your user to the `docker` group or didn't log out/log in after adding them. Try using `sudo docker ...` or follow Prerequisite 2.
- **Error `docker: invalid reference format`:** Check if the image name (`raylib_container`) is spelled correctly in the `docker run` command and that the image actually exists (check with `docker images`).
- **Window doesn't appear / Error `cannot open display: :0`:** Check that you ran `xhost +local:docker` in the current host graphical session. Also verify the `DISPLAY` variable is being passed correctly (`-e DISPLAY=$DISPLAY`).
- **Error `MESA: error: Failed to query drm device.`, `glx: failed to create dri3 screen`, `failed to load driver: iris/radeon/etc.`:** Hardware acceleration isn't working. Ensure the `--device /dev/dri:/dev/dri` flag was used. If it still fails, try **Option 2** of `docker run` (software rendering with `-e LIBGL_ALWAYS_SOFTWARE=1`).
- **Need to Rebuild Image:** If the image seems outdated or corrupted, rebuild it:

  ```bash
  docker build -t raylib_container .
  ```

or if you prefer:

```bash
    docker build --pull --rm -f 'Dockerfile' -t 'raylib_container:test' '.'
```
