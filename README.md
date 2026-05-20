```markdown
# AI Code Check (ACC) 🧠💻

AI Code Check (ACC) is a modern, cross-platform Flutter application that analyzes source code snippets and estimates whether they are likely AI-generated or human-written using an ensemble of Large Language Models (LLMs). 

The application combines the outputs of Google Gemini and Groq-powered models to produce a more reliable prediction, confidence score, and explanation.

---

## ✨ Features

| Feature | Description |
| :--- | :--- |
| 🤖 **AI Code Detection** | Detects AI-generated code using Gemini + Groq APIs. |
| 🧠 **Ensemble Analysis** | Combines multiple model outputs for improved reliability. |
| 📊 **Probability Visualization** | Interactive gauge chart and model comparison. |
| 🔐 **Authentication** | Email/password authentication with local persistence. |
| 🕓 **Analysis History** | Stores previous analyses offline using Hive. |
| 🌙 **Theme Support** | Light / Dark / System theme modes. |
| 📱 **Responsive UI** | Optimized for mobile, tablet, desktop, and web. |
| ⚡ **Real-Time Feedback** | Loading states, animations, snackbars, and error handling. |
| 🛡️ **Robust Error Handling** | Handles rate limits, network issues, invalid responses, and API failures gracefully. |
| 💾 **Persistent Storage** | `SharedPreferences` + `Hive` local storage. |
| 🔄 **Smart Fallback Logic** | If one AI model fails, the other still provides analysis. |

---

## 📸 Application Overview

The core application workflow moves sequentially through the following layers:

```text
User enters code
       ↓
   Flutter UI
       ↓
Riverpod State Management
       ↓
 AnalysisService
       ↓
Gemini API + Groq API
       ↓
Response Processing
       ↓
 Ensemble Scoring
       ↓
Visualization + History Saving

```

---

## 🏗️ Architecture

The project follows a clean, feature-based architecture optimized for scalability and maintainability.

```text
lib/
├── core/
│   ├── constants/
│   ├── network/
│   ├── providers/
│   ├── theme/
│   └── utils/
│
├── features/
│   ├── auth/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── services/
│   │
│   ├── code_check/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   │
│   ├── history/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── services/
│   │
│   └── settings/
│       ├── providers/
│       └── screens/
│
├── shared/
│   └── widgets/
│
└── main.dart

```

---

## 🧠 AI Detection System

ACC utilizes a multi-model ensemble approach to balance individual model biases:

| Model | Role |
| --- | --- |
| **Gemini** | Primary LLM analysis |
| **Groq** | Secondary validation model |

### The System Process:

1. Sends the identical code snippet to both APIs simultaneously.
2. Extracts individual probability percentages and qualitative explanations.
3. Combines results into an ensemble prediction.
4. Calculates final confidence based on model agreement levels.

### 📊 Ensemble Scoring Logic

The final confidence level depends on how closely the two models agree.

| Agreement Level | Confidence |
| --- | --- |
| Small difference | **High** |
| Moderate difference | **Medium** |
| Large disagreement | **Low** |

> **Example:**
> * Gemini → `82%`
> * Groq → `79%`
> * **Final Output:** High Confidence AI-generated
> 
> 

---

## ⚙️ Technologies Used

### Frontend & Core

* **Flutter** & **Dart** - Cross-platform framework and language.
* **Material 3** - Modern UI components and design systems.

### State Management & Networking

* **Flutter Riverpod** - Reactive state management.
* **Dio** - Powerful HTTP client for Dart with interceptor support.

### Local Storage

* **Hive** - Lightweight and blazing-fast key-value database written in pure Dart.
* **SharedPreferences** - Platform-specific persistent storage for simple data.

### Third-Party APIs & Utilities

* **Google Gemini API**
* **Groq API**
* **fl_chart** - For custom interactive charts and probability visualization.
* **flutter_dotenv** - For managing environment variables.
* **uuid** - For unique ID generation.

---

## 🔄 State Management & Storage Strategy

### Riverpod Providers

* `authProvider`: Manages user session and authentication state.
* `analysisProvider`: Coordinates async tasks for AI code checking.
* `historyProvider`: Manages local analysis records.
* `settingsProvider`: Controls user preferences like global theme modes.

### 💾 Local Persistence

* **SharedPreferences:** Best used for simple, lightweight preferences like theme settings and authentication token persistence.
* **Hive:** Best used for storing structured data locally. It powers our offline-first analysis history log for fast read/write times.

---

## 🌐 API Integration & Networking Flow

The app communicates smoothly with external AI services using Dio:

```text
Flutter UI ➔ Riverpod Provider ➔ Analysis Service ➔ Dio HTTP Client ➔ Gemini / Groq APIs
                                                                             │
Flutter UI 🎨 Model Conversion 🎨 JSON Response Parsing 💡───────────────────┘

```

### 🛡️ Error Handling

The application safely intercepts and handles failures gracefully without crashing:

* API rate limits (`429 Too Many Requests`)
* Network timeouts & loss of internet connection
* Invalid JSON payloads or malformed API responses
* Partial service failures (Smart fallback handles if only one model drops)

---

## 📱 Responsive Design

The interface natively scales across **Mobile**, **Tablet**, **Desktop**, and **Web** deployment targets using:

* Dynamic responsive padding values.
* Explicit width constraints for wider screen layouts.
* Adaptive layouts and grid structures.
* Theme-aware components that seamlessly transition between light, dark, and system modes.

---

## 🚀 Setup & Installation

### 1️⃣ Clone the Repository

```bash
git clone [https://github.com/your-username/ai-code-check.git](https://github.com/your-username/ai-code-check.git)
cd ai-code-check

```

### 2️⃣ Install Dependencies

```bash
flutter pub get

```

### 3️⃣ Create Environment File

Create a `.env` file in the project's root directory:

```env
GEMINI_API_KEY=your_gemini_key_here
GROQ_API_KEY=your_groq_key_here

```

### 4️⃣ Run the Application

* **Mobile / Desktop:**
```bash
flutter run

```


* **Web (with static port binding):**
```bash
flutter run -d chrome 

```



## 📦 Main Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1  # Or current stable version
  dio: ^5.4.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.3
  flutter_dotenv: ^5.1.0
  fl_chart: ^0.66.0
  uuid: ^4.3.3

```

---

## 🧪 Example Detection Flow

1. User pastes a snippet of code into the text input area.
2. The application passes the prompt to both Gemini and Groq concurrently.
3. Each individual API returns its respective probability score and markdown text response.
4. Raw data payloads are parsed into structured models.
5. The system calculates an ensemble agreement score.
6. The UI renders the analytical output:
* **Final Verdict** (Human vs. AI)
* **Confidence Status** (High / Medium / Low)
* **Interactive Gauge Charts**
* **Individual Model Explanations**


7. The complete report is automatically indexed into the local Hive cache.

---

