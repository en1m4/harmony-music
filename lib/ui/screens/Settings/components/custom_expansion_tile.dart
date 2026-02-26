import 'package:flutter/material.dart';

class CustomExpansionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool initiallyExpanded;
  const CustomExpansionTile(
      {super.key,
      required this.children,
      required this.icon,
      required this.title,
      this.initiallyExpanded = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        childrenPadding: const EdgeInsets.all(8),
        tilePadding: const EdgeInsets.only(right: 16,left: 10),
        textColor: Theme.of(context).textTheme.titleMedium!.color,
        iconColor: Theme.of(context).textTheme.titleMedium!.color,
        collapsedBackgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(30),
        backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(30),
        title: Text(title),
        leading: Icon(icon),
        children: children,
      ),
    );
  }
}
