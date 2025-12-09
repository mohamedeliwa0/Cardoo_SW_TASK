# BLE Monitoring System — Raspberry Pi + NestJS + Flutter

A complete end-to-end system for reading **temperature & humidity** from a Raspberry Pi BLE device, storing readings in a **NestJS + SQLite backend**, and displaying them in a **Flutter mobile app**.

---

## 🏗 System Architecture

```
┌────────────────┐        POST /readings        ┌────────────────────┐
│  Raspberry Pi   │ ──────────────────────────► │   NestJS Backend    │
│  BLE Sensor     │                             │  (SQLite Database)  │
└────────────────┘ ◄─────────────────────────── └────────────────────┘
      ▲                       GET /latest               ▲
      │                                                 │
      └───────────────────── Flutter App ───────────────┘
```

---

## 📌 Features

### Raspberry Pi (Python)
- Reads BLE sensor values (temperature + humidity)
- Sends periodic readings to backend via HTTP POST
- Automatic retries if backend is unreachable

### Backend (NestJS + TypeORM + SQLite)
- REST API to save readings
- REST API to fetch the latest reading
- Local SQLite database storage
- Lightweight and deployable on Raspberry Pi or cloud VM

### Flutter App
- Displays latest reading
- Refresh button
- Auto-fetch every few seconds
- Works on Android & iOS

---

# 📁 Project Structure

```
project/
│
├── backend/                # NestJS backend
│   ├── src/
│   │   ├── readings/       # Entity, controller, service
│   │   ├── app.module.ts
│   │   └── main.ts
│   ├── readings.db         # SQLite database (auto-created)
│   └── package.json
│
├── raspberry/
│   └── ble_sender.py       # Python BLE → API sender
│
└── flutter_app/
    └── lib/
        ├── main.dart
        └── services/api.dart
```

---

# 🖥️ Backend (NestJS)

## ⚙️ Installation

```bash
cd backend
npm install
```

## ▶️ Run the server

```bash
npm run start:dev
```

Server will run at:

```
http://localhost:3000
```

If running on Raspberry Pi or VM, access from same network using:

```
http://<device-ip>:3000
```

---

## 📡 API Endpoints

### 1. POST /readings
Send a new reading.

#### Body:
```json
{
  "temperature": 25.3,
  "humidity": 60.2
}
```

### 2. GET /readings/latest
Fetch the most recent reading.

### 3. GET /readings
Fetch all readings.

---

# 🐍 Raspberry Pi (Python BLE)

The Raspberry Pi script:
- Reads data from BLE device
- Sends it to backend over HTTP
- Optional: runs with systemd service for auto-start

Run it:
```bash
python3 ble_sender.py
```

Set backend URL inside script:
```
API_URL = "http://<your-backend-ip>:3000/readings"
```

---

# 📱 Flutter App

The Flutter app:
- Calls backend APIs
- Displays latest values
- Shows errors if backend is offline

## Install dependencies:
```bash
flutter pub get
```

## Run app:
```bash
flutter run
```

Backend URL is set in:
```
lib/services/api.dart
```

Update it to:
```
http://<your-backend-ip>:3000
```

---

# 🗄 Database

SQLite database file location:
```
backend/readings.db
```

Table structure:
```
reading {
  id           INTEGER PRIMARY KEY
  temperature  FLOAT
  humidity     FLOAT
  createdAt    DATETIME
}
```

---

# 🚀 Deployment Options

### 1. Raspberry Pi
Runs backend + BLE script.

### 2. Cloud VM
Host NestJS backend for mobile access.

### 3. Docker
Possible future enhancement.

---

# 🧪 Testing Endpoints

### Using curl:

```bash
curl http://<server-ip>:3000/readings/latest
```

Send sample data:
```bash
curl -X POST http://<server-ip>:3000/readings \
  -H "Content-Type: application/json" \
  -d '{"temperature": 24.5, "humidity": 58.3}'
```

---

# 📌 TODO (Future Enhancements)

- Authentication (JWT)
- Historical charts in Flutter
- MQTT support
- BLE auto-pairing
- Docker deployment

---

# 👨‍💻 Author

**Mohamed Eliwa**  
Senior Embedded Linux & Software Engineer  
📧 mh1642@fayoum.edu.eg  
📍 October City, Egypt

