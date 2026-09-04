import 'package:flutter/material.dart';

/// App-wide route observer, used by views to react to navigation events.
final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();
