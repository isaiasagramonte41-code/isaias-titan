class MemoryService {
  final List<String> _history = [];

  void saveMessage(String message) {
    _history.add(message);
  }

  List<String> getHistory() {
    return List.unmodifiable(_history);
  }

  void clear() {
    _history.clear();
  }
}