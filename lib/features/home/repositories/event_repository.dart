import '../models/event.dart';

abstract class EventRepository {
  List<Event> fetchEvents();
}
