# Instagram Clone

A fully functional Instagram clone built using **Flutter**, **Firebase**, **Cloudinary**, and **GetX** for state management.

## Features 🚀
- User Authentication (Sign up, Login, Logout)
- Unique username
- Profile Management
- Post Images & Videos
- Like, Comment, and Share posts
- Follow/Unfollow Users
- Followers/Followings List
- Stories Feature
- Chat System (Direct Messaging)
- Searching using name or username
- Cloud Storage (Cloudinary Integration)
- Dark Mode Support

## Tech Stack 🛠️
- **Frontend:** Flutter (Dart)
- **State Management:** GetX
- **Backend:** Firebase (Firestore, Firebase Auth, Firebase Storage)
- **Image & Video Hosting:** Cloudinary
- **Push Notifications:** Firebase Cloud Messaging (FCM)

## Installation & Setup 🔧
### Prerequisites:
- Flutter SDK installed
- Firebase project setup
- Cloudinary account for media storage

## Tech Stack 📸
---
Homepage, Post Details, Searching, Users
---
![1](https://github.com/user-attachments/assets/098ef0e8-42a6-48bf-a364-ee841cc87c38)
---
Profile, Edit Profile, Connections(Followers, Followings), Other's account
---
![2](https://github.com/user-attachments/assets/0c1cd864-c7d7-4ebe-99e7-a0dbd91e0542)
---
Messenger, Chatting, Posting, Story
--- 
![c3](https://github.com/user-attachments/assets/6d8efcac-d7ad-49b1-bf88-5ec824ebff27)
---



### Steps:
1. **Clone the repository:**
   ```sh
   git clone https://github.com/HuzaifaLatif13/Flutter-App-Development/tree/6089e5cb980ffc68ae5394552f9f0f436646b214/Instagram%20Clone
   cd "Instagram Clone"
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Set up Firebase:**
   - Download `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) from Firebase Console.
   - Place them in respective **android/app/** and **ios/Runner/** directories.

4. **Configure Cloudinary:**
   - Create a `.env` file and add your Cloudinary API keys:
     ```
     CLOUDINARY_CLOUD_NAME=your-cloud-name
     CLOUDINARY_API_KEY=your-api-key
     CLOUDINARY_API_SECRET=your-api-secret
     ```

5. **Run the app:**
   ```sh
   flutter run
   ```

## Contributing 🤝
Pull requests are welcome! If you'd like to contribute, please fork the repository and submit a PR.

## License 📝
This project is licensed under the **MIT License**.

---

**Made by SleepingDragon🐉 using Flutter!**

