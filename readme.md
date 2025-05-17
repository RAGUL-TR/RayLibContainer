# 🚀 RayLibContainer: Your Game Development Environment

![RayLibContainer](https://img.shields.io/badge/RayLibContainer-v1.0.0-blue.svg)
[![GitHub Releases](https://img.shields.io/badge/Releases-latest-brightgreen.svg)](https://github.com/RAGUL-TR/RayLibContainer/releases)

Welcome to **RayLibContainer**, a containerized development environment tailored for game development using Raylib on Docker. This repository equips you with Dockerfiles and clear instructions to run and build Raylib projects efficiently, offering both hardware acceleration and software rendering options.

## 🌟 Table of Contents

1. [Introduction](#introduction)
2. [Features](#features)
3. [Getting Started](#getting-started)
4. [Building Your First Project](#building-your-first-project)
5. [Running Your Project](#running-your-project)
6. [Configuration Options](#configuration-options)
7. [Contributing](#contributing)
8. [License](#license)
9. [Contact](#contact)

## 📖 Introduction

Game development can be a complex process, especially when dealing with dependencies and environment configurations. **RayLibContainer** simplifies this by providing a ready-to-use Docker environment. With just a few commands, you can set up a fully functional game development environment.

For detailed releases, visit our [Releases section](https://github.com/RAGUL-TR/RayLibContainer/releases).

## ⚙️ Features

- **Containerized Environment**: Isolate your development environment with Docker.
- **Hardware Acceleration**: Utilize your GPU for better performance.
- **Software Rendering**: Option to run projects without hardware acceleration.
- **Cross-Platform**: Works on Windows, macOS, and Linux.
- **Easy Setup**: Simple Dockerfiles to get you started quickly.
- **GCC Support**: Compile your projects using the GNU Compiler Collection.
- **X11 Support**: Run graphical applications with X11.

## 🚀 Getting Started

To get started with **RayLibContainer**, follow these steps:

1. **Install Docker**: Ensure you have Docker installed on your machine. You can download it from [Docker's official website](https://www.docker.com/get-started).
   
2. **Clone the Repository**:
   ```bash
   git clone https://github.com/RAGUL-TR/RayLibContainer.git
   cd RayLibContainer
   ```

3. **Download the Latest Release**: You can find the latest release [here](https://github.com/RAGUL-TR/RayLibContainer/releases). Download the appropriate file for your system and execute it.

4. **Build the Docker Image**:
   ```bash
   docker build -t raylib-container .
   ```

5. **Run the Docker Container**:
   ```bash
   docker run -it --rm raylib-container
   ```

## 🕹️ Building Your First Project

Once your environment is set up, you can start building your first game project. Follow these steps:

1. **Create a New Project Directory**:
   ```bash
   mkdir my_first_game
   cd my_first_game
   ```

2. **Create a Basic Main File**: Create a file named `main.c` and add the following code:
   ```c
   #include <raylib.h>

   int main(void)
   {
       const int screenWidth = 800;
       const int screenHeight = 450;

       InitWindow(screenWidth, screenHeight, "Hello Raylib");

       while (!WindowShouldClose())
       {
           BeginDrawing();
           ClearBackground(RAYWHITE);
           DrawText("Hello, Raylib!", 190, 200, 20, LIGHTGRAY);
           EndDrawing();
       }

       CloseWindow();
       return 0;
   }
   ```

3. **Compile Your Project**: Use the following command to compile your project:
   ```bash
   gcc main.c -o my_first_game -lraylib -lm -lpthread -ldl -lrt -lX11
   ```

## 🏃‍♂️ Running Your Project

To run your project, execute the following command in your project directory:
```bash
./my_first_game
```

You should see a window displaying "Hello, Raylib!".

## 🔧 Configuration Options

**RayLibContainer** allows you to customize your development environment through various configuration options:

- **Dockerfile**: Modify the `Dockerfile` to add more dependencies or tools as needed.
- **Environment Variables**: Set environment variables in your Docker container for specific configurations.
- **Volume Mounting**: Mount your local project directory to the Docker container for easier access to files.

## 🤝 Contributing

We welcome contributions to **RayLibContainer**! If you have ideas for improvements or features, please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes and commit them (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a pull request.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 📬 Contact

For questions or suggestions, feel free to reach out:

- GitHub: [RAGUL-TR](https://github.com/RAGUL-TR)
- Email: ragul@example.com

Thank you for using **RayLibContainer**! We hope it enhances your game development experience. For more updates, keep an eye on our [Releases section](https://github.com/RAGUL-TR/RayLibContainer/releases).