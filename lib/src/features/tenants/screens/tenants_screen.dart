import 'package:flutter/material.dart';
import '../models/tenant.dart';
import '../widgets/tenant_list_item.dart';
import '../widgets/add_edit_tenant_form.dart';
import '../services/tenant_service.dart';
import '../../../common/widgets/base_screen.dart';

class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
          onSave: (tenantData) => _handleSaveTenant(tenantData),
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

  void _showEditTenantDialog(Tenant tenant) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredTenants = _tenants.where((tenant) {
      final matchesSearch = tenant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tenant.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _filterStatus == null || tenant.paymentStatus == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    return BaseScreen(
      scaffoldKey: _scaffoldKey,
      title: 'Tenants',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadTenants,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTenantDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tenants...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 16),
                DropdownButton<PaymentStatus>(
                  value: _filterStatus,
                  hint: const Text('Filter by payment status'),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All'),
                    ),
                    ...PaymentStatus.values.map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toString().split('.').last),
                        )),
                  ],
                  onChanged: (value) => setState(() => _filterStatus = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : filteredTenants.isEmpty
                        ? const Center(child: Text('No tenants found'))
                        : ListView.builder(
                            itemCount: filteredTenants.length,
                            itemBuilder: (context, index) {
                              final tenant = filteredTenants[index];
                              return TenantListItem(
                                tenant: tenant,
                                onEdit: () => _showEditTenantDialog(tenant),
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
