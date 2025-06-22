# 🏫 Campus Sync

**Campus Sync** is an all-in-one platform designed to streamline campus communication, event management and coordination. From personalized event updates and club notifications to seamless merchandise purchases and smarter scheduling, the app keeps both students and organizers **in sync**.

---

## 📑 Table of Contents

- [Features](#-features)  
- [Tech Stack](#-tech-stack)  
- [Setup Instructions](#-setup-instructions)  
- [Methodology](#-methodology)  
- [Future Goals](#-future-goals)  
- [Figma Designs](#-figma-designs)  
- [Why Campus Sync?](#-why-campus-sync)  
- [Contact](#contact)  

---

## 🚀 Features

### 🔔 Real-Time Notifications  
* **Firebase Cloud Messaging (FCM)** + **BullMQ** (Redis-backed)  
* Real-time and scheduled delivery  
* Job retries, exponential back-off, parallel workers  

### 🧠 Smart Event Coordination  
* Events can be **Draft → Tentative → Published**  
* Timeline shows overlapping / nearby events  
* Multi-organizer collaboration  

### 🧑‍🎓 Club Following & Personalization  
* Follow clubs by category (Coding, Finance, Blockchain …)  
* Personalized contest alerts via **Codeforces API**  

### 🛍️ Payments & Merchandise  
* **Razorpay** for UPI payments  
* In-app club merchandise store  
* OneDrive file storage and Outlook 2.0 calendar sync  

### 🔐 Role-Based Access Control (RBAC)  
* Roles for **Students**, **Organizers**, **Admins**  
* Fine-grained permission & resource access  

---

## 🧑‍💻 Tech Stack

| Layer            | Technology                        |
|------------------|-----------------------------------|
| **Frontend**     | Flutter (Android + iOS)           |
| **Backend**      | Node.js + Express.js              |
| **Database**     | Firebase + Redis                  |
| **Notifications**| FCM + BullMQ                      |
| **Design**       | Figma (UI/UX prototyping)         |
| **Storage & Auth**| OneDrive API, Razorpay, Outlook 2.0 |
| **External APIs**| Codeforces API                    |

---

## 🛠️ Setup Instructions

### 🔧 Backend (Node.js + Express)

1. `cd server`
2. Add a `.env` file with the required credentials.  
3. Start the server: node index.js

---

### 📱 Frontend (Flutter)

1. `cd frontend`  
2. *(optional)* clean the build: flutter clean
3. Run:
Option 1: Using VS Code
Press Ctrl + Shift + D to go to the Run and Debug tab.

If not created already, click "create a launch.json file".

Add the following inside launch.json:

json
Copy
Edit
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=CLIENT_ID=$your-client-id",
        "--dart-define=AZURE_TENANT_ID=$your-tenant-id",
        "--dart-define=serverUrl=https://iitgcampussync.onrender.com"
      ]
    }
  ]
}


Option 2: Using Android Studio
Go to Edit Configuration

Add the same --dart-define parameters under Additional run args

Option 3: Using Terminal
bash
Copy
Edit
flutter run \
  --dart-define=CLIENT_ID=$your-client-id \
  --dart-define=AZURE_TENANT_ID=$your-tenant-id \
  --dart-define=serverUrl=https://iitgcampussync.onrender.com

---

## 📐 Methodology

* Modular full-stack architecture  
* Decoupled notification layer (BullMQ)  
* Firebase for realtime DB + auth  
* **UI/UX-first**: responsive layouts prototyped in Figma  

---

## 🎯 Future Goals

* 🔒 **Class Rep Access** — manage dept-level events  
* 🧠 **LeetCode Contest Alerts** — extend contest integration  
* 🛒 **Club Storefronts** — list and pre-sell merchandise  

---

## ✨ Figma Designs

> All UI mock-ups, prototypes and event-card designs were created in Figma.

![Figma Mockups](link-to-figma-or-screenshot)

---

## 💡 Why Campus Sync?

📬 Email is cluttered   📱 Social media is noisy   📉 Students miss events  

**Campus Sync** fixes this by  
* delivering timely updates,  
* avoiding scheduling clashes, and  
* making planning smoother for organizers.  

> Whether you’re exploring clubs or planning your next big event — **Campus Sync keeps everyone in sync.**

---

## Contact
This Application is maintained by CODING CLUB OF IIT GUWAHATI
For collaboration, feedback, or suggestions:

- 📧 **Email:** *codingclub@iitg.ac.in*  
  
