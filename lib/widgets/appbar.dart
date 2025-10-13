import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({super.key, this.title, this.bottom});

  @override
  Size get preferredSize {
    return Size.fromHeight(
      (title != null ? kToolbarHeight : 0) +
          (bottom?.preferredSize.height ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      title: title != null && title!.isNotEmpty
          ? Text(
              title!,
              style: const TextStyle(
                // color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      centerTitle: true,
      bottom: bottom,
    );
  }
}
