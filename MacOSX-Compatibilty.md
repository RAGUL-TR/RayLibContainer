## MacOSX Compatibility for Raylib Docker Container

**[Versão em Português](MacOSX-Compatibility-pt.md)**

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

If you have any difficulties, please read the main [README](readme.md) file first. If the problem persists, feel free to open an issue on the project's repository for assistance.
