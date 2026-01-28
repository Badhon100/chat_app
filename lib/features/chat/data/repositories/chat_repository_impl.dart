import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/local/chat_local_data_source.dart';
import '../datasources/remote/chat_remote_data_source.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remote;
  final ChatLocalDataSource local;
  final SupabaseClient client;

  ChatRepositoryImpl({
    required this.remote,
    required this.local,
    required this.client,
  });

  String get _myId => client.auth.currentUser!.id;

  // =========================================================
  // 🎧 REALTIME + LOCAL PENDING MERGED STREAM
  // =========================================================
  @override
  Stream<List<MessageEntity>> listenMessages(String conversationId) async* {
    AppLogger.info('ChatRepo: listenMessages: START for $conversationId');
    // Initial load (one-time fetch) to avoid infinite loading and show messages immediately
    List<MessageModel> initialRemote = [];
    try {
      AppLogger.info(
        'ChatRepo: listenMessages: Fetching initial remote messages...',
      );
      final rows = await client
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at')
          .timeout(const Duration(seconds: 10));

      initialRemote = (rows as List)
          .map((e) => MessageModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      AppLogger.info(
        'ChatRepo: listenMessages: Fetched ${initialRemote.length} remote messages',
      );
    } catch (e) {
      // ignore – on error, we still show local pending
      AppLogger.error('ChatRepo: listenMessages: Initial fetch error', e);
    }

    final initialPending = local.getPending(conversationId);
    AppLogger.info(
      'ChatRepo: listenMessages: Found ${initialPending.length} local pending messages',
    );
    final initialAll = [...initialRemote];
    for (final p in initialPending) {
      final exists = initialAll.any((m) => m.id == p.id);
      if (!exists) initialAll.add(p);
    }
    initialAll.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    AppLogger.info(
      'ChatRepo: listenMessages: Yielding initial list of ${initialAll.length} messages',
    );
    yield initialAll;

    // Live updates
    AppLogger.info('ChatRepo: listenMessages: Subscribing to live updates...');
    yield* remote.listenMessages(conversationId).map((remoteMessages) {
      AppLogger.info(
        'ChatRepo: listenMessages: Live update received ${remoteMessages.length} messages',
      );
      final pendingLocal = local.getPending(conversationId);
      final all = [...remoteMessages];
      for (final pending in pendingLocal) {
        final exists = all.any((m) => m.id == pending.id);
        if (!exists) all.add(pending);
      }
      all.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      AppLogger.info(
        'ChatRepo: listenMessages: Yielding updated list of ${all.length} messages',
      );
      return all;
    });
  }

  // =========================================================
  // 📤 SEND MESSAGE (ONLINE OR OFFLINE)
  // =========================================================
  @override
  Future<void> sendMessage(MessageEntity entity) async {
    final model = MessageModel.fromEntity(entity);

    try {
      await remote.sendMessage(model.copyWith(status: MessageStatus.sent));
      await local.delete(model.id);
    } catch (_) {
      await local.cachePending(model.copyWith(status: MessageStatus.pending));
    }
  }

  // =========================================================
  // 🔁 RETRY ALL PENDING MESSAGES
  // =========================================================
  @override
  Future<void> retryPending() async {
    final pendingMessages = local.getAllPending();

    for (final msg in pendingMessages) {
      try {
        await remote.sendMessage(msg.copyWith(status: MessageStatus.sent));
        await local.delete(msg.id);
      } catch (_) {
        // still offline → keep stored
      }
    }
  }

  @override
  Future<void> markDelivered(String messageId) async {
    await remote.markDelivered(messageId);
  }

  // =========================================================
  // 💬 LOAD CHAT HISTORY (CONVERSATION LIST)
  // =========================================================
  @override
  Future<List<Conversation>> getConversations() async {
    AppLogger.info('ChatRepo: getConversations: Fetching conversation list...');
    try {
      final res = await client
          .from('conversations')
          .select('id, user1, user2')
          .or('user1.eq.$_myId,user2.eq.$_myId');

      final List data = res as List;
      AppLogger.info(
        'ChatRepo: getConversations: Found ${data.length} raw conversations',
      );

      List<Conversation> conversations = [];

      for (final c in data) {
        final otherUserId = c['user1'] == _myId ? c['user2'] : c['user1'];

        final profile = await client
            .from('profiles')
            .select('email')
            .eq('id', otherUserId)
            .single();

        conversations.add(
          Conversation(id: c['id'], otherUserEmail: profile['email']),
        );
      }

      AppLogger.success(
        'ChatRepo: getConversations: Successfully loaded ${conversations.length} conversations',
      );
      return conversations;
    } catch (e) {
      AppLogger.error('ChatRepo: getConversations: ERROR', e);
      rethrow;
    }
  }

  // =========================================================
  // 👤 START CHAT WITH EMAIL
  // =========================================================
  @override
  Future<String?> createConversationByEmail(String email) async {
    AppLogger.info('ChatRepo: createConversationByEmail: $email');
    try {
      final user = await client
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (user == null) {
        AppLogger.info(
          'ChatRepo: createConversationByEmail: User not found for $email',
        );
        return null;
      }

      final otherId = user['id'];

      // Check existing conversation
      final existing = await client
          .from('conversations')
          .select('id')
          .or(
            'and(user1.eq.$_myId,user2.eq.$otherId),and(user1.eq.$otherId,user2.eq.$_myId)',
          )
          .maybeSingle();

      if (existing != null) {
        AppLogger.info(
          'ChatRepo: createConversationByEmail: Existing conversation found: ${existing['id']}',
        );
        return existing['id'];
      }

      // Ensure my profile exists (backfill just in case)
      await client.from('profiles').upsert({'id': _myId}).select();

      // Create new
      final created = await client
          .from('conversations')
          .insert({'user1': _myId, 'user2': otherId})
          .select('id')
          .single();

      AppLogger.success(
        'ChatRepo: createConversationByEmail: Created new conversation: ${created['id']}',
      );
      return created['id'];
    } catch (e) {
      AppLogger.error('ChatRepo: createConversationByEmail: ERROR', e);
      throw Exception('Failed to start chat: $e');
    }
  }
}
