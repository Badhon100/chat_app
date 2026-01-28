import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:chat_app/features/chat/presentation/bloc/conversation/conversation_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class BlocProviders {
  static final sl = GetIt.instance;

  static final providers = <BlocProvider>[
    BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
    BlocProvider<ChatBloc>(create: (context) => sl<ChatBloc>()),
    BlocProvider<ConversationBloc>(create: (context) => sl<ConversationBloc>()),
  ];
}
