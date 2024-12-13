import 'package:flutter/material.dart';
import '../models/tenant.dart';

class AddEditTenantForm extends StatefulWidget {
  final Tenant? tenant;
  final Function(Tenant) onSave;

  const AddEditTenantForm({
    super.key,
    this.tenant,
    required this.onSave,
  });

  @override
  State<AddEditTenantForm> createState() => _AddEditTenantFormState();
}

class _AddEditTenantFormState extends State<AddEditTenantForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _rentAmountController;
  late DateTime _moveInDate;
  DateTime? _moveOutDate;
  late PaymentStatus _paymentStatus;
  late TextEditingController _notesController;
  String? _selectedPropertyId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tenant?.name);
    _emailController = TextEditingController(text: widget.tenant?.email);
    _phoneController = TextEditingController(text: widget.tenant?.phoneNumber);
    _rentAmountController = TextEditingController(
      text: widget.tenant?.rentAmount.toString(),
    );
    _moveInDate = widget.tenant?.moveInDate ?? DateTime.now();
    _moveOutDate = widget.tenant?.moveOutDate;
    _paymentStatus = widget.tenant?.paymentStatus ?? PaymentStatus.upToDate;
    _notesController = TextEditingController(text: widget.tenant?.notes);
    _selectedPropertyId = widget.tenant?.propertyId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rentAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isMoveIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isMoveIn ? _moveInDate : (_moveOutDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isMoveIn) {
          _moveInDate = picked;
        } else {
          _moveOutDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.tenant == null ? 'Add New Tenant' : 'Edit Tenant',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter tenant name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // TODO: Add property selection dropdown
              // FutureBuilder<List<Property>>(
              //   future: _loadProperties(),
              //   builder: (context, snapshot) {
              //     return DropdownButtonFormField<String>(
              //       value: _selectedPropertyId,
              //       items: snapshot.data
              //           ?.map((property) => DropdownMenuItem(
              //                 value: property.id,
              //                 child: Text(property.title),
              //               ))
              //           .toList(),
              //       onChanged: (value) {
              //         setState(() => _selectedPropertyId = value);
              //       },
              //       decoration: const InputDecoration(
              //         labelText: 'Property',
              //         border: OutlineInputBorder(),
              //       ),
              //     );
              //   },
              // ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rentAmountController,
                decoration: const InputDecoration(
                  labelText: 'Rent Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter rent amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Move-in Date'),
                      subtitle: Text(
                        '${_moveInDate.year}-${_moveInDate.month}-${_moveInDate.day}',
                      ),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Move-out Date'),
                      subtitle: Text(
                        _moveOutDate != null
                            ? '${_moveOutDate!.year}-${_moveOutDate!.month}-${_moveOutDate!.day}'
                            : 'Not set',
                      ),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PaymentStatus>(
                value: _paymentStatus,
                items: PaymentStatus.values
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toString().split('.').last),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _paymentStatus = value);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Payment Status',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: Create actual tenant object and save
                    // final tenant = Tenant(
                    //   id: widget.tenant?.id ?? '',
                    //   propertyId: _selectedPropertyId!,
                    //   name: _nameController.text,
                    //   email: _emailController.text,
                    //   phoneNumber: _phoneController.text,
                    //   rentAmount: double.parse(_rentAmountController.text),
                    //   paymentStatus: _paymentStatus,
                    //   moveInDate: _moveInDate,
                    //   moveOutDate: _moveOutDate,
                    //   notes: _notesController.text,
                    // );
                    // widget.onSave(tenant);
                  }
                },
                child: const Text('Save Tenant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
