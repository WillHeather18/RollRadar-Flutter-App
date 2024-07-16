// custom_bottom_sheet_route.dart
import 'package:flutter/material.dart';

class CustomBottomSheetRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final double? heightFraction; // Fraction of screen height to cover
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;

  CustomBottomSheetRoute({
    required this.child,
    this.heightFraction = 0.9, // default to 90% of screen height
    this.transitionDuration = const Duration(milliseconds: 500),
    this.reverseTransitionDuration = const Duration(milliseconds: 500),
  }) : super(
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          pageBuilder: (context, animation, secondaryAnimation) {
            final screenHeight = MediaQuery.of(context).size.height;
            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: screenHeight *
                    (heightFraction ?? 0.9), // Adjust height here
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: child,
                ),
              ),
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black54,
        );
}
