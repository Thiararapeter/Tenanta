import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/room.dart';
import '../domain/room_type.dart';

class RoomListScreen extends StatefulWidget {
  final String propertyId;
  final String propertyName;

  const RoomListScreen({
    Key? key,
    required this.propertyId,
    required this.propertyName,
  }) : super(key: key);

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  List<Room> _rooms = [];
  List<RoomType> _roomTypes = [];
  Map<String, RoomType> _roomTypeMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load room types
      final roomTypesResponse = await _supabase
          .from('room_types')
          .select()
          .order('name');

      _roomTypes = (roomTypesResponse as List)
          .map((data) => RoomType.fromJson(data))
          .toList();

      _roomTypeMap = {
        for (var type in _roomTypes) type.id: type,
      };

      // Load rooms for this property
      final roomsResponse = await _supabase
          .from('rooms')
          .select()
          .eq('property_id', widget.propertyId)
          .order('floor')
          .order('room_number');

      setState(() {
        _rooms = (roomsResponse as List)
            .map((data) => Room.fromJson(data))
            .toList();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading rooms: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showAddEditRoomDialog([Room? room]) async {
    if (_roomTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add room types first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final roomNumberController = TextEditingController(text: room?.roomNumber);
    final floorController = TextEditingController(
        text: room?.floor.toString());
    final rentController = TextEditingController(
        text: room?.rent.toString());
    String? selectedRoomTypeId = room?.roomTypeId ?? _roomTypes.first.id;
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(room == null ? 'Add Room' : 'Edit Room'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedRoomTypeId,
                  decoration: const InputDecoration(
                    labelText: 'Room Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _roomTypes.map((type) {
                    return DropdownMenuItem(
                      value: type.id,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedRoomTypeId = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a room type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: roomNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Room Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a room number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: floorController,
                  decoration: const InputDecoration(
                    labelText: 'Floor',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the floor number';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: rentController,
                  decoration: const InputDecoration(
                    labelText: 'Rent',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the rent amount';
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  'room_type_id': selectedRoomTypeId,
                  'room_number': roomNumberController.text,
                  'floor': int.parse(floorController.text),
                  'rent': double.parse(rentController.text),
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        result['property_id'] = widget.propertyId;

        if (room == null) {
          // Create new room
          await _supabase.from('rooms').insert(result);
        } else {
          // Update existing room
          await _supabase
              .from('rooms')
              .update(result)
              .eq('id', room.id);
        }

        await _loadData();
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving room: $error'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _deleteRoom(Room room) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room'),
        content: Text('Are you sure you want to delete room ${room.roomNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _supabase
            .from('rooms')
            .delete()
            .eq('id', room.id);

        await _loadData();
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting room: $error'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rooms - ${widget.propertyName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No rooms found',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditRoomDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Room'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _rooms.length,
                  itemBuilder: (context, index) {
                    final room = _rooms[index];
                    final roomType = _roomTypeMap[room.roomTypeId];
                    return Card(
                      child: ListTile(
                        title: Text('Room ${room.roomNumber}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type: ${roomType?.name ?? 'Unknown'}'),
                            Text('Floor: ${room.floor}'),
                            Text('Rent: \$${room.rent.toStringAsFixed(2)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showAddEditRoomDialog(room),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteRoom(room),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditRoomDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
