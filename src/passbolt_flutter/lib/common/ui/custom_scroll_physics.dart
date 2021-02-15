// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter/cupertino.dart';

class CustomScrollPhysics extends AlwaysScrollableScrollPhysics {
  const CustomScrollPhysics({ScrollPhysics parent})
      : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get maxFlingVelocity => 9000;

  // https://github.com/flutter/flutter/issues/32448
  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity * 1,
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
      );
    }
    return null;
  }
}