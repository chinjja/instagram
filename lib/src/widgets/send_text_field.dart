import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/repo/models/model.dart';
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
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        bottom: kIsWeb ? 8 : 0,
      ),
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
              top: 0,
              left: 2,
              right: 6,
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: networkImage(user.photoUrl),
                  ),
                  TextButton(
                    onPressed:
                        controller.text.trim().isEmpty ? null : () => _summit(),
                    child: Text(widget.sendText),
                  ),
                ],
              )),
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
