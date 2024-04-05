import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final String fraction;
  final int totalStars;
  final double size; // Added parameter for the size of the stars
  final IconData filledStar, halfFilledStar, unfilledStar;

  const StarRating({
    Key? key,
    required this.fraction,
    this.totalStars = 4,
    this.size = 24.0, // Default size is 24.0, can be overridden
    this.filledStar = Icons.star,
    this.halfFilledStar = Icons.star_half,
    this.unfilledStar = Icons.star_border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse the fraction string to calculate the rating
    final parts = fraction.split('/');
    if (parts.length != 2) {
      return SizedBox(); // Return an empty widget if the format is incorrect
    }
    final double numerator = double.tryParse(parts[0]) ?? 0.0;
    final double denominator = double.tryParse(parts[1]) ?? 1.0;
    double.tryParse(parts[1]) ?? 1.0; // Avoid division by zero
    final double rating = (numerator / denominator) * totalStars;

    List<Widget> starList = [];
    for (int i = 0; i < totalStars; i++) {
      Widget starIcon;
      if (i < rating.floor()) {
        starIcon = Icon(filledStar, color: Colors.amber, size: size);
      } else if (i < rating) {
        starIcon = Icon(halfFilledStar, color: Colors.amber, size: size);
      } else {
        starIcon = Icon(unfilledStar, color: Colors.amber, size: size);
      }
      starList.add(starIcon);
    }
    return Row(mainAxisSize: MainAxisSize.min, children: starList);
  }
}
