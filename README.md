# KasiBiz 🛍️📊

**A Flutter and Firebase business management application for small local businesses.**

KasiBiz helps township entrepreneurs, spaza shop owners, salon operators, and other small business owners manage their daily operations in one place.

The application makes it easier to track products, record sales, manage expenses, and monitor business performance.

## Features

### 🔐 User Authentication
- Register an account using email and password.
- Log in securely using Firebase Authentication.
- Log out of your account.
- Access a personalized business dashboard.

### 📦 Products & Services
- Add products and services.
- Store product names, types, and prices.
- View available products and services.
- Save business information using Cloud Firestore.

### 💰 Sales Management
- Record sales for products and services.
- Enter the quantity sold.
- Automatically calculate sale totals.
- Save sales to Cloud Firestore.

### 📜 Sales History
- View previously recorded sales.
- Display product names, quantities, dates, and amounts.
- Calculate total revenue.
- Automatically update when new sales are recorded.

### 🧾 Expense Management
- Record business expenses.
- Categorize expenses, including stock, rent, electricity, and transport.
- Save expense information to Cloud Firestore.

### 📋 Expense History
- View previously recorded expenses.
- Display expense names, categories, dates, and amounts.
- Calculate total business expenses.
- Automatically update when new expenses are recorded.

### 📊 Business Dashboard
- Display total sales.
- Display total expenses.
- Automatically calculate profit.

**Profit = Total Sales − Total Expenses**

The dashboard updates automatically as business transactions are recorded.

## Technologies Used

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Application programming language |
| Firebase Authentication | User registration and login |
| Cloud Firestore | Database for products, sales, and expenses |
| Android Emulator | Android application testing |
| Flutter Test | Automated widget testing |
| Fake Cloud Firestore | Mock database for testing |
| Firebase Auth Mocks | Mock authentication for testing |
| Git & GitHub | Version control and source code hosting |

## Project Structure

```text
kasibiz/
├── android/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   └── pages/
│       ├── logged_in_page.dart
│       ├── login_page.dart
│       ├── register_page.dart
│       ├── products_page.dart
│       ├── record_sale_page.dart
│       ├── record_expense_page.dart
│       ├── sales_history_page.dart
│       └── expense_history_page.dart
├── test/
│   ├── dashboard_page_test.dart
│   ├── record_expense_page_test.dart
│   ├── sales_history_page_test.dart
│   └── expense_history_page_test.dart
├── pubspec.yaml
└── README.md
```

*The project structure highlights the main files. Additional generated files and tests may be present.*

## Getting Started

### Prerequisites

Install the following:

- Flutter SDK
- Dart SDK (included with Flutter)
- Android Studio or VS Code
- Android SDK and an Android emulator
- Firebase CLI and FlutterFire CLI for Firebase configuration

### 1. Clone the repository

```bash
git clone https://github.com/KhensaneM/KasiBiz.git
cd KasiBiz
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Create your own Firebase project in the [Firebase Console](https://console.firebase.google.com/).

Enable:

- Authentication with the Email/Password sign-in method
- Cloud Firestore

Register your Android application with Firebase and configure it using FlutterFire:

```bash
flutterfire configure
```

This generates the Firebase configuration for your environment. Ensure that your Firebase Authentication and Firestore security rules are configured appropriately before using the application with real business data.

### 4. Launch an Android emulator

Check available emulators:

```bash
flutter emulators
```

Launch an emulator, for example:

```bash
flutter emulators --launch Pixel_8
```

Verify that Flutter detects it:

```bash
flutter devices
```

### 5. Run KasiBiz

```bash
flutter run
```

Alternatively, specify the connected Android emulator:

```bash
flutter run -d emulator-5554
```

Use the actual device ID displayed by `flutter devices`.

## Automated Testing

KasiBiz uses automated widget tests to validate its application functionality.

Tests cover functionality such as:

- Dashboard calculations
- Expense recording and validation
- Sales History
- Expense History
- Empty states
- Authentication checks

### Run the tests

```bash
flutter test
```

Latest verified local result:

**46 tests passed successfully.**

### Check code quality

```bash
flutter analyze
```

Latest verified local result:

**No issues found.**

These automated tests use mock Firebase services and do not replace testing against a real Firebase project.

## Screenshots

Android application screenshots will be added here.

Planned screenshots:

- Welcome screen
- Registration and login
- Business dashboard
- Products & Services
- Record Sale
- Sales History
- Record Expense
- Expense History

## Target Users

KasiBiz is designed for small local business owners, including:

- Spaza shop owners
- Township entrepreneurs
- Salon and barbershop operators
- Small retail businesses
- Independent service providers

## Future Improvements

- Monthly sales and expense reports
- Business performance charts
- Product stock tracking
- Downloadable business reports
- Additional dashboard insights

## Developer

Developed as a practical Flutter and Firebase portfolio project.

**GitHub:** [KhensaneM](https://github.com/KhensaneM)

**Repository:** [KasiBiz](https://github.com/KhensaneM/KasiBiz)

---

*Helping small businesses manage their money, understand their performance, and grow with confidence.* ❤️