import 'package:edge_detection/sobel_edge_detector/views/edge_detection.dart';
import 'package:edge_detection/sobel_edge_detector/views/view_image.dart';
import 'package:edge_detection/sobel_edge_detector/views/view_images.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        // home router
        path: '/',
        name: 'home',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const MaterialPage<void>(
          child: EdgeDetector(),
        ),
      ),
      GoRoute(
        // view images route
        path: '/viewImages',
        name: 'viewImages',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const MaterialPage<void>(
          child: ViewImages(),
        ),
        // sub routes
        routes: [
          GoRoute(
            path: ':name',
            name: 'viewImage',
            pageBuilder: (BuildContext context, GoRouterState state) =>
                MaterialPage<void>(
              child: ViewImage(
                name: state.params['name']!,
                path: state.queryParams['path']!,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
