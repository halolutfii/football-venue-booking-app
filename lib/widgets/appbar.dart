import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    Key? key,
    this.title,
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
      automaticallyImplyLeading: false,
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
      bottom: bottom, 
    );
  }
}