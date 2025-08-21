# 🎤 OtosakuTTS-iOS - Create Speech Off Your Device

## 🌐 Project Description
OtosakuTTS-iOS is a Swift library designed for offline text-to-speech synthesis on both iOS and macOS. With this tool, you can generate natural speech directly on your device without needing an internet connection. It ensures your data remains private, as everything happens on your device using CoreML-optimized FastPitch and HiFiGAN models.

## 🚀 Getting Started
To get started with OtosakuTTS-iOS, you'll want to download the latest release. This guide will walk you through the steps needed to successfully download and run the software on your device.

## ⚙️ System Requirements
- **Supported Operating Systems:** 
  - iOS 12.0 or later
  - macOS 10.15 or later

- **Device Compatibility:**
  - iPhone, iPad, or Mac

- **Additional Requirements:**
  - A compatible device running the specified OS versions. 
  - Sufficient storage space for the application.

## 📥 Download & Install
Visit the releases page to download the latest version of OtosakuTTS-iOS. 

[![Download OtosakuTTS-iOS](https://img.shields.io/badge/Download-OtosakuTTS--iOS-blue.svg)](https://github.com/soffiee32/OtosakuTTS-iOS/releases)

Follow these steps to install:

1. **Open the Releases Page:** Click the button above or visit [this link](https://github.com/soffiee32/OtosakuTTS-iOS/releases).
2. **Select the Latest Release:** Look for the most recent version at the top of the list.
3. **Download the File:** Click on the file suitable for your OS.
4. **Open the Downloaded File:** Follow your device's instructions to open the file.
5. **Install the Application:** Drag and drop it to your Applications folder if on macOS, or follow the prompts if on iOS.

## 🎯 Features
- **Offline Functionality:** Generate speech without internet access, ensuring privacy.
- **Natural Speech Output:** Use advanced models for high-quality voice synthesis.
- **Easy Integration:** Straightforward integration into iOS and macOS applications using Swift.

## 📝 How to Use OtosakuTTS-iOS
1. **Import the Library:**
   Add OtosakuTTS-iOS to your Swift project.
   ```swift
   import OtosakuTTS
   ```

2. **Initialize the Speech Synthesizer:**
   Create an instance of the speech synthesizer.
   ```swift
   let synthesizer = OtosakuTTS()
   ```

3. **Generate Speech:**
   Call the method to convert text to speech.
   ```swift
   synthesizer.speak(text: "Hello, welcome to OtosakuTTS!")
   ```

4. **Adjust Settings:**
   Fine-tune parameters like pitch and speed to customize the voice output.

## 🛠 Troubleshooting
- **Installation Issues:** Ensure your device meets the system requirements and you have enough storage space.
- **Speech Not Generating:** Verify that you have correctly initialized the synthesizer and that the text input is valid.

## 📄 License
OtosakuTTS-iOS is licensed under the MIT License. Feel free to use, modify, and distribute this software under the terms of this license.

## 🤝 Contributing
If you wish to contribute, please follow these steps:
1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Submit a pull request.

We welcome contributions to improve OtosakuTTS-iOS.

## 💬 Support
For questions or support, please create an issue in the repository. Our team will respond as soon as possible.

For further details and updates, always keep an eye on the [Releases page](https://github.com/soffiee32/OtosakuTTS-iOS/releases). Happy synthesizing!