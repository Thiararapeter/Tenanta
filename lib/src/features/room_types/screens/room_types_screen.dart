import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../common/widgets/base_screen.dart';

class RoomTypesScreen extends StatefulWidget {
  const RoomTypesScreen({super.key});

  @override
  State<RoomTypesScreen> createState() => _RoomTypesScreenState();
}

class _RoomTypesScreenState extends State<RoomTypesScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _roomTypes = [];

  @override
  void initState() {
    super.initState();
    _loadRoomTypes();
  }

  Future<void> _loadRoomTypes() async {
    try {
      final data = await _supabase
          .from('room_types')
          .select('id, name, description, base_price')
          .eq('user_id', _supabase.auth.currentUser?.id);
      
      if (mounted) {
        setState(() {
          _roomTypes = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading room types: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addRoomType() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddRoomTypeDialog(),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await _supabase.from('room_types').insert({
          'name': result['name'],
          'description': result['description'],
          'base_price': result['base_price'],
          'user_id': _supabase.auth.currentUser?.id,
        });
        _loadRoomTypes();
      } catch (e) {
        debugPrint('Error adding room type: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add room type')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _deleteRoomType(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room Type'),
        content: const Text('Are you sure you want to delete this room type?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _supabase.from('room_types').delete().eq('id', id);
        _loadRoomTypes();
      } catch (e) {
        debugPrint('Error deleting room type: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete room type')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      scaffoldKey: _scaffoldKey,
      title: 'Room Types',
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
                      ElevatedButton(
                        onPressed: _addRoomType,
                        child: const Text('Add Room Type'),
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
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(
                          roomType['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Base Price: \$${roomType['base_price']}'),
                            if (roomType['description'] != null) ...[
                              const SizedBox(height: 4),
                              Text(roomType['description'] as String),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteRoomType(roomType['id'] as int),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRoomType,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddRoomTypeDialog extends StatefulWidget {
  @override
  State<_AddRoomTypeDialog> createState() => _AddRoomTypeDialogState();
}

class _AddRoomTypeDialogState extends State<_AddRoomTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _basePriceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Room Type'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Room Type Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a room type name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _basePriceController,
                decoration: const InputDecoration(
                  labelText: 'Base Price',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a base price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
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
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'description': _descriptionController.text,
                'base_price': double.parse(_basePriceController.text),
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
