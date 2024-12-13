import 'package:flutter/material.dart';
import '../models/tenant.dart';

class TenantListItem extends StatelessWidget {
  final Tenant tenant;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TenantListItem({
    super.key,
    required this.tenant,
    required this.onTap,
    required this.onDelete,
  });

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.upToDate:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.overdue:
        return Colors.red;
    }
  }

  String _getStatusText(PaymentStatus status) {
    return status.toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(tenant.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Tenant'),
              content: Text('Are you sure you want to delete ${tenant.name}?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            child: Text(tenant.name[0].toUpperCase()),
          ),
          title: Text(tenant.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tenant.email),
              Text(tenant.phoneNumber),
              Text(
                tenant.propertyTitle,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${tenant.rentAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(tenant.paymentStatus).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(tenant.paymentStatus),
                  style: TextStyle(
                    color: _getStatusColor(tenant.paymentStatus),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}
