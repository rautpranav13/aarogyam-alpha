// flutter_flow_animations.dart — compatibility shim.
// Provides stubs for the FF animation utilities.
// Actual animations are now handled via flutter_animate package directly.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

export 'package:flutter_animate/flutter_animate.dart';

// Stub AnimationInfo — kept for backward-compat with existing code that
// builds an animationsMap. The real animations are no-ops here.
class AnimationInfo {
  AnimationInfo({
    this.trigger,
    this.applyInitialState = true,
    this.effects = const [],
    this.effectsBuilder,
    this.loop = false,
    this.reverse = false,
  });

  final AnimationTrigger? trigger;
  final bool applyInitialState;
  final List<Effect> effects;
  final List<Effect> Function()? effectsBuilder;
  final bool loop;
  final bool reverse;
  AnimationController? controller;
}

enum AnimationTrigger {
  onPageLoad,
  onActionTrigger,
}

typedef AnimationsMap = Map<String, AnimationInfo>;

/// Applies animations from an [AnimationsMap] to a widget.
/// Stub — returns the child unchanged (flutter_animate handles real anims).
Widget applyAnimationSettings(
  AnimationInfo info,
  Widget child, {
  AnimationController? controller,
}) =>
    child;

/// Setup animations — no-op stub.
void setupAnimations(Iterable<AnimationInfo> animations, TickerProvider vsync) {}

/// fixStatusBar — no-op.
void fixStatusBarOniOS16AndBelow(BuildContext context) {}
