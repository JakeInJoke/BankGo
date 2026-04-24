import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/simulation_bloc.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SimulationBloc>().add(MarkNotificationsAsRead());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notifications),
      ),
      body: BlocBuilder<SimulationBloc, SimulationState>(
        builder: (context, state) {
          if (state.notifications.isEmpty) {
            return const Center(
              child: Text('No hay alertas por el momento.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.paddingPage),
            itemCount: state.notifications.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.spaceSM),
            itemBuilder: (context, index) {
              final item = state.notifications[index];
              return ListTile(
                contentPadding: const EdgeInsets.all(AppDimensions.spaceSM),
                leading: CircleAvatar(
                  child: Icon(_iconForType(item.type)),
                ),
                title: Text(item.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.message),
                    const SizedBox(height: 4),
                    Text(
                      _dateTimeText(item.createdAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    if (item.amount != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Monto: ${CurrencyFormatter.format(item.amount!)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ],
                ),
                trailing: Text(
                  _timeText(item.createdAt),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.security:
        return Icons.shield_outlined;
      case NotificationType.purchase:
        return Icons.shopping_bag_outlined;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }

  String _timeText(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    return 'hace ${diff.inDays}d';
  }

  String _dateTimeText(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm', 'es_PE').format(dateTime);
  }
}
