import 'package:flutter/material.dart';

/// Push a full-screen page onto the navigator. Detail screens use this; tab
/// roots live in the [IndexedStack] inside RootShell.
Future<T?> pushPage<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute<T>(builder: (_) => page),
  );
}

/// Replace the whole stack with [page] (used after a successful payment so the
/// user cannot "back" into the half-finished checkout).
Future<T?> pushReplacementPage<T>(BuildContext context, Widget page) {
  return Navigator.of(context).pushReplacement<T, dynamic>(
    MaterialPageRoute<T>(builder: (_) => page),
  );
}

/// Push [page] and drop every route above the root shell. Used after checkout:
/// the user lands on the active ticket and Back returns straight to Home.
Future<T?> pushAndReset<T>(BuildContext context, Widget page) {
  return Navigator.of(context).pushAndRemoveUntil<T>(
    MaterialPageRoute<T>(builder: (_) => page),
    (Route<dynamic> route) => route.isFirst,
  );
}

void showToast(BuildContext context, String message, {IconData? icon}) {
  final ScaffoldMessengerState m = ScaffoldMessenger.of(context);
  m
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 2200),
        content: Row(
          children: <Widget>[
            Icon(icon ?? Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
