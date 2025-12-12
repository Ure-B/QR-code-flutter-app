import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class EventProvider extends ChangeNotifier {
  List<EventModel> _events = [];
  EventModel? _selectedEvent;
  bool _loading = false;

  List<EventModel> get events => _events;
  EventModel? get selectedEvent => _selectedEvent;
  bool get loading => _loading;

  Future<void> loadEvents(String token) async {
    _loading = true;
    notifyListeners();
    try {
      final api = ApiService(token: token);
      _events = await api.listEvents();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void selectEvent(EventModel event) {
    _selectedEvent = event;
    notifyListeners();
  }

  void clearSelection() {
    _selectedEvent = null;
    notifyListeners();
  }
}
