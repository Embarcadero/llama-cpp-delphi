# 🐫 llama-cpp-delphi

Welcome to **llama-cpp-delphi**, the Delphi bindings for [llama.cpp](https://github.com/ggerganov/llama.cpp)! This project allows you to integrate the power of Llama-based Large Language Models (LLMs) into your Delphi applications, enabling efficient and versatile local inference.

## 🚀 Features

- **Delphi Integration**: Harness Llama models directly in your Delphi projects.
- **Local Inference**: No external servers or APIs required—your data stays local.
- **Cross-Platform Support**: Compatible with Windows, Linux, and Mac.
  - 🖥️ **Mac Silicon**: GPU (MPS) and CPU inference supported.
  - 💻 **Windows**: CPU inference supported, with options for CUDA, Vulkan, Kompute, and OpenBLAS.
  - 🌏 **Linux**: CPU inference supported, with options for CUDA, Vulkan, Kompute, and OpenBLAS.
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

The necessary **llama.cpp** libraries are distributed as part of the releases of this repository. You can find them under the "Release" section in the repository. Here's an explanation of the libraries available:

#### CPU Build

CPU-only builds for Windows, Linux, and macOS. Inference runs slow on CPU—consider using a GPU-based library.

#### BLAS Build

Building the program with BLAS support may lead to some performance improvements in prompt processing using batch sizes higher than 32 (the default is 512). Using BLAS doesn't affect the generation performance. There are several different BLAS implementations available for build and use:

- **Accelerate Framework**: Available on macOS, enabled by default.
- **OpenBLAS**: Provides CPU-based BLAS acceleration. Ensure OpenBLAS is installed on your machine.
- **BLIS**: A high-performance portable BLAS framework. [Learn more](https://github.com/flame/blis).
- **Intel oneMKL**: Optimized for Intel processors, supporting advanced instruction sets like avx\_vnni.

#### SYCL

SYCL is a higher-level programming model to improve programming productivity on various hardware accelerators.

llama.cpp based on SYCL is used to **support Intel GPU** (Data Center Max series, Flex series, Arc series, Built-in GPU and iGPU).

For detailed info, please refer to [[llama.cpp for SYCL](./backend/SYCL.md)](https://github.com/ggerganov/llama.cpp/blob/master/docs/backend/SYCL.md).

#### Metal Build

On MacOS, Metal is enabled by default. Using Metal makes the computation run on the GPU.

When built with Metal support, you can explicitly disable GPU inference with the `--n-gpu-layers 0` option in the Llama settings.

#### CUDA

Provides GPU acceleration using an NVIDIA GPU. [Refer to the CUDA guide](https://github.com/ggerganov/llama.cpp/blob/master/docs/cuda-fedora.md) for Fedora setup.

#### Vulkan

Vulkan provides GPU acceleration through a modern, low-overhead API. To use Vulkan:

* Ensure Vulkan is installed and supported by your GPU drivers.

Learn more at the [official Vulkan site](https://vulkan.org).

#### Kompute

Kompute offers efficient compute operations for GPU workloads. It's designed for AI inference tasks and works seamlessly with Vulkan.

#### CANN

Provides NPU acceleration using the AI cores of Ascend NPUs. [Learn more about CANN](https://www.hiascend.com/en/software/cann).

#### SYCL

SYCL enables GPU acceleration on Intel GPUs. Refer to the [SYCL documentation](https://github.com/ggerganov/llama.cpp/blob/master/docs/backend/SYCL.md) for setup details.

#### HIP

Supports GPU acceleration on AMD GPUs compatible with HIP.

#### MUSA

Provides GPU acceleration using the MUSA cores of Moore Threads MTT GPUs.

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

