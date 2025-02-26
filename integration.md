# Supabase Integration for Flutter Chat App

This guide explains how to integrate Supabase with your Flutter chat application for authentication, database storage, and file storage.

## 1. Setup Supabase Project

### Create a new Supabase project
1. Go to [supabase.com](https://supabase.com/) and sign up or log in
2. Create a new project with a name and secure database password
3. Choose a region close to your users
4. Note down your project URL and anon key from the API settings

### Set Up Database Tables

Execute the following SQL in the Supabase SQL Editor:
## TODO:
### DELETE: 
 - supabase database password: ChatApp=102030

```sql
-- Create users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  username TEXT NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create chats table
CREATE TABLE chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create chat members table
CREATE TABLE chat_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_id UUID REFERENCES chats(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(chat_id, user_id)
);

-- Create messages table
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_id UUID REFERENCES chats(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT,
  message_type TEXT NOT NULL CHECK (message_type IN ('text', 'image', 'video', 'file', 'audio')),
  attachment_url TEXT,
  attachment_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_read BOOLEAN DEFAULT FALSE
);
```

### Create Storage Buckets

1. Go to the Storage section in Supabase dashboard
2. Create two buckets:
   - `avatars` - for user profile pictures
   - `attachments` - for message attachments (images, videos, files, audio)
3. Set appropriate permissions (for development, you can start with public)

## 2. Flutter Project Setup

### Add Supabase Dependencies

Update your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Supabase
  supabase_flutter:
  
  # File handling
  file_picker: 
  image_picker: 
  path_provider: 
  uuid: 
  
  # For audio recording
  record: 
  just_audio: 
```

Run `flutter pub get` to install the dependencies.

### Initialize Supabase in main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase - replace with your project URL and anon key
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
    debug: true, // Set to false in production
  );
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

## 3. Authentication Implementation

1. Update the auth service to handle sign-up and sign-in with Supabase
2. Implement UI for login and registration screens
3. Set up routing to direct users to authentication screens when not logged in

## 4. Chat Functionality Implementation

1. Use the Supabase repositories to fetch chats and messages
2. Set up realtime subscriptions for messages
3. Implement message sending (text, images, videos, files, audio)
4. Handle file uploads and storage with Supabase Storage

## 5. Testing the Integration

1. Create test users and verify authentication
2. Test sending different types of messages
3. Verify realtime updates work correctly
4. Test file uploads and attachments

## Troubleshooting

### Common Issues

1. **Authentication Issues**:
   - Verify your Supabase URL and anon key are correct
   - Check if email confirmation is required in your Supabase settings

2. **Database Access Issues**:
   - Verify your Row Level Security (RLS) policies
   - Check if the authenticated user has the necessary permissions

3. **Storage Issues**:
   - Verify storage bucket permissions
   - Check if file paths and URLs are correct

4. **Realtime Updates**:
   - Ensure you're subscribed to the correct channels
   - Check if realtime is enabled for your tables

## Security Considerations

1. Implement appropriate Row Level Security (RLS) policies:
   ```sql
   -- Example RLS for messages
   ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
   
   CREATE POLICY "Users can read messages in chats they belong to" ON messages
   FOR SELECT USING (
     auth.uid() IN (
       SELECT user_id FROM chat_members WHERE chat_id = messages.chat_id
     )
   );
   
   CREATE POLICY "Users can insert messages in chats they belong to" ON messages
   FOR INSERT WITH CHECK (
     auth.uid() IN (
       SELECT user_id FROM chat_members WHERE chat_id = messages.chat_id
     )
   );
   ```

2. Secure storage buckets with appropriate policies
3. Validate file types and sizes on upload
4. Implement client-side encryption for sensitive communications if needed

## Production Checklist

1. Disable debug mode for Supabase
2. Set up proper error handling and recovery mechanisms
3. Implement rate limiting for API calls
4. Set up proper RLS policies for all tables
5. Configure storage bucket permissions appropriately
6. Add monitoring and analytics


# Authentication Implementation Guide

This guide explains how authentication is implemented in the Flutter messenger app using Supabase, Riverpod, and GoRouter.

## Overview

The authentication system in this app uses:

- **Supabase Auth**: For user registration, login, and session management
- **Riverpod**: For state management with generated providers
- **GoRouter**: For route handling and redirects based on auth state

## Key Components

### 1. Auth State Provider

The `authStateProvider` is the central piece of the authentication system. It:

- Listens to authentication state changes
- Provides methods for sign in, sign up, and sign out
- Stores the current user information

```dart
@riverpod
class AuthState extends _$AuthState {
  @override
  AsyncValue<User?> build() {
    // ... implementation
  }
  
  Future<void> signIn({required String email, required String password}) async {
    // ... implementation
  }
  
  Future<void> signUp({required String email, required String password, required String username}) async {
    // ... implementation
  }
  
  Future<void> signOut() async {
    // ... implementation
  }
}
```

### 2. User Profile Provider

The `userProfileProvider` fetches the user's profile data from Supabase:

```dart
@riverpod
Future<Map<String, dynamic>> userProfile(UserProfileRef ref) async {
  // ... implementation
}
```

### 3. Auth-Aware Router

The router automatically redirects users based on their authentication state:

- Unauthenticated users are redirected to login
- Authenticated users are redirected away from auth screens
- Special handling for the splash screen

```dart
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    // ... implementation with redirects
  );
}
```

### 4. Auth Screens

The app includes several authentication-related screens:

- **SplashScreen**: Initial loading screen
- **LoginScreen**: User login form
- **RegisterScreen**: User registration form
- **ProfileScreen**: User profile management

## Auth Flow

1. **App Start**:
   - App shows splash screen
   - Auth state is checked

2. **User Not Authenticated**:
   - Router redirects to login screen
   - User can choose to login or register

3. **User Authenticated**:
   - Router redirects to home (chat list) screen
   - User can access protected routes

4. **Sign Out**:
   - User profile is cleared
   - Router redirects to login screen

## Form Validation

All authentication forms include validation for:

- Email format
- Password length (minimum 6 characters)
- Username length (minimum 3 characters)
- Password confirmation matching

## UI Components

The authentication UI uses reusable components:

- **AuthTextField**: Styled text input for auth forms
- **AuthButton**: Styled button with loading state
- **AuthHeader**: App logo and title for auth screens
- **SocialButton**: Button for social authentication (optional)
- **OrDivider**: Visual separator for auth options

## Avatar Handling

User profile avatars are:

1. Picked from the gallery
2. Uploaded to Supabase storage
3. URL stored in the user's profile

## How to Use

### Sign In

```dart
try {
  await ref.read(authStateProvider.notifier).signIn(
    email: 'user@example.com',
    password: 'password123',
  );
  // Success - router will redirect
} catch (e) {
  // Handle error
}
```

### Sign Up

```dart
try {
  await ref.read(authStateProvider.notifier).signUp(
    email: 'user@example.com',
    password: 'password123',
    username: 'username',
  );
  // Success - router will redirect
} catch (e) {
  // Handle error
}
```

### Sign Out

```dart
try {
  await ref.read(authStateProvider.notifier).signOut();
  // Success - router will redirect
} catch (e) {
  // Handle error
}
```

### Access Current User

```dart
final user = ref.watch(currentUserProvider);
if (user != null) {
  // User is authenticated
  print(user.id);
  print(user.email);
}
```

### Access User Profile

```dart
final userProfileAsync = ref.watch(userProfileProvider);
userProfileAsync.when(
  data: (profile) {
    // Use profile data
    print(profile['username']);
    print(profile['avatar_url']);
  },
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
);
```

## Security Considerations

- Passwords are never stored locally
- Auth tokens are automatically handled by Supabase
- Session persistence is managed securely
- Database access is protected by Row Level Security (RLS) policies

## Future Enhancements

- Social login integration
- Two-factor authentication
- Email verification
- Password recovery flow

# Login Screen MVVM Refactoring

This refactoring transforms the login screen to follow MVVM architecture and clean code principles. Here's what was changed:

## 1. Separation of Concerns

### Before
The original `LoginView` mixed UI, state management, validation, and business logic in a single class.

### After
- **Model**: Data structures in `LoginState`
- **View**: UI-only code in `LoginView`
- **ViewModel**: Business logic in `LoginViewModel`

## 2. Key MVVM Components

### ViewModel (`LoginViewModel`)
- Manages state with immutable `LoginState` class
- Handles business logic (login, password reset)
- Exposes UI-related methods (toggle password visibility)
- Uses Riverpod's code generation for easy provider creation

```dart
@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  LoginState build() {
    // Initialize state
  }
  
  void togglePasswordVisibility() { /* ... */ }
  Future<void> login() { /* ... */ }
  // Other methods...
}
```

### State Management
- Immutable state object using the value object pattern
- All state changes go through the ViewModel
- Clear state transitions with `copyWith` pattern

```dart
class LoginState {
  final bool isLoading;
  final bool isPasswordVisible;
  // Other state properties...
  
  const LoginState({ /* ... */ });
  
  LoginState copyWith({ /* ... */ }) {
    return LoginState( /* ... */ );
  }
}
```

### View (`LoginView`)
- Changed from `ConsumerStatefulWidget` to `ConsumerWidget`
- Focuses solely on rendering UI based on state
- Delegates all logic to the ViewModel
- Extracts reusable UI components

## 3. Code Organization Improvements

### Extracted Validators
- Moved validation logic to a dedicated `Validators` utility class
- Made validators reusable across different screens

### Extracted UI Components
- Refactored dialog into separate `ForgotPasswordDialog` widget
- Improved and enhanced reusable auth widgets

### Extracted Helper Methods
- Created focused methods for specific UI sections
- Improved readability with clear method naming

## 4. Error Handling

- Centralized error handling in the ViewModel
- Added dedicated error state properties
- Created snackbar helper method for consistent error display

## 5. Clean Code Principles Applied

### Single Responsibility Principle
Each class now has a clear, singular responsibility:
- `LoginView`: Rendering UI
- `LoginViewModel`: Business logic and state management
- `Validators`: Form validation rules
- `AuthWidgets`: Reusable UI components

### Dependency Inversion
View depends on abstractions (state and ViewModel interface) rather than concrete implementations.

### Open/Closed Principle
The code is now more extensible without requiring changes to existing components.

## 6. Benefits of the Refactoring

1. **Testability**: Logic is now easily testable in isolation
2. **Maintainability**: Clearer code organization makes future changes easier
3. **Reusability**: Extracted components can be reused throughout the app
4. **Separation of concerns**: UI and logic are properly decoupled
5. **Type safety**: Better typing for state management
6. **State management**: More predictable state transitions

# Register Screen MVVM Refactoring

This refactoring transforms the register screen to follow MVVM architecture and clean code principles. Here's what was changed:

## 1. Key Changes

### Separated the UI from Business Logic
- Transformed `RegisterView` from a `ConsumerStatefulWidget` to a simpler `ConsumerWidget`
- Moved all state management and business logic to a dedicated `RegisterViewModel`
- Created an immutable `RegisterState` class for predictable state transitions

### Utilized Validators Utility
- Reused the same centralized `Validators` utility for form field validation
- Eliminated duplicated validation logic across screens

### Refactored UI Components
- Extracted complex or repeated UI elements into smaller methods
- Used the same reusable auth widgets already created for login

## 2. MVVM Implementation

### Model
The `RegisterState` class holds all UI state:
```dart
class RegisterState {
  final bool isLoading;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final String? errorMessage;
  
  // Constructor and copyWith method...
}
```

### ViewModel
The `RegisterViewModel` handles all business logic:
```dart
@riverpod
class RegisterViewModel extends _$RegisterViewModel {
  // Form controllers and validation logic
  
  @override
  RegisterState build() {
    // Initialize state and manage resources
  }
  
  // UI-related methods
  void togglePasswordVisibility() { ... }
  void toggleConfirmPasswordVisibility() { ... }
  
  // Business logic
  Future<void> register() { ... }
  void resetError() { ... }
}
```

### View
The `RegisterView` is now a stateless widget that:
- Renders UI based on the current state
- Delegates all logic to the ViewModel
- No longer manages any internal state

## 3. Benefits of this Refactoring

### Improved Testability
- Business logic can now be tested independently of UI
- Easy to mock dependencies for unit tests
- UI can be tested with dummy view models

### Better Separation of Concerns
- **View**: Only handles UI rendering 
- **ViewModel**: Contains business logic and state transitions
- **State**: Represents the current UI state immutably

### Enhanced Maintainability
- Clear, predictable state transitions
- No scattered state across a stateful widget
- Centralized error handling
- Reuse of existing validation and UI component code

### Code Consistency
- Registration and login screens now follow the same architectural pattern
- Common validation logic is shared between screens
- Same UI components and error handling approaches

## 4. Specific Improvements

1. **State Management**: State is now managed in an immutable object with a predictable interface
2. **Form Handling**: Form submission logic is cleanly separated from UI
3. **Error Handling**: Error states are properly managed and displayed
4. **Resource Management**: Controllers are properly disposed when no longer needed
5. **Code Organization**: Smaller, more focused methods with clear responsibilities
6. **Reusability**: Shared validators and UI components reduce duplication

This refactoring aligns the register screen with modern architectural best practices while making the code more maintainable and testable.