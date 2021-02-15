// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/errors.dart';
import 'package:passbolt_flutter/common/exceptions.dart';
import 'package:pedantic/pedantic.dart';

class UserIntent {
  bool validate() {
    return true;
  }
}

abstract class BlocState {}

class ErrorState extends BlocState {
  final String message;

  ErrorState(this.message);
}

class PendingState extends BlocState {}

abstract class BlocReaction {
  final Object payload;

  BlocReaction([this.payload]);
}

class ErrorReaction extends BlocReaction {
  final String message;

  ErrorReaction(this.message);
}

class UnauthorizedReaction extends BlocReaction {}

abstract class Bloc<T extends BlocState> {
  Stream<BlocState> get states;

  Stream<BlocReaction> get reactions;

  Stream<BlocReaction> get unauthorized;

  void dispose();

  void handle(UserIntent action);
}

class DefaultBloc<T extends BlocState> implements Bloc<T> {
  final _logger = Logger('DefaultBloc');

  @protected
  Map<Type, Function(UserIntent)> actions = {};

  @protected
  BlocState state;

  @protected
  final statesController = StreamController<BlocState>();

  @protected
  final reactionsController = StreamController<BlocReaction>();

  @protected
  final unauthorizedController = StreamController<BlocReaction>();

  @override
  Stream<BlocReaction> get reactions => reactionsController.stream;

  @override
  Stream<BlocState> get states => statesController.stream;

  @override
  Stream<BlocReaction> get unauthorized => unauthorizedController.stream;

  void setReaction(BlocReaction reaction) {
    if (reaction is UnauthorizedReaction) {
      unauthorizedController.sink.add(reaction);
    } else {
      reactionsController.sink.add(reaction);
    }
  }

  void setState(BlocState state) {
    this.state = state;
    statesController.sink.add(state);
  }

  void dispose() {
    statesController.close();
    reactionsController.close();
    unauthorizedController.close();
  }

  @override
  void handle(UserIntent intent) async {
    final action = actions[intent.runtimeType];

    if (action == null) {
      throw AppError('There is no bloc action for this UIAction');
    }

    try {
      intent.validate();
      _logger.fine(
          "******* handle intent $intent, current state is $state*******");
      final result = await action(intent);
      return result;
    } catch (error, stacktrace) {
      unawaited(Crashlytics.instance.recordError(error, stacktrace));
      AppException exception;
      if (error is! AppException) {
        exception = AppException(error.toString());
      } else {
        exception = error;
      }

      _logger.warning(
          '${this.runtimeType} execute exception, message: ${exception.message}');

      if (exception is UnauthorizedException) {
        setReaction(UnauthorizedReaction());
        return;
      }

      setState(ErrorState(exception.message));
    }
  }

  @protected
  String getErrorMessage(error) {
    String errorMessage;

    if (error is AppException) {
      errorMessage = error.message;
    } else {
      errorMessage = error.toString();
    }
    return errorMessage;
  }
}
