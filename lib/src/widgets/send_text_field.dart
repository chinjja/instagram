import 'package:flutter/material.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/utils/utils.dart';

class SendTextField extends StatefulWidget {
  const SendTextField({
    Key? key,
    required this.user,
    required this.hintText,
    required this.sendText,
    required this.onTap,
    this.autoFocus = false,
  }) : super(key: key);
  final User user;
  final bool autoFocus;
  final String hintText;
  final String sendText;
  final void Function(String text) onTap;

  @override
  State<SendTextField> createState() => _SendTextFieldState();
}

class _SendTextFieldState extends State<SendTextField> {
  late final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 150,
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              focusNode: focusNode,
              onChanged: (text) {
                setState(() {});
              },
              autofocus: widget.autoFocus,
              decoration: InputDecoration(
                hintText: widget.hintText,
                contentPadding: const EdgeInsets.only(
                  left: 52,
                  right: 60,
                  top: 4,
                  bottom: 4,
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: networkImage(user.photoUrl),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: TextButton(
              child: Text(widget.sendText),
              onPressed:
                  controller.text.trim().isEmpty ? null : () => _summit(),
            ),
          ),
        ],
      ),
    );
  }

  void _summit() {
    widget.onTap(controller.text.trim());
    controller.clear();
    focusNode.requestFocus();

    setState(() {});
  }
}
