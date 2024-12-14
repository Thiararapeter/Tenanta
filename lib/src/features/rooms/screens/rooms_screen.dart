import 'package:flutter/material.dart';
import '../../../common/widgets/base_screen.dart';
import '../models/room.dart';
import '../services/room_service.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _roomService = RoomService();
  bool _isLoading = true;
  List<Room> _rooms = [];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      setState(() => _isLoading = true);
      final rooms = await _roomService.getRooms();
      if (mounted) {
        setState(() {
          _rooms = rooms;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading rooms: $error'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      scaffoldKey: _scaffoldKey,
      title: 'Rooms',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? const Center(child: Text('No rooms found'))
              : ListView.builder(
                  itemCount: _rooms.length,
                  itemBuilder: (context, index) {
                    final room = _rooms[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text('Room ${room.roomNumber}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(room.property?.title ?? 'Unknown Property'),
                            Text('Rent: \$${room.rentAmount.toStringAsFixed(2)}'),
                            Text('Status: ${room.status}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => _AddRoomDialog(
              onSave: (roomData) async {
                try {
                  await _roomService.addRoom(roomData);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Room added successfully')),
                    );
                  }
                  _loadRooms();
                } catch (error) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding room: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddRoomDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const _AddRoomDialog({
    required this.onSave,
  });

  @override
  State<_AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<_AddRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberController = TextEditingController();
  final _rentAmountController = TextEditingController();
  String? _selectedPropertyId;

  @override
  void dispose() {
    _roomNumberController.dispose();
    _rentAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Room'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _roomNumberController,
              decoration: const InputDecoration(
                labelText: 'Room Number',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a room number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPropertyId,
              decoration: const InputDecoration(
                labelText: 'Property',
              ),
              items: [], // TODO: Load properties from RoomService
              onChanged: (value) {
                setState(() => _selectedPropertyId = value);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a property';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rentAmountController,
              decoration: const InputDecoration(
                labelText: 'Rent Amount',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a rent amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave({
                'room_number': _roomNumberController.text,
                'property_id': _selectedPropertyId,
                'rent_amount': double.parse(_rentAmountController.text),
                'status': 'available',
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
