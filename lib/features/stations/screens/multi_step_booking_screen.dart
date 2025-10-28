import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicharge/models/station_model.dart';
import 'package:unicharge/models/slot_model.dart';
import 'package:unicharge/models/booking_model.dart';
import 'package:unicharge/models/enums.dart';
import 'package:unicharge/providers/stations_provider.dart';
import 'package:unicharge/providers/auth_provider.dart';
import 'package:unicharge/providers/booking_provider.dart';
import 'package:unicharge/features/bookings/screens/booking_confirmation_screen.dart';

class MultiStepBookingScreen extends ConsumerStatefulWidget {
  final StationModel station;

  const MultiStepBookingScreen({
    super.key,
    required this.station,
  });

  @override
  ConsumerState<MultiStepBookingScreen> createState() => _MultiStepBookingScreenState();
}

class _MultiStepBookingScreenState extends ConsumerState<MultiStepBookingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  DateTime? _startTime;
  DateTime? _endTime;
  String? _selectedSlotId;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.station.name),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),
          
          // Page view
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildTimeSelectionPage(),
                _buildSlotSelectionPage(),
                _buildReviewPage(),
              ],
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepItem('Time', 0, Icons.access_time),
          _buildStepDivider(),
          _buildStepItem('Slot', 1, Icons.layers),
          _buildStepDivider(),
          _buildStepItem('Confirm', 2, Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStepItem(String label, int step, IconData icon) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isCompleted
                ? Colors.green
                : isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider() {
    return Expanded(
      child: Container(
        height: 2,
        color: _currentStep >= 2
            ? Colors.green
            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildTimeSelectionPage() {
    DateTime startTime = _startTime ?? _getNext30MinuteInterval();
    DateTime endTime = _endTime ?? _getNext30MinuteInterval().add(const Duration(hours: 2));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Your Time',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose when you want to park or charge',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          
          // Start Time
          _buildTimeSelector(
            context,
            'Start Time',
            startTime,
            Icons.access_time,
            (time) {
              setState(() {
                _startTime = time;
                if (endTime.isBefore(time) || endTime == time) {
                  _endTime = time.add(const Duration(hours: 1));
                }
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // End Time
          _buildTimeSelector(
            context,
            'End Time',
            endTime,
            Icons.event,
            (time) {
              setState(() {
                _endTime = time;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Duration Summary
          if (_startTime != null && _endTime != null)
            _buildDurationSummary(context, _startTime!, _endTime!),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    BuildContext context,
    String label,
    DateTime time,
    IconData icon,
    Function(DateTime) onTimeSelected,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(label),
        subtitle: Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(time),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  alwaysUse24HourFormat: true,
                ),
                child: child!,
              );
            },
          ).then((t) {
            if (t == null) return null;
            return TimeOfDay(
              hour: t.hour,
              minute: (t.minute / 30).floor() * 30,
            );
          });
          
          if (picked != null) {
            final selected = DateTime(
              time.year,
              time.month,
              time.day,
              picked.hour,
              picked.minute,
            );
            onTimeSelected(selected);
          }
        },
      ),
    );
  }

  Widget _buildDurationSummary(BuildContext context, DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Total Duration: ${hours}h ${minutes}m',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotSelectionPage() {
    if (_startTime == null || _endTime == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Please select times first',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final slotsState = ref.watch(stationSlotsWithAvailabilityProvider(widget.station.id));
        
        return slotsState.when(
          data: (slots) {
            // Fetch bookings for all slots
            final slotBookings = <String, List<BookingModel>>{};
            
            for (final slot in slots) {
              final bookingsState = ref.watch(slotAvailabilityProvider(slot.id));
              bookingsState.whenData((bookings) {
                slotBookings[slot.id] = bookings;
              });
            }
            
            return _buildSlotsGrid(slots, slotBookings);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading slots: $error'),
          ),
        );
      },
    );
  }

  Widget _buildSlotsGrid(List<SlotModel> slots, Map<String, List<BookingModel>> slotBookings) {
    // Filter slots to only show those available during the selected time period
    final availableSlots = slots.where((slot) {
      final bookings = slotBookings[slot.id] ?? [];
      return _isSlotAvailable(slot, bookings);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a Slot',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose from available slots during your selected time',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${availableSlots.length} of ${slots.length} slots available',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          
          if (availableSlots.isEmpty)
            _buildNoSlotsAvailable()
          else
            ...availableSlots.map((slot) {
              final isSelected = slot.id == _selectedSlotId;
              final bookings = slotBookings[slot.id] ?? [];
              final isAvailable = _isSlotAvailable(slot, bookings);
              
              return _buildSlotCard(context, slot, isSelected, bookings, isAvailable);
            }),
        ],
      ),
    );
  }

  Widget _buildNoSlotsAvailable() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Slots Available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No slots are available during your selected time period. Please try a different time.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Text('Change Time'),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(
    BuildContext context,
    SlotModel slot,
    bool isSelected,
    List<BookingModel> bookings,
    bool isAvailable,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : isAvailable
                  ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isAvailable ? () {
          setState(() {
            _selectedSlotId = isSelected ? null : slot.id;
          });
        } : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : isAvailable
                          ? Colors.green
                          : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${slot.slotIndex + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (slot.type == SlotType.chargingPad)
                      const Icon(
                        Icons.bolt,
                        size: 16,
                        color: Colors.white,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Slot ${slot.slotIndex + 1}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSlotTypeText(slot.type),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAvailable ? 'Free' : 'Occupied',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isAvailable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected 
                    ? Icons.radio_button_checked 
                    : Icons.radio_button_unchecked,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildReviewPage() {
    if (_startTime == null || _endTime == null || _selectedSlotId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text('Please complete all steps'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Booking',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Confirm your booking details',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          
          _buildReviewCard(),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    return Consumer(
      builder: (context, ref, child) {
        final slotsState = ref.read(stationSlotsWithAvailabilityProvider(widget.station.id));
        final slot = slotsState.value?.firstWhere((s) => s.id == _selectedSlotId);
        
        if (slot == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final duration = _endTime!.difference(_startTime!);
        final hours = duration.inHours;
        final minutes = duration.inMinutes % 60;
        final price = (duration.inMinutes / 60.0).ceil() * widget.station.pricePerHour;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Booking Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSummaryRow('Station', widget.station.name),
              _buildSummaryRow('Slot', '${slot.slotIndex + 1} (${_getSlotTypeText(slot.type)})'),
              _buildSummaryRow('Start Time', _formatTime(_startTime!)),
              _buildSummaryRow('End Time', _formatTime(_endTime!)),
              _buildSummaryRow('Duration', '${hours}h ${minutes}m'),
              const Divider(height: 32),
              _buildSummaryRow('Price per Hour', '₹${widget.station.pricePerHour.toStringAsFixed(0)}'),
              _buildSummaryRow('Total', '₹${price.toStringAsFixed(0)}', isTotal: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousPage,
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep < 2) {
                    _nextPage();
                  } else {
                    _confirmBooking();
                  }
                },
                child: Text(_currentStep < 2 ? 'Next' : 'Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBooking() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to book')),
      );
      return;
    }

    if (_startTime == null || _endTime == null || _selectedSlotId == null) return;

    final duration = _endTime!.difference(_startTime!);
    final durationHours = (duration.inMinutes / 60.0).ceil();

    try {
      await ref.read(createBookingNotifierProvider.notifier).createBooking(
        userId: user.uid,
        stationId: widget.station.id,
        slotId: _selectedSlotId!,
        durationHours: durationHours,
        pricePerHour: widget.station.pricePerHour,
        customStartTime: _startTime,
      );

      final bookingState = ref.read(createBookingNotifierProvider);
      bookingState.whenData((booking) {
        if (booking != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BookingConfirmationScreen(booking: booking),
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  bool _isSlotAvailable(SlotModel slot, List<BookingModel> bookings) {
    if (slot.status == SlotStatus.occupied || slot.status == SlotStatus.maintenance) {
      return false;
    }

    for (final booking in bookings) {
      final start = booking.startTime;
      final end = booking.endTime ?? start.add(Duration(hours: booking.durationHours));
      
      if (_startTime!.isBefore(end) && _endTime!.isAfter(start)) {
        return false;
      }
    }
    
    return true;
  }


  String _getSlotTypeText(SlotType type) {
    switch (type) {
      case SlotType.parkingSpace:
        return 'Parking Space';
      case SlotType.chargingPad:
        return 'Charging Pad';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  DateTime _getNext30MinuteInterval() {
    final now = DateTime.now();
    final currentMinute = now.minute;
    
    // Round up to the next 30-minute interval
    if (currentMinute <= 30) {
      // Round to :30 if we're before or at :30
      return DateTime(now.year, now.month, now.day, now.hour, 30);
    } else {
      // Round to next hour :00 if we're after :30
      return DateTime(now.year, now.month, now.day, now.hour + 1, 0);
    }
  }
}

