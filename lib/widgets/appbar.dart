import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;
  final bool showDrawer;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    Key? key,
    this.title,
    this.onBack,
    this.onSettings,
    this.showDrawer = false,
    this.bottom,
  }) : super(key: key);

  @override
  Size get preferredSize {
    return Size.fromHeight(
      (title != null ? kToolbarHeight : 0) + (bottom?.preferredSize.height ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF2E3A59),
      leading: showDrawer
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            )
          : (onBack != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack,
                )
              : null),
      title: title != null && title!.isNotEmpty
          ? Text(
              title!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      centerTitle: true,
      actions: [
        if (onSettings != null)
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: onSettings,
          ),
      ],
      bottom: bottom, 
    );
  }
}