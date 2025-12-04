# Fohormalai

Fohormalai is a smart waste management system designed to streamline waste collection, marketplace transactions, and environmental awareness. It consists of three main components: the Flutter-based mobile app, a Django-based backend, and a React TypeScript admin panel.

## Features

### Mobile App
- **Waste Collection Requests**: Schedule pickups with detailed information.
- **Marketplace**: Buy and sell recyclable materials.
- **Authentication**: Secure login and registration with Google Sign-In.
- **Splash Screen**: Animated splash screen with SVG support.
- **Dashboard**: Overview of collection requests and marketplace posts.

### Backend
- **Authentication**: Register, login, and OTP-based verification.
- **Notifications**: View notifications related to waste pickups and other activities.
- **Pickup Schedules**: Manage waste pickup schedules.
- **Collection Requests**: Create and manage waste collection requests.
- **Analytics**: Detailed analytics for waste management operations.

### Admin Panel
- **Dashboard**: Real-time statistics and metrics.
- **Collection Management**: View and update collection requests.
- **Heatmap Visualization**: Location-based clustering for collection demand.
- **Marketplace Monitoring**: Manage marketplace posts.
- **Pickup Schedule Management**: Create and manage pickup schedules.
- **User Management**: Administer user accounts and permissions.
- **Analytics & Reports**: Comprehensive analytics dashboard.
- **Notification System**: Bulk notification management.

## Technologies Used

### Mobile App
- **Flutter**: Cross-platform UI framework.
- **Dart**: Programming language for Flutter.
- **Google Fonts**: Custom typography.
- **Flutter SVG**: SVG image rendering.
- **Geocoding and Geolocator**: Location services.
- **Flutter Map**: Interactive map integration.

### Backend
- **Django**: Backend framework.
- **Django REST Framework**: API development.
- **MongoEngine**: MongoDB integration.
- **JWT Authentication**: Secure user authentication.

### Admin Panel
- **React**: Frontend framework.
- **TypeScript**: Strongly typed JavaScript.
- **Vite**: Build tool.
- **Tailwind CSS**: Styling framework.
- **Axios**: HTTP client.
- **React Router**: Routing library.

## Installation

### Mobile App
1. Clone the repository:
   ```bash
   git clone https://github.com/0-nikesh/fohormalai.git
   ```
2. Navigate to the project directory:
   ```bash
   cd fohormalai
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

### Backend
1. Clone the repository:
   ```bash
   git clone https://github.com/0-nikesh/fohormalai_backend.git
   ```
2. Navigate to the project directory:
   ```bash
   cd fohormalai_backend
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Run the server:
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

### Admin Panel
1. Clone the repository:
   ```bash
   git clone https://github.com/0-nikesh/fohormalai_admin
   cd fohormalai-admin
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start the development server:
   ```bash
   npm run dev
   ```
4. Open your browser and navigate to `http://localhost:5173`

## Folder Structure

```
fohormalai/
├── android/                # Android-specific files
├── assets/                 # Fonts, icons, and images
├── ios/                    # iOS-specific files
├── lib/                    # Main application code
│   ├── app/
|   |   |── models/         # Every Feature Model
|   |   |── providers/      # Providers
|   |   |── services/       # Services
|   |   |── apiendpoints                  
│   ├── features/           # Feature-specific modules
│   │   ├── auth/           # Authentication screens
│   │   ├── collection/     # Waste collection screens
|   |   ├── dashboard/      # Screens
|   |   ├── map/            # Map Integration
│   │   ├── notification/   # Notifications
|   ├── profile/        # User Profile
│   │   ├── splash/         # Splash screen
│   └── main.dart           # Application entry point
├── test/                   # Unit and widget tests
├── web/                    # Web-specific files
├── pubspec.yaml            # Project dependencies
└── README.md               # Project documentation
```

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## Contact

For any inquiries or feedback, please contact:
- **Name**: Nikesh
- **Email**: bhandarinikesh93@gmail.com
- **GitHub**: [0-nikesh](https://github.com/0-nikesh)
