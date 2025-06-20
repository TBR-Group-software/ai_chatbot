# 🤖 AI Chat Bot

<div align="center">

![AI Chat Bot](assets/images/chat_bot_logo.png)

**A sophisticated, clean-architecture Flutter-based AI chatbot that allows to use any model's API.**

<img src="demo_images/history_gif.gif" alt="HistoryDemo" width="250"/>
<img src="demo_images/memory_gif.gif" alt="MemoryDemo" width="250"/>
<img src="demo_images/memory_gif.gif" alt="TextMessageDemo" width="250"/>
<img src="demo_images/voice_gif.gif" alt="VoiceRecognitionDemo" width="250"/>
</div>

---

## Table of Contents

- [Key Features](#-key-features)
- [Project Structure](#-project-structure)
- [Code Samples](#-code-samples)
- [Built With](#️-built-with)
- [Getting Started](#-getting-started)
- [Testing](#-testing)
- [Contributing](#-contributing)
- [License](#-license)
- [Acknowledgments](#-acknowledgments)

---

## Key Features

- **AI-Powered Conversations**: Leverages the **Google Gemini AI** for intelligent, context-aware responses.
- **Voice-to-Text**: Integrates the `speech_to_text` package to capture the user's voice and convert it to text, enabling hands-free input.
- **Real-time Streaming**: Utilizes **Server-Sent Events (SSE)** to stream responses from the Gemini API, providing a dynamic and interactive user experience as the AI types.
- **Message Editing**: Allows users to long-press their own messages to edit and resend them, triggering a new AI response.
- **Retry Mechanism**: A one-tap retry button appears for any failed AI responses, providing resilience against network errors.
- **Chat History**: Persists chat sessions using **Hive**, a fast and lightweight key-value database, for local storage on the device.
-  **Modern UI**: A sleek, dark-themed interface built with Material You principles.
-  **Clean Architecture**: A robust and maintainable codebase with a clear separation of concerns.
-  **Advanced State Management**: Employs the **BLoC pattern** for predictable and scalable state handling.

---

## Project Structure

```
ai_chat_bot/
├── android/                 # Android platform files
├── assets/                 # Images and assets
├── ios/                     # iOS platform files
├── lib/
│   ├── core/               # Core functionality
│   ├── data/               # Data layer
│   ├── domain/             # Business logic
│   └── presentation/       # UI layer
├── test/                   # Unit tests
├── .env                    # Environment variables
├── pubspec.yaml           # Dependencies
└── README.md              # Introduction
```


### Presentation Layer
- **Responsibility**: Handles all UI and user interaction logic.
- **Components**:
    - **Widgets/Pages**: Flutter widgets that form the screens of the app. They are responsible for rendering the UI based on the current state.
    - **BLoC (Business Logic Component)**: Manages the state of a feature. It listens to events from the UI (e.g., button clicks) and emits new states in response. It communicates with the Domain layer via Use Cases.

### Domain Layer
- **Responsibility**: Contains the core business logic of the application. This layer is completely independent of the UI and data sources.
- **Components**:
    - **Entities**: Business objects that represent the core data structures of the app (e.g., `ChatMessageEntity`).
    - **Repositories (Abstract)**: Defines the contracts (interfaces) for the Data layer to implement. This decouples the domain logic from the specific data source implementations.
    - **Use Cases**: Encapsulates a single, specific business rule. They orchestrate the flow of data between the Presentation and Data layers by using repository contracts.

### Data Layer
- **Responsibility**: Responsible for retrieving data from various sources (e.g., remote API, local database).
- **Components**:
    - **Models**: Data Transfer Objects (DTOs) that are specific to a data source (e.g., `GeminiTextResponse` for the Gemini API). They include logic for serialization/deserialization (`fromJson`/`toJson`).
    - **Data Sources**: The concrete implementation for fetching data (e.g., `GeminiRemoteDataSource`, `HiveStorageLocalDataSource`).
    - **Repositories (Implementation)**: Implements the repository contracts defined in the Domain layer. It decides where to fetch the data from (e.g., remote or local cache).


---

## Code Samples

### Chat Message Entity
```dart
class ChatMessageEntity {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String sessionId;

  const ChatMessageEntity({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.sessionId,
  });
}
```

### Voice Recording State Management
```dart
class VoiceRecordingEntity {
  final bool isRecording;
  final bool isListening;
  final double soundLevel;
  final String recognizedText;
  final Duration recordingDuration;

  factory VoiceRecordingEntity.recording({
    required bool isListening,
    required double soundLevel,
    required String recognizedText,
    required Duration recordingDuration,
  }) {
    return VoiceRecordingEntity(
      isRecording: true,
      isListening: isListening,
      soundLevel: soundLevel,
      recognizedText: recognizedText,
      recordingDuration: recordingDuration,
    );
  }
}
```

### Gemini AI Integration
```dart
Stream<GeminiTextResponse?> streamGenerateContent(String prompt) async* {
  final apiKey = dotenv.env['GEMINI_API_KEY'];
  final modelName = dotenv.env['MODEL_NAME'] ?? 'gemini-2.0-flash';
  
  final url = '$_baseUrl/$_apiVersion/models/$modelName:streamGenerateContent?alt=sse&key=$apiKey';
  
  final requestBody = {
    'contents': [{
      'parts': [{'text': prompt}]
    }],
    'generationConfig': {
      'maxOutputTokens': 2048,
      'temperature': 0.7,
    }
  };

  // Stream real-time responses
  yield* _processStreamResponse(response, client);
}
```

## Built With

- **Framework**: **[Flutter](https://flutter.dev)**
- **Language**: **[Dart](https://dart.dev)**
- **Architecture**: **[Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)**
- **State Management**: **[Flutter BLoC](https://bloclibrary.dev)**
- **Dependency Injection**: **[Get It](https://pub.dev/packages/get_it)**
- **Navigation**: **[Auto Route](https://pub.dev/packages/auto_route)**
- **Local Storage**: **[Hive](https://pub.dev/packages/hive_ce)**
- **API Communication**: **[HTTP](https://pub.dev/packages/http)** (with SSE)
- **AI Integration**: **[Google Gemini AI](https://deepmind.google/technologies/gemini/)**
- **Voice Recognition**: **[Speech to Text](https://pub.dev/packages/speech_to_text)**
- **Code Generation**: **[Build Runner](https://pub.dev/packages/build_runner)**

## Getting Started

### Prerequisites

Before running this project, make sure you have:

- **Flutter SDK** (3.7.2 or higher)
- **Dart SDK** (included with Flutter)
- **Android Studio** / **Xcode** (for mobile development)
- **Google Gemini API Key** (get one from [Google AI Studio](https://makersuite.google.com/app/apikey))

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ai_chat_bot.git
   cd ai_chat_bot
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   
   Create a `.env` file in the root directory:
   ```env
   GEMINI_API_KEY=your_google_gemini_api_key_here
   MODEL_NAME=gemini-2.0-flash
   ```

4. **Generate code (for auto_route and hive)**
   ```bash
   dart run build_runner build
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

### Platform Setup

#### Android
- Minimum SDK: 16
- Target SDK: Latest
- Permissions: Internet, Microphone

#### iOS
- iOS 11.0+
- Permissions: Microphone usage

## Usage

1. **Start a Conversation**: Tap the input field and type your message
2. **Voice Input**: Tap the microphone icon to speak your message
3. **Edit Messages**: Long press on your messages to edit and resend
4. **Retry Failed Messages**: Tap retry button on failed AI responses
5. **View History**: Navigate to history to see past conversations

## Testing

Run the test suite:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```


## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- [Google Gemini AI](https://deepmind.google/technologies/gemini/) for the AI capabilities
- [Flutter Team](https://flutter.dev) for the amazing framework
- [BLoC Library](https://bloclibrary.dev) for excellent state management

---

<div align="center">

**Made with ❤️ and Flutter**

[⬆ Back to top](#-ai-chat-bot)

</div>
