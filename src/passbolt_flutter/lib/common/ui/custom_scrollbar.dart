// ©2019-2020 Actonica LLC - All Rights Reserved

// https://github.com/flutter/flutter/issues/36603

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomScrollbar extends StatefulWidget {
  const CustomScrollbar({
    Key key,
    @required this.child,
    this.controller,
  }) : super(key: key);

  final Widget child;

  final ScrollController controller;

  @override
  _ScrollbarState createState() => _ScrollbarState();
}

class _ScrollbarState extends State<CustomScrollbar> with TickerProviderStateMixin {
  ScrollbarPainter _materialPainter;
  TextDirection _textDirection;
  Color _themeColor;
  AnimationController _fadeoutAnimationController;
  Animation<double> _fadeoutOpacityAnimation;
  Timer _fadeoutTimer;

  @override
  void initState() {
    super.initState();
    _fadeoutAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeoutOpacityAnimation = CurvedAnimation(
      parent: _fadeoutAnimationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        _themeColor = theme.highlightColor.withOpacity(0.2);
        _textDirection = Directionality.of(context);
        _materialPainter = _buildMaterialScrollbarPainter();
        break;
    }
  }

  ScrollbarPainter _buildMaterialScrollbarPainter() {
    return ScrollbarPainter(
      color: _themeColor,
      textDirection: _textDirection,
      thickness: 6.0,
      fadeoutOpacityAnimation: _fadeoutOpacityAnimation,
      padding: MediaQuery.of(context).padding,
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final ScrollMetrics metrics = notification.metrics;
    if (metrics.maxScrollExtent <= metrics.minScrollExtent) {
      return false;
    }

    if ((notification is ScrollUpdateNotification || notification is OverscrollNotification)) {
      if (_fadeoutAnimationController.status != AnimationStatus.forward) {
        _fadeoutAnimationController.forward();
      }

      _materialPainter.update(notification.metrics, notification.metrics.axisDirection);
      _fadeoutTimer?.cancel();
      _fadeoutTimer = Timer(Duration(milliseconds: 600), () {
        _fadeoutAnimationController.reverse();
        _fadeoutTimer = null;
      });
    }
    return false;
  }

  @override
  void dispose() {
    _fadeoutAnimationController.dispose();
    _fadeoutTimer?.cancel();
    _materialPainter?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: RepaintBoundary(
        child: CustomPaint(
          foregroundPainter: _materialPainter,
          child: RepaintBoundary(
            child: widget.child,
          ),
        ),
      ),
    );
  }
}