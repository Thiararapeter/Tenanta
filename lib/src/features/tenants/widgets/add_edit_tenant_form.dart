import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tenant.dart';
import '../../property/domain/property.dart';
import '../../rooms/models/room.dart';

class AddEditTenantForm extends StatefulWidget {
  final Tenant? tenant;
  final Function(Map<String, dynamic>) onSave;

  const AddEditTenantForm({
    Key? key, 
    this.tenant,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditTenantForm> createState() => _AddEditTenantFormState();
}

class _AddEditTenantFormState extends State<AddEditTenantForm> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rentAmountController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = true;
  List<Property> _properties = [];
  List<Room> _availableRooms = [];
  String? _selectedPropertyId;
  String? _selectedRoomId;
  DateTime _moveInDate = DateTime.now();
  DateTime? _moveOutDate;
  String _paymentStatus = 'upToDate';

  @override
  void initState() {
    super.initState();
    _loadProperties();
    if (widget.tenant != null) {
      _nameController.text = widget.tenant!.name;
      _emailController.text = widget.tenant!.email;
      _phoneController.text = widget.tenant!.phoneNumber;
      _rentAmountController.text = widget.tenant!.rentAmount.toString();
      _notesController.text = widget.tenant!.notes ?? '';
      _selectedPropertyId = widget.tenant!.propertyId;
      _selectedRoomId = widget.tenant!.roomId;
      _moveInDate = widget.tenant!.moveInDate;
      _moveOutDate = widget.tenant!.moveOutDate;
      _paymentStatus = widget.tenant!.paymentStatus.toString().split('.').last;
    }
  }

  Future<void> _loadProperties() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('properties')
          .select()
          .eq('user_id', userId);

      setState(() {
        _properties = (response as List<dynamic>)
            .map((data) => Property.fromJson(Map<String, dynamic>.from(data)))
            .toList();
        _isLoading = false;
      });

      if (_selectedPropertyId != null) {
        _loadAvailableRooms(_selectedPropertyId!);
      }
    } catch (e) {
      print('Error loading properties: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAvailableRooms(String propertyId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('rooms')
          .select('*, property:properties(*)')
          .eq('property_id', propertyId)
          .eq('user_id', userId)
          .or('status.eq.available,id.eq.${_selectedRoomId ?? ''}');

      setState(() {
        _availableRooms = (response as List<dynamic>)
            .map((data) => Room.fromJson(Map<String, dynamic>.from(data)))
            .toList();
      });
    } catch (e) {
      print('Error loading rooms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
              DropdownButtonFormField<String>(
                value: _selectedPropertyId,
                decoration: const InputDecoration(
                  labelText: 'Property',
                  border: OutlineInputBorder(),
                ),
                items: _properties.map((property) {
                  return DropdownMenuItem(
                    value: property.id,
                    child: Text(property.title),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPropertyId = value;
                    _selectedRoomId = null;
                    if (value != null) {
                      _loadAvailableRooms(value);
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a property';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRoomId,
                decoration: const InputDecoration(
                  labelText: 'Room',
                  border: OutlineInputBorder(),
                ),
                items: _availableRooms.map((room) {
                  return DropdownMenuItem(
                    value: room.id,
                    child: Text('Room ${room.roomNumber} - \$${room.rentAmount.toStringAsFixed(2)}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoomId = value;
                    if (value != null) {
                      final selectedRoom = _availableRooms.firstWhere((room) => room.id == value);
                      _rentAmountController.text = selectedRoom.rentAmount.toString();
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a room';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rentAmountController,
                decoration: const InputDecoration(
                  labelText: 'Rent Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                enabled: false, // Rent amount is auto-filled from selected room
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a room to set rent amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Move-in Date'),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _moveInDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() => _moveInDate = date);
                            }
                          },
                          child: Text(
                            _moveInDate.toString().split(' ')[0],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Move-out Date'),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _moveOutDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() => _moveOutDate = date);
                            }
                          },
                          child: Text(
                            _moveOutDate?.toString().split(' ')[0] ?? 'Not set',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentStatus,
                decoration: const InputDecoration(
                  labelText: 'Payment Status',
                  border: OutlineInputBorder(),
                ),
                items: ['upToDate', 'pending', 'overdue']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _paymentStatus = value);
                  }
                },
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
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final tenantData = {
                      'name': _nameController.text,
                      'email': _emailController.text,
                      'phone_number': _phoneController.text,
                      'property_id': _selectedPropertyId,
                      'room_id': _selectedRoomId,
                      'rent_amount': double.parse(_rentAmountController.text),
                      'move_in_date': _moveInDate.toIso8601String(),
                      'move_out_date': _moveOutDate?.toIso8601String(),
                      'payment_status': _paymentStatus,
                      'notes': _notesController.text,
                      'user_id': _supabase.auth.currentUser!.id,
                    };

                    widget.onSave(tenantData);
                  }
                },
                child: Text(widget.tenant == null ? 'Save Tenant' : 'Update Tenant'),
              ),
            ],
          ),
        ),
      ),
    );
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
}
