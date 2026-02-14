# 🔥 Flutter Firebase Authentication & Firestore - Week 5

A professional Flutter app with **Firebase Authentication** (Email/Password + Google Sign-In), **Cloud Firestore** database, and a modern light-mode UI.

---

## 📱 Features

### ✅ Week 5 Implementation
- 🔐 **Firebase Authentication**
  - Email & Password sign-up/login
  - Google Sign-In integration
  - Password reset functionality
  - Remember Me / persistent login
  - Secure logout

- ☁️ **Cloud Firestore Database**
  - Real-time user profile storage
  - Task management with CRUD operations
  - Automatic data synchronization
  - Offline persistence

- 🎨 **Professional Light Mode UI**
  - Clean, modern interface
  - Professional color scheme
  - Smooth animations
  - Responsive design
  - Material Design 3

### 🔄 Previous Features (Week 1-4)
- ✅ Form validation
- ✅ Beautiful animations
- ✅ API integration (JSONPlaceholder)
- ✅ JSON parsing
- ✅ Error handling
- ✅ Loading states

---

## 🛠️ Tech Stack

- **Flutter SDK**: 3.38.5
- **Firebase Core**: ^3.8.1
- **Firebase Auth**: ^5.3.3
- **Cloud Firestore**: ^5.5.2
- **Google Sign-In**: ^6.2.2
- **Shared Preferences**: ^2.3.3
- **HTTP**: ^1.1.0

---

## 📂 Updated Project Structure (2026)

```
lib/
├── firebase_options.dart                # Firebase config (auto-generated)
├── main.dart                            # App entry point with Firebase initialization
├── models/
│   ├── app_user.dart                    # Firebase user model
│   ├── user_model.dart                  # API user model (Week 4)
│   └── todo_model.dart                  # Task model with Firestore support
├── screens/
│   ├── login_screen.dart                # Login page with email & Google sign-in
│   ├── signup_screen.dart               # Registration page
│   └── user_profile_page.dart           # Profile & tasks (Firestore-powered)
├── services/
│   ├── api_service.dart                 # API requests (Week 4)
│   ├── firebase_auth_service.dart       # Authentication logic
│   └── firestore_service.dart           # Database operations
└── widgets/
    ├── profile_tab.dart                 # User profile UI (now with permissions dialog)
    └── tasks_tab.dart                   # Task management UI
```

---

## 🚀 How to Run (Web, Port 8080)

> **Important:** Google Sign-In for web is only configured for port 8080. Always use this command to run the app for web:

```bash
flutter run -d chrome --web-port=8080
```

If you use a different port, Google Sign-In will fail with a redirect_uri_mismatch error.

---

## 🎯 Usage Guide

### **First Time Users**
1. Launch the app
2. Click **"Sign Up"**
3. Enter your name, email, and password
4. Or use **"Sign up with Google"**
5. Your profile is automatically created in Firestore

### **Returning Users**
1. Enter your email and password
2. Check **"Remember Me"** for automatic login
3. Or use **"Sign in with Google"**

### **Managing Tasks**
1. Go to the **Tasks** tab
2. Tap the **➕** button to create a task
3. Check/uncheck to mark as complete
4. Swipe left to delete
5. All changes sync to Firestore automatically

### **Profile Management**
1. Go to the **Profile** tab
2. Tap the ✏️ icon to edit your name
3. View your email (read-only)
4. Tap **Logout** to sign out

---

## 🔒 Firestore Security Rules (2026)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Todos collection
    match /todos/{todoId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## 📝 Permissions Disclosure (in-app)
- The app requests:
  - **Internet**: To fetch and sync your data with the cloud.
  - **Storage**: To cache your profile and tasks for faster access.
- These are shown to the user in the profile page under "Privacy & Security".

---

## 🟢 Other Notes
- All authentication and Firestore logic is modularized in the `services/` folder.
- All UI changes and dialogs are handled in the `widgets/` and `screens/` folders.
- For any Google Sign-In issues, always check your port and Google Cloud Console redirect URIs.

---

## 🛠️ Tech Stack

- **Flutter SDK**: 3.38.5
- **Firebase Core**: ^3.8.1
- **Firebase Auth**: ^5.3.3
- **Cloud Firestore**: ^5.5.2
- **Google Sign-In**: ^6.2.2
- **Shared Preferences**: ^2.3.3
- **HTTP**: ^1.1.0

---

## 📂 Project Structure

```
lib/
├── firebase_options.dart                # Firebase config (auto-generated)
├── main.dart                            # App entry point with Firebase initialization
├── models/
│   ├── app_user.dart                    # Firebase user model
│   ├── user_model.dart                  # API user model (Week 4)
│   └── todo_model.dart                  # Task model with Firestore support
├── screens/
│   ├── login_screen.dart                # Login page with email & Google sign-in
│   ├── signup_screen.dart               # Registration page
│   └── user_profile_page.dart           # Profile & tasks (Firestore-powered)
├── services/
│   ├── api_service.dart                 # API requests (Week 4)
│   ├── firebase_auth_service.dart       # Authentication logic
│   └── firestore_service.dart           # Database operations
└── widgets/
    ├── profile_tab.dart                 # User profile UI (now with permissions dialog)
    └── tasks_tab.dart                   # Task management UI
```

---

## 🚀 Firebase Setup Instructions

### **Step 1: Create a Firebase Project**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name (e.g., `flutter-auth-app`)
4. Disable Google Analytics (optional)
5. Click **"Create project"**

---

### **Step 2: Register Your App**

#### **For Android:**

1. In Firebase Console, click **Android icon** (🤖)
2. Enter your package name:
   - Open `android/app/build.gradle`
   - Find `applicationId` (e.g., `com.example.user_profile_screen_flutter`)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`
5. Update `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
6. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   
   android {
       defaultConfig {
           minSdkVersion 21  // Important for Firebase
       }
   }
   ```

#### **For iOS:**

1. In Firebase Console, click **iOS icon** (🍎)
2. Enter your bundle ID:
   - Open `ios/Runner.xcodeproj` in Xcode
   - Find Bundle Identifier
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into the `Runner` folder
6. Ensure it's added to the target

#### **For Web:**

1. In Firebase Console, click **Web icon** (</\>)
2. Register your app
3. Copy the Firebase configuration
4. Open `lib/main.dart` and add configuration:
   ```dart
   await Firebase.initializeApp(
     options: FirebaseOptions(
       apiKey: "YOUR_API_KEY",
       authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
       projectId: "YOUR_PROJECT_ID",
       storageBucket: "YOUR_PROJECT_ID.appspot.com",
       messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
       appId: "YOUR_APP_ID",
     ),
   );
   ```

---

### **Step 3: Enable Authentication Methods**

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. **Enable Email/Password**:
   - Click "Email/Password"
   - Toggle "Enable"
   - Save

3. **Enable Google Sign-In**:
   - Click "Google"
   - Toggle "Enable"
   - Select your support email
   - Save

---

### **Step 4: Configure Google Sign-In**

#### **For Android:**
1. In Firebase Console, go to **Project Settings**
2. Copy **SHA-1** fingerprint from your development machine:
   ```bash
   # For Windows
   keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

   # For Mac/Linux
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
3. Add SHA-1 to Firebase project settings

#### **For iOS:**
1. Add URL scheme to `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```
   (Get `REVERSED_CLIENT_ID` from `GoogleService-Info.plist`)

---

### **Step 5: Create Firestore Database**

1. In Firebase Console, go to **Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
4. Select a location close to your users
5. Click **"Enable"**

---

### **Step 6: Set Firestore Rules** (Important!)

1. Go to **Firestore Database** → **Rules**
2. Replace with these security rules:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users can only read/write their own profile
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Users can only read/write their own tasks
       match /todos/{todoId} {
         allow read, write: if request.auth != null && 
                              resource.data.userId == request.auth.uid;
         allow create: if request.auth != null && 
                         request.resource.data.userId == request.auth.uid;
       }
     }
   }
   ```
3. Click **"Publish"**

---

## 💻 Installation & Running

### **1. Clone the Repository**
```bash
git clone https://github.com/AlizayAhmed/Firebase_Authentication_and_Database
cd Login_Flutter
```

### **2. Install Dependencies**
```bash
flutter pub get
```

### **3. Run the App**
```bash
# For web
flutter run -d chrome

# For Android
flutter run -d android

# For iOS
flutter run -d ios
```

---

## 🎯 Usage Guide

### **First Time Users**
1. Launch the app
2. Click **"Sign Up"**
3. Enter your name, email, and password
4. Or use **"Sign up with Google"**
5. Your profile is automatically created in Firestore

### **Returning Users**
1. Enter your email and password
2. Check **"Remember Me"** for automatic login
3. Or use **"Sign in with Google"**

### **Managing Tasks**
1. Go to the **Tasks** tab
2. Tap the **➕** button to create a task
3. Check/uncheck to mark as complete
4. Swipe left to delete
5. All changes sync to Firestore automatically

### **Profile Management**
1. Go to the **Profile** tab
2. Tap the ✏️ icon to edit your name
3. View your email (read-only)
4. Tap **Logout** to sign out

---

## 🔒 Security Features

- ✅ Passwords are hashed by Firebase Authentication
- ✅ User data is protected by Firestore security rules
- ✅ Each user can only access their own data
- ✅ Google OAuth for secure third-party authentication
- ✅ Automatic session management

---

## 🐛 Troubleshooting

### **"No Firebase App '[DEFAULT]' has been created"**
- Ensure `Firebase.initializeApp()` is called before `runApp()`
- Check that configuration files are in the correct location

### **Google Sign-In not working**
- Verify SHA-1 fingerprint is added to Firebase project
- Check that Google Sign-In is enabled in Firebase Console
- Ensure `google-services.json` is up to date

### **Firestore permission denied**
- Check Firestore security rules
- Ensure user is authenticated before accessing data
- Verify userId matches in rules

### **Build errors on iOS**
- Run `pod install` in the `ios` folder
- Clean build folder: `flutter clean`
- Update CocoaPods: `pod repo update`

---

## 📸 Screenshots

### Login Screen
![Login Screen](screenshots/login.png)

### Sign Up Screen
![Sign Up Screen](screenshots/signup.png)

### Profile Tab
![Profile Tab](screenshots/profile.png)

### Tasks Tab
![Tasks Tab](screenshots/tasks.png)

---

## 📚 Learning Outcomes

### Week 5 (Current)
- ✅ Firebase project setup and configuration
- ✅ Email/Password authentication implementation
- ✅ Google Sign-In integration
- ✅ Cloud Firestore database operations
- ✅ Real-time data synchronization
- ✅ Firestore security rules
- ✅ User session management
- ✅ Professional UI/UX design

### Week 4
- ✅ RESTful API integration
- ✅ JSON parsing and serialization
- ✅ HTTP requests with error handling
- ✅ ListView and dynamic UI

### Week 1-3
- ✅ Flutter basics and widgets
- ✅ Form validation
- ✅ State management
- ✅ Navigation

---

## 🔮 Future Enhancements

- [ ] Profile picture upload to Firebase Storage
- [ ] Email verification
- [ ] Biometric authentication
- [ ] Dark mode toggle
- [ ] Task categories and priorities
- [ ] Due dates and reminders
- [ ] Task sharing between users
- [ ] Search and filter tasks

---

## 📄 License

This project is for educational purposes as part of a Flutter internship program.

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

---

## 📞 Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Review Firebase documentation
3. Open an issue on GitHub

---

**Built with ❤️ using Flutter & Firebase**