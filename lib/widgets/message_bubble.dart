import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Align(
        alignment:
            isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUser
                ? Colors.cyan.withOpacity(0.25)
                : Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUser
                  ? Colors.cyanAccent
                  : Colors.white24,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isUser
                        ? Colors.cyanAccent
                        : Colors.black54,
                    child: Icon(
                      isUser
                          ? Icons.person
                          : Icons.smart_toy,
                      size: 16,
                      color: isUser
                          ? Colors.black
                          : Colors.cyanAccent,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    isUser
                        ? "Tú"
                        : "ISAIAS TITAN",
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    "${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}