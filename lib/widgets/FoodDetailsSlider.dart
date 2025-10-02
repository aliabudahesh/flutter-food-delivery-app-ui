import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class FoodDetailsSlider extends StatelessWidget {
  const FoodDetailsSlider({super.key, required this.slideImage1, this.slideImage2, this.slideImage3});

  final String slideImage1;
  final String? slideImage2;
  final String? slideImage3;

  List<Widget> _buildSlides() {
    final List<String> images = <String>[slideImage1];
    if (slideImage2 != null) {
      images.add(slideImage2!);
    }
    if (slideImage3 != null) {
      images.add(slideImage3!);
    }
    return images
        .map((String assetPath) => ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: Image.asset(assetPath, fit: BoxFit.cover, width: double.infinity),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> slides = _buildSlides();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CarouselSlider(
        items: slides,
        options: CarouselOptions(
          height: 220,
          viewportFraction: 1,
          enableInfiniteScroll: slides.length > 1,
          autoPlay: slides.length > 1,
          enlargeCenterPage: false,
        ),
      ),
    );
  }
}
