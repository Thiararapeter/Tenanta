import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/room_type.dart';

class RoomTypeScreen extends StatefulWidget {
  const RoomTypeScreen({Key? key}) : super(key: key);

  @override
  State<RoomTypeScreen> createState() => _RoomTypeScreenState();
}

class _RoomTypeScreenState extends State<RoomTypeScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  List<RoomType> _roomTypes = [];

  @override
  void initState() {
    super.initState();
    _loadRoomTypes();
  }

  Future<void> _loadRoomTypes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _supabase
          .from('room_types')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _roomTypes = (response as List)
            .map((data) => RoomType.fromJson(data))
            .toList();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading room types: $error'),
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

  Future<void> _showAddEditRoomTypeDialog([RoomType? roomType]) async {
    final nameController = TextEditingController(text: roomType?.name);
    final descriptionController = TextEditingController(text: roomType?.description);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(roomType == null ? 'Add Room Type' : 'Edit Room Type'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                maxLines: 3,
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
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'description': descriptionController.text,
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
        if (roomType == null) {
          // Create new room type
          await _supabase.from('room_types').insert(result);
        } else {
          // Update existing room type
          await _supabase
              .from('room_types')
              .update(result)
              .eq('id', roomType.id);
        }

        await _loadRoomTypes();
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving room type: $error'),
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

  Future<void> _deleteRoomType(RoomType roomType) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room Type'),
        content: Text('Are you sure you want to delete ${roomType.name}?'),
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
            .from('room_types')
            .delete()
            .eq('id', roomType.id);

        await _loadRoomTypes();
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting room type: $error'),
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
        title: const Text('Room Types'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _roomTypes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No room types found',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditRoomTypeDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Room Type'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _roomTypes.length,
                  itemBuilder: (context, index) {
                    final roomType = _roomTypes[index];
                    return Card(
                      child: ListTile(
                        title: Text(roomType.name),
                        subtitle: Text(roomType.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showAddEditRoomTypeDialog(roomType),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteRoomType(roomType),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: _roomTypes.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showAddEditRoomTypeDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
