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
  final _rentController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
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
      _rentController.text = widget.property!.rent.toString();
      _cityController.text = widget.property!.city;
      _addressController.text = widget.property!.address;
      _imageUrl = widget.property!.imageUrls.isNotEmpty ? widget.property!.imageUrls.first : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rentController.dispose();
    _cityController.dispose();
    _addressController.dispose();
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
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final imageUrl = await _uploadImage();
      final propertyData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'rent': double.parse(_rentController.text),
        'city': _cityController.text,
        'address': _addressController.text,
        'image_urls': imageUrl != null ? [imageUrl] : [],
        'owner_id': _supabase.auth.currentUser!.id,
      };

      if (widget.property == null) {
        // Create new property
        await _supabase.from('properties').insert(propertyData);
      } else {
        // Update existing property
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property == null ? 'Add Property' : 'Edit Property'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the city';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the address';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Property Image',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_imageUrl != null || _newImage != null) ...[
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _newImage != null
                          ? kIsWeb
                              ? Image.network(
                                  _newImage!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_newImage!.path),
                                  fit: BoxFit.cover,
                                )
                          : Image.network(
                              _imageUrl!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          _newImage = null;
                          _imageUrl = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(_imageUrl != null || _newImage != null
                  ? 'Change Image'
                  : 'Add Image'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProperty,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        widget.property == null ? 'Add Property' : 'Save Changes',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
