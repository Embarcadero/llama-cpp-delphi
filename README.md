# 🐫 llama-cpp-delphi

Welcome to **llama-cpp-delphi**, the Delphi bindings for [llama.cpp](https://github.com/ggerganov/llama.cpp)! This project allows you to integrate the power of Llama-based Large Language Models (LLMs) into your Delphi applications, enabling efficient and versatile local inference.

## 🚀 Features

- **Delphi Integration**: Harness Llama models directly in your Delphi projects.
- **Local Inference**: No external servers or APIs required—your data stays local.
- **Cross-Platform Support**: Compatible with Windows, Linux, and Mac.
  - 🖥️ **Mac Silicon**: GPU (MPS) and CPU inference supported.
  - 💻 **Windows**: CPU inference supported, with options for CUDA, Vulkan, HIP, Kompute, and OpenBLAS.
  - 🌏 **Linux**: CPU inference supported, with options for CUDA, Vulkan, HIP, and MUSA.
  - 🚀 **Android and iOS support coming soon!**
- **Pre-Built Libraries**: Simplified setup with pre-compiled libraries.
- **Customizable Sampling**: Fine-tune your AI’s behavior with easy-to-configure samplers.

## 🔧 Getting Started

### Prerequisites

1. **Delphi IDE** installed.
2. **Git** installed (required for cloning model repositories).
3. A basic understanding of Delphi development.

### Installation

1. Clone the **llama-cpp-delphi** repository:
   ```bash
   git clone https://github.com/Embarcadero/llama-cpp-delphi.git
   ```
2. Open the project in Delphi IDE.
3. Build the project for your desired platform(s):
   - Windows
   - Linux
   - Mac Silicon

### Libraries

The necessary **llama.cpp** libraries are distributed as part of the releases of this repository. You can find them under the "Release" section in the repository.

## 🌟 Using llama-cpp-delphi

### Key Components

- **Llama**: Delphi-friendly IDE component.

### Running Samples

1. Explore the `samples` directory for available examples, like **SimpleChatWithDownload**.
2. Follow the README provided in each sample folder for detailed instructions.

## 🔧 Configuration

### Models

You can use any model compatible with **llama.cpp** (e.g., GGUF format). Popular options include:
- **Llama-2**: A robust and general-purpose model.
- **Llama-3**: A lightweight alternative with excellent performance.
- **Mistral**: A compact and efficient model.
- **DeepSeek**: An innovative model designed for exploratory tasks.

### Hardware Support

- **Mac Silicon**:
  - GPU inference (via MPS) is recommended for optimal performance.
  - CPU inference is available but slower.
- **Windows**:
  - CPU inference supported, with additional support for CUDA, Vulkan, Kompute, HIP, and OpenBLAS.
- **Linux**:
  - CPU inference supported, with additional support for CUDA, Vulkan, HIP, and MUSA.

## 🤝 Contributions

We welcome contributions to improve **llama-cpp-delphi**! Feel free to:
- Report issues.
- Submit pull requests.
- Suggest enhancements.

## 📝 License

This project is licensed under the MIT License—see the `LICENSE` file for details.

## 🌟 Final Notes

Get started with **llama-cpp-delphi** and bring advanced AI capabilities to your Delphi projects. If you encounter any issues or have suggestions, let us know—we’re here to help! Happy coding! 🎉

