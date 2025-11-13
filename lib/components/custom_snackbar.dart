import 'dart:async';

import 'package:flutter/material.dart';
extension<T> on Future<T> {
  /// Returns a [Completer] that allows checking for this [Future]'s completion.
  ///
  /// See https://stackoverflow.com/a/69731240/6696558.
  Completer<T> wrapInCompleter() {
    final completer = Completer<T>();
    then(completer.complete).catchError(completer.completeError);
    return completer;
  }
}

void successSnackbar({required String text,required BuildContext context}){
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  scaffoldMessenger
      .showSnackBar( SnackBar(
    backgroundColor: const Color(0xFFedf7ed),
    content: Row(
      children: [
        const Icon(
          Icons.check,
          color: Color(0xFF408844),
        ),
        const SizedBox(width: 8),
        Text(text,style: const TextStyle(color: Color(0xFF375b39),fontWeight: FontWeight.bold),),
      ],
    ),
  ))
      .closed
      .wrapInCompleter();
}

void failSnackbar({required String text,required BuildContext context}){
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  scaffoldMessenger
      .showSnackBar( SnackBar(
    backgroundColor: const Color(0xFFfdeded),
    content: Row(
      children: [
        const Icon(
          Icons.error_outline,
          color: Color(0xFFd74141),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF723a39),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ))
      .closed
      .wrapInCompleter();
}