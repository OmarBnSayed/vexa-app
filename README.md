# Vexa Deepfake Detection App

Vexa is a cross-platform video deepfake detection system combining a Flutter frontend and a FastAPI + AI backend.

It uses state-of-the-art models such as Capsule Networks, Xception, and DSP-FWA for high-confidence fake video detection.

---

## 🚀 Features

- 🎥 Upload and preview videos (web & desktop)
- 🧠 Deepfake detection using model fusion
- 📊 Visual result screen with confidence level
- 🔒 BSD-3-Clause licensed (free to use and share)

---

## 🛠️ Tech Stack

| Layer      | Technology             |
|------------|------------------------|
| Frontend   | Flutter (Web/Desktop)  |
| Backend    | FastAPI (Python)       |
| ML Models  | TensorFlow/Keras       |
| Formats    | REST API, JSON         |

---

## 📦 Folder Structure

```text
vexaapp/
├── backend_auth/       # FastAPI auth server
├── upload/             # Model code & inference logic
├── vexa_app/           # Flutter frontend
```

---

## ⚙️ Setup Instructions

### 🔧 Backend (FastAPI)
```bash
cd backend_auth
pip install -r requirements.txt
uvicorn main:app --reload
```

### 💻 Frontend (Flutter)
```bash
cd vexa_app
flutter pub get
flutter run -d chrome
```

---

## 📷 Sample Screenshot

![UI Screenshot](home/ubuntu/upload/WhatsApp%20Image%202025-04-30%20at%2002.13.42.jpeg)

---

## 📄 License

This project is licensed under the **BSD 3-Clause License**.  
See the [`LICENSE`](LICENSE) file for details.
