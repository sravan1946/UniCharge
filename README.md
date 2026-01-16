# UniCharge

**UniCharge** is a comprehensive **Smart Parking & EV Charging Management Platform** built with **Flutter**. It streamlines the process of finding, booking, and managing parking spots and EV charging stations.

## 🚀 Key Features

*   **Smart Booking System**: Reserve parking spots and EV charging stations in advance.
*   **Secure QR Verification**:
    *   **User**: Generates a secure, time-limited QR token upon booking.
    *   **Admin**: Built-in QR scanner to verify bookings and activate sessions.
*   **Real-time Map Integration**: Locate stations easily using Google Maps.
*   **Interactive UI**: Smooth animations and transitions using Rive.
*   **Role-Based Access**: distinct flows for Users and Admins.

## 🛠️ Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/) (SDK >=3.0.0 <4.0.0)
*   **State Management**: [Riverpod](https://riverpod.dev/) (w/ Code Generation)
*   **Backend & Auth**: [Firebase](https://firebase.google.com/) (Auth, Firestore)
*   **Maps**: Google Maps Flutter
*   **Scanning**: `qr_flutter` & `mobile_scanner`
*   **Navigation**: `go_router`
*   **Network**: `dio`

## ⚙️ Setup & Installation

Follow these steps to set up the project locally.

### Prerequisites

*   **Flutter SDK**: Ensure you have Flutter installed (`flutter doctor`).
*   **Firebase Project**: You need a Firebase project configured for this app.

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-username/unicharge.git
    cd unicharge
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Environment Configuration**:
    *   Create a `.env` file in the root directory (refer to `env.example` if available).
    *   Add necessary API keys (Google Maps, etc.).

4.  **Run Code Generation**:
    This project uses `freezed` and `riverpod_generator`. Run the builder to generate necessary files:
    ```bash
    dart run build_runner build -d
    ```

5.  **Run the App**:
    ```bash
    flutter run
    ```

## 📱 Admin Access

To access the Admin features (like the QR Scanner):
1.  Navigate to the **Profile** screen.
2.  Go to the **Admin Access** section.
3.  Select **Scan Booking QR Code**.
