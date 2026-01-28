import 'package:chat_app/core/utils/app_logger.dart';
import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:hive/hive.dart';

abstract class ChatLocalDataSource {
  Future<void> cachePending(MessageModel msg);

  List<MessageModel> getPending(String conversationId);

  List<MessageModel> getAllPending();

  Future<void> delete(String id);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final Box box;

  ChatLocalDataSourceImpl(this.box);

  /// 💾 Save message locally when offline
  @override
  Future<void> cachePending(MessageModel msg) async {
    AppLogger.info('ChatLocal: cachePending: ${msg.id}');
    await box.put(msg.id, msg.toMap());
  }

  /// 📥 Pending messages for a specific conversation
  @override
  List<MessageModel> getPending(String conversationId) {
    final pending = box.values
        .map((e) => MessageModel.fromMap(Map<String, dynamic>.from(e)))
        .where(
          (m) =>
              m.conversationId == conversationId &&
              m.status == MessageStatus.pending,
        )
        .toList();
    AppLogger.info(
      'ChatLocal: getPending for $conversationId found ${pending.length}',
    );
    return pending;
  }

  /// 🌍 All pending messages across conversations
  @override
  List<MessageModel> getAllPending() {
    return box.values
        .map((e) => MessageModel.fromMap(Map<String, dynamic>.from(e)))
        .where((m) => m.status == MessageStatus.pending)
        .toList();
  }

  /// 🗑 Remove message after successful upload
  @override
  Future<void> delete(String id) async {
    await box.delete(id);
  }
}
