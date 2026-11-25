import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

/// Row widget displaying a single day's weather forecast.
class DailyForecastTile extends StatelessWidget {
  final DailyForecast forecast;
  final bool isToday;
  final String Function(double celsius) formatTemp;

  const DailyForecastTile({
    super.key,
    required this.forecast,
    required this.formatTemp,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = forecast.weatherInfo;
    final dayLabel = isToday
        ? 'Hari Ini'
        : DateFormat('EEE, d MMM').format(forecast.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              dayLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Icon(info.icon, color: info.accentColor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              info.description,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (forecast.precipitationProbabilityMax > 0) ...[
            Builder(
              builder: (context) {
                final rainBlue = theme.brightness == Brightness.dark
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF0284C7);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: rainBlue.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.water_drop_rounded,
                        size: 12,
                        color: rainBlue,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${forecast.precipitationProbabilityMax}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: rainBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
          ],
          Text(
            '${formatTemp(forecast.temperature2mMin)} / ${formatTemp(forecast.temperature2mMax)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
