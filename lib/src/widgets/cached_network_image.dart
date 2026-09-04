import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

CachedNetworkImage buildCachedNetworkImage(imageUrl,
    {double? height, double? width}) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    placeholder: (context, url) => Image.asset(
      'packages/zartek_core/assets/placeholder.png',
      width: width,
    ),
    errorWidget: (context, url, error) => Image.asset(
      'packages/zartek_core/assets/placeholder.png',
      width: width,
    ),
    fit: BoxFit.cover,
    height: height,
    width: width,
  );
}
