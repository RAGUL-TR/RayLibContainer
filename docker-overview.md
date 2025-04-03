# Raylib on Docker (Container)

Container focused on game development using [Raylib](https://www.raylib.com/). The goal is to provide a consistent and isolated development environment, minimizing configuration issues on the host system.

You can see the Container Github Repo here: \
[Raylib-Container](https://github.com/gm64x/RayLibContainer)

> **Are you using macOS?** Follow the guide for specific instructions. Go to [MacOS Compatibility Guide](#macos-compatibility-guide) section below.

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

Adding your user to the `docker` group with the command below generally removes the need to use `sudo` to execute `docker` commands:

```bash
sudo usermod -aG docker $USER
```

However, it's important to mention that, depending on the specific configuration of your Linux distribution, there might be situations (for example, when trying to interact with the graphical interface or "open the display" from within a container) where using `sudo` might still be necessary for some tasks, even if the user is a member of the `docker` group.

> **Important:** After running this command, you **must log out and log back in** or **reboot the system** for the group change to take effect.

## Building the Image (If Necessary)

If you don't have the Docker image locally yet, or if you want to update it (e.g., after modifying the `Dockerfile` or to get a new Raylib version), use the `build` command:

```bash
# Navigate to the directory containing the 'Dockerfile'
# cd /path/to/project
docker build -t raylib_container .
```

> **Up-to-date Raylib:** When building the image, Raylib is cloned and compiled directly from the official GitHub repository, ensuring you always have the latest version available.

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

## MacOS Compatibility Guide

To run graphical applications within a Docker container on macOS, some additional steps are required to enable the container to access the macOS display. Here's how to do it:

### 1. Install XQuartz

XQuartz is an X Window System implementation for macOS. It is required to forward the graphical display from the Docker container to your macOS environment.

- Download XQuartz from the official website: [https://www.xquartz.org/](https://www.xquartz.org/)
- Install XQuartz by following the instructions provided in the downloaded package.
- **Important:** After installation, you must log out and log back in to your macOS account for the changes to take effect.

### 2. Configure XQuartz

After installing and logging back in, configure XQuartz to allow connections from network clients:

- Open XQuartz.
- Go to XQuartz Preferences (XQuartz → Preferences).
- In the "Security" tab, make sure "Allow connections from network clients" is checked.

### 3. Open Display

Open a terminal and run the following command to allow connections from Docker:

```bash
xhost + 127.0.0.1
```

This command allows connections from the local machine, which is necessary for Docker to forward the graphical display.

### 4. Run Docker Container

Now you can run the Docker container with the necessary parameters to forward the display. Here's an example:

```bash
docker run -it --rm \
    -e DISPLAY=127.0.0.1:0 \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ./user_code:/app/user_code \
    raylib_container
```

**Explanation of Parameters:**

- `-e DISPLAY=127.0.0.1:0`: Sets the `DISPLAY` environment variable to the correct address for XQuartz on macOS.
- `-v /tmp/.X11-unix:/tmp/.X11-unix`: Mounts the X11 socket directory to allow communication with the X server.
- `-v ./user_code:/app/user_code`: Mounts your local `user_code` directory to the `/app/user_code` directory inside the container. Place your Raylib project files in the `user_code` directory.
- `raylib_container`: The name of the Docker image.

### 5. Verify the Connection

Inside the container, run `xeyes` to verify that the graphical display is working correctly:

```bash
xeyes
```

If `xeyes` opens a window and the eyes follow your mouse cursor, the configuration is correct, and you can proceed with developing your Raylib project.

### Additional Notes

- Ensure that XQuartz is running before you start the Docker container.
- If you encounter any issues, double-check that you have followed all the steps correctly, especially logging out and back in after installing XQuartz and configuring its security settings.

If the problem persists, feel free to open an issue on the project's repository for assistance.

---

This file is under the license of Eclipse Public License 2.0
