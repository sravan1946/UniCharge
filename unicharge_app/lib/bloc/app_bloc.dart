import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../models/station.dart';
import '../models/slot.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../services/appwrite_service.dart';
import '../services/location_service.dart';

// Events
abstract class AppEvent {}

class LoadStations extends AppEvent {}
class LoadStationDetails extends AppEvent {
  final String stationId;
  LoadStationDetails(this.stationId);
}
class LoadSlots extends AppEvent {
  final String stationId;
  LoadSlots(this.stationId);
}
class LoadUserBookings extends AppEvent {}
class SignIn extends AppEvent {
  final String email;
  final String password;
  SignIn(this.email, this.password);
}
class SignUp extends AppEvent {
  final String email;
  final String password;
  final String name;
  SignUp(this.email, this.password, this.name);
}
class SignOut extends AppEvent {}
class RequestLocationPermission extends AppEvent {}
class GetCurrentLocation extends AppEvent {}
class ReserveSlot extends AppEvent {
  final String slotId;
  final String stationId;
  ReserveSlot(this.slotId, this.stationId);
}
class CancelBooking extends AppEvent {
  final String bookingId;
  CancelBooking(this.bookingId);
}

// States
abstract class AppState {}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppLoaded extends AppState {
  final List<Station> stations;
  final Station? selectedStation;
  final List<Slot> slots;
  final List<Booking> userBookings;
  final User? currentUser;
  final Position? currentLocation;
  final bool hasLocationPermission;

  AppLoaded({
    this.stations = const [],
    this.selectedStation,
    this.slots = const [],
    this.userBookings = const [],
    this.currentUser,
    this.currentLocation,
    this.hasLocationPermission = false,
  });

  AppLoaded copyWith({
    List<Station>? stations,
    Station? selectedStation,
    List<Slot>? slots,
    List<Booking>? userBookings,
    User? currentUser,
    Position? currentLocation,
    bool? hasLocationPermission,
  }) {
    return AppLoaded(
      stations: stations ?? this.stations,
      selectedStation: selectedStation ?? this.selectedStation,
      slots: slots ?? this.slots,
      userBookings: userBookings ?? this.userBookings,
      currentUser: currentUser ?? this.currentUser,
      currentLocation: currentLocation ?? this.currentLocation,
      hasLocationPermission: hasLocationPermission ?? this.hasLocationPermission,
    );
  }
}

class AppError extends AppState {
  final String message;
  AppError(this.message);
}

// BLoC
class AppBloc extends Bloc<AppEvent, AppState> {
  final AppwriteService _appwriteService;
  final LocationService _locationService;

  AppBloc({
    required AppwriteService appwriteService,
    required LocationService locationService,
  }) : _appwriteService = appwriteService,
       _locationService = locationService,
       super(AppInitial()) {
    on<LoadStations>(_onLoadStations);
    on<LoadStationDetails>(_onLoadStationDetails);
    on<LoadSlots>(_onLoadSlots);
    on<LoadUserBookings>(_onLoadUserBookings);
    on<SignIn>(_onSignIn);
    on<SignUp>(_onSignUp);
    on<SignOut>(_onSignOut);
    on<RequestLocationPermission>(_onRequestLocationPermission);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<ReserveSlot>(_onReserveSlot);
    on<CancelBooking>(_onCancelBooking);
  }

  Future<void> _onLoadStations(LoadStations event, Emitter<AppState> emit) async {
    try {
      emit(AppLoading());
      final stations = await _appwriteService.getStations();
      emit(AppLoaded(stations: stations));
    } catch (e) {
      emit(AppError('Failed to load stations: $e'));
    }
  }

  Future<void> _onLoadStationDetails(LoadStationDetails event, Emitter<AppState> emit) async {
    try {
      emit(AppLoading());
      final station = await _appwriteService.getStation(event.stationId);
      final currentState = state as AppLoaded;
      emit(currentState.copyWith(selectedStation: station));
    } catch (e) {
      emit(AppError('Failed to load station details: $e'));
    }
  }

  Future<void> _onLoadSlots(LoadSlots event, Emitter<AppState> emit) async {
    try {
      emit(AppLoading());
      final slots = await _appwriteService.getSlots(event.stationId);
      final currentState = state as AppLoaded;
      emit(currentState.copyWith(slots: slots));
    } catch (e) {
      emit(AppError('Failed to load slots: $e'));
    }
  }

  Future<void> _onLoadUserBookings(LoadUserBookings event, Emitter<AppState> emit) async {
    try {
      emit(AppLoading());
      final currentState = state as AppLoaded;
      if (currentState.currentUser != null) {
        final bookings = await _appwriteService.getUserBookings(currentState.currentUser!.id);
        emit(currentState.copyWith(userBookings: bookings));
      }
    } catch (e) {
      emit(AppError('Failed to load user bookings: $e'));
    }
  }

  Future<void> _onSignIn(SignIn event, Emitter<AppState> emit) async {
    try {
      emit(AppLoading());
      final user = await _appwriteService.signIn(event.email, event.password);
      final currentState = state as AppLoaded;
      emit(currentState.copyWith(currentUser: user));
    } catch (e) {
      emit(AppError('Failed to sign in: $e'));
    }
  }

  Future<void> _onSignUp(SignUp event, Emitter<AppState> emit) async {
    try {
      emit(AppLoading());
      final user = await _appwriteService.signUp(event.email, event.password, event.name);
      final currentState = state as AppLoaded;
      emit(currentState.copyWith(currentUser: user));
    } catch (e) {
      emit(AppError('Failed to sign up: $e'));
    }
  }

  Future<void> _onSignOut(SignOut event, Emitter<AppState> emit) async {
    try {
      await _appwriteService.signOut();
      final currentState = state as AppLoaded;
      emit(currentState.copyWith(currentUser: null));
    } catch (e) {
      emit(AppError('Failed to sign out: $e'));
    }
  }

  Future<void> _onRequestLocationPermission(RequestLocationPermission event, Emitter<AppState> emit) async {
    try {
      final hasPermission = await _locationService.requestLocationPermission();
      final currentState = state as AppLoaded;
      emit(currentState.copyWith(hasLocationPermission: hasPermission));
    } catch (e) {
      emit(AppError('Failed to request location permission: $e'));
    }
  }

  Future<void> _onGetCurrentLocation(GetCurrentLocation event, Emitter<AppState> emit) async {
    try {
      final position = await _locationService.getCurrentPosition();
      final currentState = state as AppLoaded;
      emit(currentState.copyWith(currentLocation: position));
    } catch (e) {
      emit(AppError('Failed to get current location: $e'));
    }
  }

  Future<void> _onReserveSlot(ReserveSlot event, Emitter<AppState> emit) async {
    try {
      emit(AppLoading());
      final currentState = state as AppLoaded;
      if (currentState.currentUser != null && currentState.selectedStation != null) {
        final booking = await _appwriteService.createBooking(
          userId: currentState.currentUser!.id,
          stationId: event.stationId,
          slotId: event.slotId,
          price: currentState.selectedStation!.pricePerHour,
        );
        
        // Update slot status to reserved
        await _appwriteService.updateSlot(event.slotId, {
          'status': 'reserved',
          'reserved_by': currentState.currentUser!.id,
        });
        
        // Reload slots and bookings
        add(LoadSlots(event.stationId));
        add(LoadUserBookings());
      }
    } catch (e) {
      emit(AppError('Failed to reserve slot: $e'));
    }
  }

  Future<void> _onCancelBooking(CancelBooking event, Emitter<AppState> emit) async {
    try {
      emit(AppLoading());
      await _appwriteService.updateBooking(event.bookingId, {
        'status': 'cancelled',
        'end_time': DateTime.now().toIso8601String(),
      });
      
      final currentState = state as AppLoaded;
      if (currentState.selectedStation != null) {
        add(LoadSlots(currentState.selectedStation!.id));
        add(LoadUserBookings());
      }
    } catch (e) {
      emit(AppError('Failed to cancel booking: $e'));
    }
  }
}
