import 'package:flutter/material.dart';

class ProgressibleButton extends StatelessWidget {
  const ProgressibleButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.showProgress = false,
  }) : super(key: key);
  final bool showProgress;
  final String text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: IndexedStack(
        index: showProgress ? 0 : 1,
        children: const [
          SizedBox(
            height: 20,
            child: Center(
              child: SizedBox(
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Text('다음'),
            ),
          ),
        ],
      ),
      onPressed: onPressed,
    );
  }
}
