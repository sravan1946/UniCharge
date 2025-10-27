import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:unicharge/providers/booking_provider.dart';
import 'package:unicharge/services/qr_token_service.dart';
import 'package:unicharge/services/firestore_database_service.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onScanResult(String code) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    try {
      // Extract booking ID from QR token
      final bookingId = QrTokenService.getBookingIdFromToken(code);
      
      if (bookingId == null) {
        _showError('Invalid QR code format');
        return;
      }
      
      // Verify the token
      if (!QrTokenService.verifyToken(code, bookingId)) {
        _showError('Invalid or expired QR code');
        return;
      }
      
      // Get booking details
      final databaseService = FirestoreDatabaseService();
      final booking = await databaseService.getBookingById(bookingId);
      
      if (booking == null) {
        _showError('Booking not found');
        return;
      }
      
      // Check if already activated
      if (booking.status.name == 'active') {
        _showError('Booking already activated');
        return;
      }
      
      if (booking.status.name != 'reserved') {
        _showError('Booking is not in reserved status');
        return;
      }
      
      // Activate the booking
      await ref.read(bookingStateProvider.notifier).activateBooking(
        bookingId: booking.id,
        slotId: booking.slotId,
      );
      
      // Show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking activated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Wait a bit then go back
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showError('Error processing QR code: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }
  
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
    // Resume scanning after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_isProcessing) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Booking QR Code'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Camera scanner
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _onScanResult(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          
          // Overlay with instructions
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Column(
              children: [
                const Spacer(),
                
                // Scanning area indicator
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isProcessing ? Colors.green : Colors.white,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Instructions
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isProcessing
                              ? 'Processing...'
                              : 'Position the QR code within the frame',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isProcessing
                              ? 'Please wait'
                              : 'Scan the booking QR code shown by the customer',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isProcessing = false;
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

