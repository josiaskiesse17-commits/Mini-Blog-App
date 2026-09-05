import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) {
        return const Placeholder();
      },
    ),

    GoRoute(
      path: '/signup',
      builder: (context, state) {
        return const Placeholder();
      },
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) {
        return const Placeholder();
      },
    ),

    GoRoute(
      path: '/article/:id',
      builder: (context, state) {
        return const Placeholder();
      },
    ),

    GoRoute(
      path: '/create',
      builder: (context, state) {
        return const Placeholder();
      },
    ),

    GoRoute(
      path: '/edit/:id',
      builder: (context, state) {
        return const Placeholder();
      },
    ),
  ],
);