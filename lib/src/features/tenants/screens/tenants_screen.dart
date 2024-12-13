import 'package:flutter/material.dart';
import '../models/tenant.dart';
import '../widgets/tenant_list_item.dart';
import '../widgets/add_edit_tenant_form.dart';
import '../services/tenant_service.dart';

class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> {
  String _searchQuery = '';
  PaymentStatus? _filterStatus;
  final TenantService _tenantService = TenantService();
  List<Tenant> _tenants = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tenants = await _tenantService.getTenants();
      setState(() {
        _tenants = tenants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load tenants: $e';
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddTenantDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddEditTenantForm(
          onSave: _handleSaveTenant,
        ),
      ),
    );
  }

  Future<void> _handleSaveTenant(Map<String, dynamic> tenantData) async {
    try {
      await _tenantService.addTenant(tenantData);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tenant added successfully')),
        );
      }
      _loadTenants();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding tenant: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleEditTenant(String id, Map<String, dynamic> tenantData) async {
    try {
      await _tenantService.updateTenant(id, tenantData);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tenant updated successfully')),
        );
      }
      _loadTenants();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating tenant: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteTenant(String id) async {
    try {
      await _tenantService.deleteTenant(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tenant deleted successfully')),
        );
      }
      _loadTenants();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting tenant: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Tenant> get _filteredTenants {
    return _tenants.where((tenant) {
      final matchesSearch = tenant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tenant.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tenant.propertyTitle.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _filterStatus == null || tenant.paymentStatus == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTenantDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search tenants...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _filterStatus == null,
                        onSelected: (selected) {
                          setState(() => _filterStatus = null);
                        },
                      ),
                      const SizedBox(width: 8),
                      ...PaymentStatus.values.map((status) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(status.toString().split('.').last),
                            selected: _filterStatus == status,
                            onSelected: (selected) {
                              setState(() => _filterStatus = selected ? status : null);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            ElevatedButton(
                              onPressed: _loadTenants,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredTenants.isEmpty
                        ? const Center(child: Text('No tenants found'))
                        : ListView.builder(
                            itemCount: _filteredTenants.length,
                            itemBuilder: (context, index) {
                              final tenant = _filteredTenants[index];
                              return TenantListItem(
                                tenant: tenant,
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).viewInsets.bottom,
                                      ),
                                      child: AddEditTenantForm(
                                        tenant: tenant,
                                        onSave: (tenantData) => _handleEditTenant(tenant.id, tenantData),
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () => _handleDeleteTenant(tenant.id),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
