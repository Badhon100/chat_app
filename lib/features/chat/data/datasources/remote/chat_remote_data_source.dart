import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<MessageModel>> listenMessages(String conversationId);
  Future<void> sendMessage(MessageModel message);
  Future<String?> createConversation(String myId, String email);
  Future<void> markDelivered(String messageId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient client;

  ChatRemoteDataSourceImpl(this.client);

  @override
  Stream<List<MessageModel>> listenMessages(String conversationId) {
    AppLogger.info('ChatRemote: listenMessages stream START for $conversationId');
    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map(
          (rows) {
            AppLogger.info('ChatRemote: listenMessages received ${rows.length} rows');
            return rows
                .map<MessageModel>((map) => MessageModel.fromMap(map))
                .toList();
          },
        );
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    AppLogger.info('ChatRemote: sendMessage: ${message.text} (id: ${message.id})');
    try {
      await client.from('messages').insert(message.toMap());
      AppLogger.success('ChatRemote: sendMessage SUCCESS');
    } catch (e) {
      AppLogger.error('ChatRemote: sendMessage ERROR', e);
      rethrow;
    }
  }

  @override
  Future<void> markDelivered(String messageId) async {
    AppLogger.info('ChatRemote: markDelivered: $messageId');
    try {
      await client
          .from('messages')
          .update({'status': 'delivered'})
          .eq('id', messageId);
      AppLogger.success('ChatRemote: markDelivered SUCCESS');
    } catch (e) {
      AppLogger.error('ChatRemote: markDelivered ERROR', e);
    }
  }

  /// Used when starting chat with email
  @override
  Future<String?> createConversation(String myId, String email) async {
    AppLogger.info('ChatRemote: createConversation: $email');
    try {
      final user = await client
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (user == null) {
        AppLogger.error('ChatRemote: createConversation: User not found for $email');
        return null;
      }

      final convo = await client
          .from('conversations')
          .insert({'user1': myId, 'user2': user['id']})
          .select()
          .single();

      AppLogger.success('ChatRemote: createConversation SUCCESS: ${convo['id']}');
      return convo['id'];
    } catch (e) {
      AppLogger.error('ChatRemote: createConversation ERROR', e);
      rethrow;
    }
  }
}
