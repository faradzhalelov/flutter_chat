import 'package:flutter/material.dart';
import 'package:flutter_chat/app/theme/colors.dart';
import 'package:flutter_chat/app/theme/icons.dart';
import 'package:flutter_chat/app/theme/text_styles.dart';
import 'package:flutter_chat/core/utils/extentions/date_extensions.dart';
import 'package:flutter_chat/core/utils/typedef/typedef.dart';
import 'package:flutter_chat/features/chat/data/models/atachment_type.dart';
import 'package:flutter_chat/features/chat_list/data/models/chat.dart';
import 'package:flutter_chat/features/common/widgets/user_avatar.dart';
import 'package:intl/intl.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    required this.chat,
    required this.onTap,
    required this.onDismissed,
    super.key,
  });
  final ChatModel chat;
  final VoidCallback onTap;
  final VoidDismissDirection onDismissed;

  @override
  Widget build(BuildContext context) {
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
          Icomoon.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: onDismissed,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  // Avatar
                  UserAvatar(
                    userName: chat.user.username,
                    avatarUrl: chat.user.avatarUrl,
                    colorIndex: colorIndex,
                    size: 50,
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
                              style: AppTextStyles.medium.copyWith(
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              _formatTime(chat.lastMessageAt),
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.darkGray,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Message preview
                        Row(
                          children: [
                            if (chat.lastMessageIsMe ?? false)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  'Вы: ',
                                  style: AppTextStyles.extraSmall
                                      .copyWith(color: AppColors.black),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                _getMessagePreview(
                                    chat.lastMessageType, chat.lastMessageText),
                                style: AppTextStyles.extraSmall
                                    .copyWith(color: AppColors.darkGray),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }

  String _getMessagePreview(MessageType? messageType, String? text) {
    if (messageType == null) {
      return '';
    }
    // For attachments
    switch (messageType) {
      case MessageType.image:
        return 'Фото';
      case MessageType.video:
        return 'Видео';
      case MessageType.file:
        return 'Файл';
      case MessageType.audio:
        return 'Голосовое сообщение';
      case MessageType.text:
        return text ?? '';
     
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now().toUtc();
    final difference = time.difference(now);
    // For very recent times (less than 1 hour ago)
    if (difference.inHours < 1) {
      final minutes = difference.inMinutes;

      if (minutes < 1) {
        return 'Только что';
      } else {
        return '$minutes ${_minutesDeclension(minutes)} назад';
      }
    }
    // For today
    else if (time.isToday()) {
      // Format as time only (e.g., "09:41")
      return DateFormat.Hm().format(time);
    }
    // For yesterday
    else if (time.isYesterday()) {
      return 'Вчера';
    }
    // For this week (less than 7 days ago)
    else if (difference.inDays < 7) {
      // For short time labels we don't need full day name
      return '${time.day}.${time.month.toString().padLeft(2, '0')}';
    }
    // For older dates
    else {
      // Format as date (e.g., "12.01.22")
      return DateFormat('dd.MM.yy').format(time);
    }
  }

// Helper function for proper Russian declension of minutes
  String _minutesDeclension(int minutes) {
    // Handle exceptions for numbers ending with 11-14
    if (minutes % 100 >= 11 && minutes % 100 <= 14) {
      return 'минут';
    }

    // Handle other cases based on last digit
    switch (minutes % 10) {
      case 1:
        return 'минута';
      case 2:
      case 3:
      case 4:
        return 'минуты';
      default:
        return 'минут';
    }
  }
}
