import 'package:flutter/material.dart';
import 'package:flutter_chat/app/theme/colors.dart';
import 'package:flutter_chat/core/utils/extentions/date_extensions.dart';
import 'package:flutter_chat/core/utils/typedef/typedef.dart';
import 'package:flutter_chat/features/chat/data/models/atachment_type.dart';
import 'package:flutter_chat/features/chat/data/models/chat.dart';
import 'package:flutter_chat/features/chat/data/models/message.dart';
import 'package:flutter_chat/features/common/widgets/user_avatar.dart';
import 'package:intl/intl.dart';


class ChatListItem extends StatelessWidget {

  const ChatListItem({
    required this.chat, required this.onTap, required this.onDismissed, super.key,
  });
  final ChatModel chat;
  final VoidCallback onTap;
  final VoidDismissDirection onDismissed;

  @override
  Widget build(BuildContext context) {
    final lastMessage = chat.lastMessage;
    final hasUnread = lastMessage != null && !lastMessage.isMe && !lastMessage.isRead;
    
    // Determine avatar color index based on the first letter of the name
    final colorIndex = chat.user.username.isNotEmpty 
        ? chat.user.username.codeUnitAt(0) % 3
        : 0;
    
    return Dismissible(
      key: Key('chat_${chat.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: onDismissed,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Avatar
              UserAvatar(
                userName: chat.user.username,
                avatarUrl: chat.user.avatarUrl,
                colorIndex: colorIndex,
                size: 48,
              ),
              const SizedBox(width: 12),
              
              // Chat info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          chat.user.username,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        Text(
                          _formatTime(chat.lastMessageTime),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Message preview
                    Row(
                      children: [
                        if (lastMessage?.isMe ?? false)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              'Вы: ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            _getMessagePreview(lastMessage),
                            style: TextStyle(
                              fontSize: 14,
                              color: hasUnread ? Colors.black : Colors.grey.shade600,
                              fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.myMessageBubble,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getMessagePreview(MessageModel? message) {
    if (message == null) {
      return '';
    }
    
    // For text messages
    if (message.text != null && message.text!.isNotEmpty) {
      return message.text!;
    }
    
    // For attachments
    switch (message.attachmentType) {
      case AttachmentType.image:
        return 'Фото';
      case AttachmentType.video:
        return 'Видео';
      case AttachmentType.file:
        return 'Файл';
      case AttachmentType.voice:
        return 'Голосовое сообщение';
      default:
        return '';
    }
  }
  
  String _formatTime(DateTime? time) {
    if (time == null) return '';
    
    final now = DateTime.now();
    
    if (time.isToday()) {
      // Format as time only (e.g., "09:41")
      return DateFormat.Hm().format(time);
    } else if (time.isYesterday()) {
      return 'Вчера';
    } else if (now.difference(time).inDays < 7) {
      // For short time labels we don't need full day name
      return '${time.day}.${time.month.toString().padLeft(2, '0')}';
    } else {
      // Format as date (e.g., "12.01.22")
      return DateFormat('dd.MM.yy').format(time);
    }
  }
}
