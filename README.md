# Realtime Chat App

A modern, full-featured realtime chat application built with Flutter, Supabase, and Clean Architecture.

## Features

- **Authentication**: Secure email/password login and registration using Supabase Auth.
- **Realtime Messaging**: Instant message delivery and updates.
- **Conversation Management**: Create and manage private conversations by email.
- **Offline Support**: Local data persistence using Hive ensures a seamless experience even without an internet connection.
- **State Management**: Robust state management using the BLoC pattern (Flutter Bloc).
- **Clean Architecture**: Scalable and maintainable codebase structured into Data, Domain, and Presentation layers.
- **Dependency Injection**: Modular dependency management with `get_it`.

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: [Dart](https://dart.dev/)
- **Backend**: [Supabase](https://supabase.com/) (Auth, Database, Realtime)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- **Local Database**: [Hive](https://pub.dev/packages/hive) (NoSQL)
- **Dependency Injection**: [get_it](https://pub.dev/packages/get_it)
- **Value Equality**: [equatable](https://pub.dev/packages/equatable)

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine.
- A [Supabase](https://supabase.com/) project set up with the necessary database tables and authentication enabled.

### Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/yourusername/chat_app.git
    cd chat_app
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Run the app:**

    ```bash
    flutter run
    ```

## Project Structure

The project follows the principles of **Clean Architecture**, dividing features into three main layers:

- **Domain**: The inner layer containing business logic (Entities, Usecases, Repository Interfaces). It is independent of external libraries.
- **Data**: The middle layer handling data retrieval and storage (Datasources, Models, Repository Implementations).
- **Presentation**: The outer layer responsible for the UI (Pages, Widgets, BLoCs).

```
lib/
├── core/               # Core utilities, widgets, and configuration
├── features/
│   ├── auth/           # Authentication feature (Login, Register)
│   └── chat/           # Chat feature (Conversations, Messages)
├── main.dart           # Application entry point
```

