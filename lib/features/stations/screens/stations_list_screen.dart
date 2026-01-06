import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicharge/providers/location_provider.dart';
import 'package:unicharge/providers/stations_provider.dart';
import 'package:unicharge/models/enums.dart';
import 'package:unicharge/models/station_model.dart';
import 'package:unicharge/features/stations/widgets/station_list_item.dart';

class StationsListScreen extends ConsumerStatefulWidget {
  const StationsListScreen({super.key});

  @override
  ConsumerState<StationsListScreen> createState() => _StationsListScreenState();
}

class _StationsListScreenState extends ConsumerState<StationsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  StationType? _selectedFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationStateProvider);
    final stationsState = ref.watch(stationsStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Stations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter chips
          if (_selectedFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(_selectedFilter!.displayName),
                    onDeleted: () {
                      setState(() {
                        _selectedFilter = null;
                      });
                    },
                    deleteIcon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),

          // Stations list
          Expanded(
            child: locationState.when(
              data: (position) {
                if (position == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, size: 64),
                        SizedBox(height: 16),
                        Text('Location access required'),
                        Text('Please enable location services'),
                      ],
                    ),
                  );
                }

                return stationsState.when(
                  data: (stations) {
                    final filteredStations = _filterStations(stations);
                    
                    if (filteredStations.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty ? Icons.search_off : Icons.location_off,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty 
                                  ? 'No stations found for "$_searchQuery"'
                                  : 'No stations found nearby',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.read(stationsStateProvider.notifier).refreshStations(position);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredStations.length,
                        itemBuilder: (context, index) {
                          final station = filteredStations[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: StationListItem(
                              station: station,
                              onTap: () {
                                // TODO: Navigate to station details
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64),
                        const SizedBox(height: 16),
                        Text('Error: $error'),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(stationsStateProvider);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(locationStateProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<StationModel> _filterStations(List<StationModel> stations) {
    var filtered = stations;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((station) {
        return station.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               station.address.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by type
    if (_selectedFilter != null) {
      filtered = filtered.where((station) {
        switch (_selectedFilter!) {
          case StationType.charging:
            return station.type == StationType.charging || station.type == StationType.hybrid;
          case StationType.parking:
            return station.type == StationType.parking || station.type == StationType.hybrid;
          case StationType.hybrid:
            return station.type == StationType.hybrid;
        }
      }).toList();
    }

    return filtered;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Stations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'Station Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedFilter == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = null;
                    });
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Charging'),
                  selected: _selectedFilter == StationType.charging,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = StationType.charging;
                    });
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Parking'),
                  selected: _selectedFilter == StationType.parking,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = StationType.parking;
                    });
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Hybrid'),
                  selected: _selectedFilter == StationType.hybrid,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = StationType.hybrid;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
