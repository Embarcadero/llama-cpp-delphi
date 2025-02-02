# 🚀 SimpleChatWithDownload

Experience the power of local inference! This app runs a Large Language Model (LLM) entirely on your machine, meaning no internet or external API calls are needed for predictions. By leveraging GPU (on Mac) or CPU (on Windows) for computation, you get a secure and self-contained AI experience tailored to your hardware setup. 🎉

**SimpleChatWithDownload** is an exciting sample project from the **llama-cpp-delphi** bindings. This app provides a streamlined way to interact with a local LLM (Large Language Model) in a sleek chat interface, featuring automatic model downloads. Whether you’re using Mac Silicon for blazing-fast GPU inference or Windows for a **SLOW** CPU inference, this sample is a great way to get started! 🎉



https://github.com/user-attachments/assets/16582374-4c12-43bd-aff8-6c4ad4f41339



## 🌟 Features

- **Interactive Chat Window**: Start chatting with your local LLM in seconds!
- **Automatic Model Downloads**: Download models like **Llama-2**, **Llama-3**, and **Mistral Lite** effortlessly. 🚀
  - Models are cloned via Git and downloaded to your system’s default download folder.
- **Platform Support**:
  - 🖥️ **Mac Silicon**: GPU (MPS) and CPU inference supported.
  - 💻 **Windows**: CPU inference only. Feel free to extend it and test CUDA.
  - ⚡ GPU inference is recommended for Mac to avoid slower CPU performance.
- **Pre-Bundled Llama.cpp Libraries**: No extra setup! All required libraries are included in the `lib` folder for easy deployment.
- **Customizable Settings**:
  - Choose your model.
  - Switch between GPU and CPU inference on Mac.
  - Enable/disable seed settings to control response variability.

## 🛠️ Getting Started

### Note

You must have Git installed on your machine to clone model repositories.

### Prerequisites

1. Ensure you have the **llama-cpp-delphi** project ready. If not, grab it from the repository.
2. A **Delphi IDE** installation.
3. For Mac deployment, make sure **PAServer** is running on your Mac.

### Steps to Run

1. **Build llama-cpp-delphi**:
   - Open the llama-cpp-delphi project in Delphi IDE.
   - Build it for **Windows** and **Mac Silicon**.

2. **Open and Build the Sample**:
   - Open the `SimpleChatWithDownload` sample in Delphi IDE.
   - Build it for your target platform:
     - **Mac Silicon**: Recommended for GPU inference.
     - **Windows**: CPU inference only.

3. **Deploy to Mac**:
   - Connect to your Mac using **PAServer**.
   - Deploy the app to your Mac. 🎉

4. **Run the App**:
   - The app will launch with a "Settings" menu where you can:
     - Select your model (Llama-2, Llama-3, Mistral Lite).
     - Choose GPU or CPU inference (Mac only).
     - Enable/disable seed randomness.

### Download and Use Models

- Click the **hamburger menu** to start downloading the selected model.
- Supported Models:
  - **Llama-2**: ~4 GB (7B.Q4_K_M).
  - **Llama-3**: ~5 GB (30B.Q4_K_M).
  - **Mistral Lite**: ~7 GB (7B.Q4_K_M).
  - 🔧 You can also use any GGUF-compatible models with Llama.cpp.
  - 💡 Feel free to test **DeepSeek** locally for additional insights and functionality!

- After the model download is complete, the chat window will activate.

## 💡 Usage Tips

- **Start Chatting**:
  - Type your message in the chat box and press **Enter** or click the **Play** button.
  - Use the **Stop** button to pause responses.

- **Customize Inference**:
  - Mac users: Switch between GPU (fast) and CPU (fallback) modes via the "Settings" menu.
  - Windows users: For better performance, explore CUDA builds in the llama-cpp-delphi "Release" section. 💪

- **Seed Option**:
  - Prevent repetitive responses for the same questions by enabling the seed setting.

## 📁 Libraries

All required libraries are bundled in the `lib` folder of the sample’s root directory:
- **Mac**: Deployment is pre-configured. Deploy via PAServer, and you’re good to go!
- **Windows**: The app automatically loads libraries from the `lib` folder.

For additional builds (e.g., CUDA versions), visit the llama-cpp-delphi "Release" section.

## 🌟 Final Notes

Enjoy chatting with cutting-edge LLMs in your own app! If you run into any issues or have feedback, feel free to contribute or reach out. Happy coding! 🚀

