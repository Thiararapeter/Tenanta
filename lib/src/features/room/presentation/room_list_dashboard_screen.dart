import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/room.dart';
import '../domain/room_type.dart';
import '../../property/domain/property.dart';
import 'room_form_screen.dart';

class RoomListDashboardScreen extends StatefulWidget {
  const RoomListDashboardScreen({Key? key}) : super(key: key);

  @override
  State<RoomListDashboardScreen> createState() => _RoomListDashboardScreenState();
}

class _RoomListDashboardScreenState extends State<RoomListDashboardScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Room> _rooms = [];
  Map<String, RoomType> _roomTypes = {};
  Map<String, Property> _properties = {};

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

      final roomTypes = (roomTypesResponse as List)
          .map((data) => RoomType.fromJson(data))
          .toList();

      _roomTypes = {
        for (var type in roomTypes) type.id: type,
      };

      // Load properties
      final propertiesResponse = await _supabase
          .from('properties')
          .select();

      final properties = (propertiesResponse as List)
          .map((data) => Property.fromJson(data))
          .toList();

      _properties = {
        for (var property in properties) property.id: property,
      };

      // Load rooms
      final roomsResponse = await _supabase
          .from('rooms')
          .select()
          .order('property_id')
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

  Future<void> _editRoom(Room room) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => RoomFormScreen(room: room),
      ),
    );

    if (result == true) {
      await _loadData();
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Rooms'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No rooms found.\nAdd rooms to your properties.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RoomFormScreen(),
                            ),
                          );

                          if (result == true) {
                            await _loadData();
                          }
                        },
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
                    final property = _properties[room.propertyId];
                    final roomType = _roomTypes[room.roomTypeId];

                    return Card(
                      child: ListTile(
                        title: Text('Room ${room.roomNumber}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Property: ${property?.title ?? 'Unknown'}'),
                            Text('Type: ${roomType?.name ?? 'Unknown'}'),
                            Text('Floor: ${room.floor}'),
                            Text('Rent: \$${room.rent.toStringAsFixed(2)}'),
                            Text(
                              room.isOccupied ? 'Occupied' : 'Vacant',
                              style: TextStyle(
                                color: room.isOccupied
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editRoom(room),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteRoom(room),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
      floatingActionButton: _rooms.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoomFormScreen(),
                  ),
                );

                if (result == true) {
                  await _loadData();
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
