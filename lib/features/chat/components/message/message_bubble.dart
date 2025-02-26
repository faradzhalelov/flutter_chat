// lib/presentation/chat/components/message_bubble.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat/app/theme/colors.dart';
import 'package:flutter_chat/app/theme/text_styles.dart';
import 'package:flutter_chat/app/theme/theme.dart';
import 'package:flutter_chat/features/chat/data/models/atachment_type.dart';
import 'package:flutter_chat/features/chat/data/models/message.dart';

class MessageBubble extends StatelessWidget {

  const MessageBubble({
    required this.message, 
    super.key,
    this.showTail = true,
  });
  final MessageModel message;
  final bool showTail;

  @override
  Widget build(BuildContext context) {
    final bubbleTheme = AppTheme.messageBubbleTheme;
    final isMe = message.isMe;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 60 : 12,
          right: isMe ? 12 : 60,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? bubbleTheme.myMessageColor : bubbleTheme.otherMessageColor,
          borderRadius: showTail
              ? (isMe ? bubbleTheme.myBorderRadius : bubbleTheme.otherBorderRadius)
              : BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text message
            if (message.text != null && message.text!.isNotEmpty)
              Text(
                message.text!,
                style: AppTextStyles.small.copyWith(
                  color: isMe
                      ? bubbleTheme.myMessageTextColor
                      : bubbleTheme.otherMessageTextColor,
                ),
              ),
            
            // Image attachment
            if (message.attachmentType == AttachmentType.image && 
                message.attachmentPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(message.attachmentPath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                  ),
                ),
              ),
            
            // Time and read status
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(),
                  Text(
                    _formatTime(message.createdAt),
                    style: AppTextStyles.extraSmall.copyWith(
                      color: bubbleTheme.timeTextColor,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.isRead 
                          ? AppColors.messageDelivered 
                          : bubbleTheme.timeTextColor,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) => "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
}
