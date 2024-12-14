import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image/image.dart' as img;
import '../domain/property.dart';

class PropertyFormScreen extends StatefulWidget {
  final Property? property;

  const PropertyFormScreen({Key? key, this.property}) : super(key: key);

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _imageUrl;
  XFile? _newImage;

  @override
  void initState() {
    super.initState();
    if (widget.property != null) {
      _titleController.text = widget.property!.title;
      _descriptionController.text = widget.property!.description;
      _locationController.text = widget.property!.location;
      _cityController.text = widget.property!.city ?? '';
      _stateController.text = widget.property!.state ?? '';
      _imageUrl = widget.property!.imageUrls.isNotEmpty ? widget.property!.imageUrls.first : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800, // Limit image width
      maxHeight: 600, // Limit image height
      imageQuality: 70, // Compress image quality
    );
    if (image != null) {
      setState(() {
        _newImage = image;
        _imageUrl = null; // Clear previous image URL
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_newImage == null) return _imageUrl;

    try {
      final bytes = await _newImage!.readAsBytes();
      final fileExt = _newImage!.name.split('.').last.toLowerCase();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      // Convert to Uint8List for compression
      Uint8List compressedBytes = bytes.buffer.asUint8List();

      // Compress image if it's not a web environment
      if (!kIsWeb && (fileExt == 'jpg' || fileExt == 'jpeg' || fileExt == 'png')) {
        final image = img.decodeImage(compressedBytes);
        if (image != null) {
          final compressedImage = img.copyResize(
            image,
            width: 800,
            height: 600,
            interpolation: img.Interpolation.linear,
          );
          compressedBytes = fileExt == 'png' 
              ? Uint8List.fromList(img.encodePng(compressedImage, level: 7))
              : Uint8List.fromList(img.encodeJpg(compressedImage, quality: 70));
        }
      }

      final String path = await _supabase.storage
          .from('property_images')
          .uploadBinary(
            fileName,
            compressedBytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
            ),
          );

      return _supabase.storage.from('property_images').getPublicUrl(fileName);
    } catch (error) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $error'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> _saveProperty() async {
    if (_titleController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final propertyData = {
        'name': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'city': _cityController.text.isEmpty ? null : _cityController.text,
        'state': _stateController.text.isEmpty ? null : _stateController.text,
        'user_id': _supabase.auth.currentUser!.id,
        'images': [],
      };

      if (widget.property == null) {
        await _supabase.from('properties').insert(propertyData);
      } else {
        await _supabase
            .from('properties')
            .update(propertyData)
            .eq('id', widget.property!.id);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.property == null
                ? 'Property added successfully'
                : 'Property updated successfully',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving property: $error'),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.property == null ? 'Add Property' : 'Edit Property'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Property Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a property name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City (Optional)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State (Optional)'),
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
          onPressed: _saveProperty,
          child: Text(widget.property == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
