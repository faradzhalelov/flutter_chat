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
  is_online boolean DEFAULT false
);

-- Create chats table
CREATE TABLE chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_message_text TEXT,
  last_message_type TEXT NOT NULL CHECK (last_message_type IN ('text', 'image', 'video', 'file', 'audio')),
  last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
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
2. Create buckets for message attachments (images, videos, files, audio)
3. Set appropriate permissions (for development, you can start with public)

## 2. Flutter Project Setup

### Add Supabase Dependencies

e.g.
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

