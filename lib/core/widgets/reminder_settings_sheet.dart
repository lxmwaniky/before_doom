import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class ReminderSettingsSheet extends StatefulWidget {
  final String? nextMovieTitle;

  const ReminderSettingsSheet({super.key, this.nextMovieTitle});

  @override
  State<ReminderSettingsSheet> createState() => _ReminderSettingsSheetState();
}

class _ReminderSettingsSheetState extends State<ReminderSettingsSheet> {
  final _notificationService = NotificationService();
  bool _isEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _notificationService.getReminderSettings();
    await _notificationService.init();

    setState(() {
      _isEnabled = settings.enabled;
      _selectedTime = settings.timeOfDay;
      _isLoading = false;
    });
  }

  Future<void> _toggleReminder(bool enabled) async {
    try {
      if (enabled) {
        final granted = await _notificationService.requestPermission();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enable notifications in settings'),
              ),
            );
          }
          return;
        }

        final success = await _notificationService.scheduleDailyReminder(
          hour: _selectedTime.hour,
          minute: _selectedTime.minute,
          nextMovieTitle: widget.nextMovieTitle,
        );

        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to schedule reminder')),
          );
          return;
        }
      } else {
        await _notificationService.cancelReminder();
      }

      setState(() => _isEnabled = enabled);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
      }
    }
  }

  Future<void> _pickTime() async {
    try {
      final picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );

      if (picked != null) {
        setState(() => _selectedTime = picked);

        if (_isEnabled) {
          final success = await _notificationService.scheduleDailyReminder(
            hour: picked.hour,
            minute: picked.minute,
            nextMovieTitle: widget.nextMovieTitle,
          );

          if (!success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update reminder time')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Icon(
            Icons.notifications_active,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Watch Reminders',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get daily reminders to continue your MCU journey',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Daily Reminder'),
              subtitle: Text(_isEnabled ? 'Enabled' : 'Disabled'),
              value: _isEnabled,
              onChanged: _toggleReminder,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedOpacity(
            opacity: _isEnabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.access_time,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Reminder Time'),
                trailing: Text(
                  _selectedTime.format(context),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: _isEnabled ? _pickTime : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
