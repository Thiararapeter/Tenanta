import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tenant.dart';

class TenantListItem extends StatelessWidget {
  final Tenant tenant;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TenantListItem({
    Key? key,
    required this.tenant,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM d, y').format(date);
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$').format(amount);
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.upToDate:
        return Colors.green;
      case PaymentStatus.late:
        return Colors.orange;
      case PaymentStatus.overdue:
        return Colors.red;
      case PaymentStatus.pending:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap ?? onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tenant.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Tenant'),
                            content: Text('Are you sure you want to delete ${tenant.name}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onDelete!();
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16),
                  const SizedBox(width: 8),
                  Text(tenant.phoneNumber),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.email, size: 16),
                  const SizedBox(width: 8),
                  Text(tenant.email),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Room ID: ${tenant.roomId}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Property ID: ${tenant.propertyId}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(tenant.paymentStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tenant.paymentStatus.toString().split('.').last,
                  style: TextStyle(
                    color: _getPaymentStatusColor(tenant.paymentStatus),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Move In: ${_formatDate(tenant.moveInDate)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (tenant.moveOutDate != null)
                Text(
                  'Move Out: ${_formatDate(tenant.moveOutDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 8),
              Text(
                'Rent: ${_formatCurrency(tenant.rentAmount)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
