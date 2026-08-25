/// Users Screen — Admin Dashboard
///
/// Data table with sort, filter, pagination — the classic admin use case.
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  // Table sort state
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  // Search filter
  String _search = '';

  // Rows per page for pagination
  int _rowsPerPage = 10;

  // Sample data
  static const _allUsers = [
    ('USR001', 'Budi Santoso', 'budi@example.com', 'Admin', 'Active'),
    ('USR002', 'Siti Rahayu', 'siti@example.com', 'User', 'Active'),
    ('USR003', 'Ahmad Fauzi', 'ahmad@example.com', 'User', 'Inactive'),
    ('USR004', 'Dewi Lestari', 'dewi@example.com', 'Manager', 'Active'),
    ('USR005', 'Eko Prasetyo', 'eko@example.com', 'User', 'Active'),
    ('USR006', 'Fitri Handayani', 'fitri@example.com', 'User', 'Active'),
    ('USR007', 'Galih Wijaya', 'galih@example.com', 'Admin', 'Active'),
    ('USR008', 'Hendra Kusuma', 'hendra@example.com', 'User', 'Inactive'),
  ];

  List<(String, String, String, String, String)> get _filtered =>
      _allUsers.where((u) {
        final q = _search.toLowerCase();
        return q.isEmpty ||
            u.$2.toLowerCase().contains(q) ||
            u.$3.toLowerCase().contains(q);
      }).toList();

  @override
  Widget build(BuildContext context) {
    final data = _filtered;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Users',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Add User'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search
            SizedBox(
              width: 320,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search users…',
                  prefixIcon: Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            const SizedBox(height: 16),

            // Data table
            Expanded(
              child: Card(
                child: PaginatedDataTable(
                  header: Text('${data.length} users'),
                  rowsPerPage: _rowsPerPage,
                  onRowsPerPageChanged: (v) =>
                      setState(() => _rowsPerPage = v ?? 10),
                  availableRowsPerPage: const [5, 10, 25],
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  columns: [
                    DataColumn(
                      label: const Text('ID'),
                      onSort: (i, asc) => setState(() {
                        _sortColumnIndex = i;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn(
                      label: const Text('Name'),
                      onSort: (i, asc) => setState(() {
                        _sortColumnIndex = i;
                        _sortAscending = asc;
                      }),
                    ),
                    const DataColumn(label: Text('Email')),
                    const DataColumn(label: Text('Role')),
                    const DataColumn(label: Text('Status')),
                    const DataColumn(label: Text('Actions')),
                  ],
                  source: _UsersDataSource(data),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersDataSource extends DataTableSource {
  final List<(String, String, String, String, String)> data;
  _UsersDataSource(this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final u = data[index];
    final isActive = u.$5 == 'Active';
    return DataRow(cells: [
      DataCell(Text(u.$1,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
      DataCell(Text(u.$2)),
      DataCell(Text(u.$3, style: const TextStyle(fontSize: 12))),
      DataCell(Chip(
        label: Text(u.$4, style: const TextStyle(fontSize: 11)),
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      )),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(u.$5,
            style: TextStyle(
                fontSize: 11,
                color: isActive ? Colors.green.shade700 : Colors.grey)),
      )),
      DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 16),
          onPressed: () {},
          tooltip: 'Edit',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.delete, size: 16, color: Colors.red),
          onPressed: () {},
          tooltip: 'Delete',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ])),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}
