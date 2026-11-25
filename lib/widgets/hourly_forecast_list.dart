import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

/// Horizontal scrollable list of hourly weather forecasts (next 24 hours).
class HourlyForecastList extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final String Function(double celsius) formatTemp;

  const HourlyForecastList({
    super.key,
    required this.hourly,
    required this.formatTemp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rainBlue = theme.brightness == Brightness.dark
        ? const Color(0xFF38BDF8)
        : const Color(0xFF0284C7);

    return SizedBox(
      height: 126,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hourly.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = hourly[index];
          final info = item.weatherInfo;
          final timeLabel =
              index == 0 ? 'Skrg' : DateFormat('HH:mm').format(item.time);

          return SizedBox(
            width: 78,
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: index == 0 ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    Icon(info.icon, color: info.accentColor, size: 24),
                    if (item.precipitationProbability > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.water_drop_rounded,
                            size: 11,
                            color: rainBlue,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${item.precipitationProbability}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: rainBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox(height: 14),
                    Text(
                      formatTemp(item.temperature2m),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
