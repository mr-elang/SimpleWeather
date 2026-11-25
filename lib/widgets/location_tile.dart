import 'package:flutter/material.dart';
import '../models/location_model.dart';

/// List tile representing a city in search results, favorites, or search history.
class LocationTile extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onDelete;

  const LocationTile({
    super.key,
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.location_on_rounded,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          location.name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          location.subtitle.isNotEmpty
              ? '${location.subtitle} • ${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}'
              : '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}',
          style: theme.textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
              icon: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFavorite ? Colors.amber : theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: onToggleFavorite,
            ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Hapus dari riwayat',
                icon: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
