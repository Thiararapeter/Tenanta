import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/room.dart';
import '../domain/room_type.dart';
import '../../property/domain/property.dart';

class RoomFormScreen extends StatefulWidget {
  final Room? room;
  final String? preSelectedPropertyId;

  const RoomFormScreen({
    Key? key,
    this.room,
    this.preSelectedPropertyId,
  }) : super(key: key);

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Property> _properties = [];
  List<RoomType> _roomTypes = [];

  String? _selectedPropertyId;
  String? _selectedRoomTypeId;
  final _roomNumberController = TextEditingController();
  final _floorController = TextEditingController();
  final _rentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.room != null) {
      _selectedPropertyId = widget.room!.propertyId;
      _selectedRoomTypeId = widget.room!.roomTypeId;
      _roomNumberController.text = widget.room!.roomNumber;
      _floorController.text = widget.room!.floor.toString();
      _rentController.text = widget.room!.rent.toString();
    } else if (widget.preSelectedPropertyId != null) {
      _selectedPropertyId = widget.preSelectedPropertyId;
    }
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _floorController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Load properties
      final propertiesResponse = await _supabase
          .from('properties')
          .select()
          .order('title');

      // Load room types
      final roomTypesResponse = await _supabase
          .from('room_types')
          .select()
          .order('name');

      setState(() {
        _properties = (propertiesResponse as List)
            .map((data) => Property.fromJson(data))
            .toList();
        _roomTypes = (roomTypesResponse as List)
            .map((data) => RoomType.fromJson(data))
            .toList();

        if (_selectedRoomTypeId == null && _roomTypes.isNotEmpty) {
          _selectedRoomTypeId = _roomTypes.first.id;
        }

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $error'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final roomData = {
        'property_id': _selectedPropertyId,
        'room_type_id': _selectedRoomTypeId,
        'room_number': _roomNumberController.text,
        'floor': int.parse(_floorController.text),
        'rent': double.parse(_rentController.text),
      };

      if (widget.room == null) {
        // Create new room
        await _supabase.from('rooms').insert(roomData);
      } else {
        // Update existing room
        await _supabase
            .from('rooms')
            .update(roomData)
            .eq('id', widget.room!.id);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving room: $error'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room == null ? 'Add Room' : 'Edit Room'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                      onChanged: widget.preSelectedPropertyId != null
                          ? null
                          : (value) {
                              setState(() {
                                _selectedPropertyId = value;
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
                      value: _selectedRoomTypeId,
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
                        setState(() {
                          _selectedRoomTypeId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a room type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _roomNumberController,
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
                      controller: _floorController,
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
                      controller: _rentController,
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
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveRoom,
                      child: Text(
                        widget.room == null ? 'Add Room' : 'Save Changes',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
