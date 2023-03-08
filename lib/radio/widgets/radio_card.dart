import 'package:flutter/material.dart';

class RadioCard extends StatelessWidget {
  const RadioCard({
    super.key, required this.onTab, required this.item,
  });

  final Map<String, dynamic> item;
  final void Function() onTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.grey.shade900,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTab,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(item['imageURL']),
                        fit: BoxFit.cover
                      )
                    ),
                  ),
                  const SizedBox(width: 12,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'], style: theme.textTheme.labelLarge!.copyWith(fontSize: 18, color: Colors.grey.shade500), overflow: TextOverflow.ellipsis,),
                        Text(item['location'], style: theme.textTheme.bodyMedium!.copyWith(color: Colors.grey.shade700)),
                        const SizedBox(height: 8,),
                        Text(item['listener'], style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Icon(!item['isPlay'] ? Icons.play_arrow : Icons.pause, size: 24, color: Colors.white),
                  const SizedBox(width: 6,)
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
