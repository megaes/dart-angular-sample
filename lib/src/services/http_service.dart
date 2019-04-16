import 'dart:math';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'dart:collection';

class HttpService {
  List<Queue<Map<String, dynamic>>> _listQueues = [];

  final server = PublishSubject<Map<String, dynamic>>();

  HttpService() {
    Timer.periodic(Duration(milliseconds: 1000), (Timer timer) {
      _listQueues.forEach((queue) => server.add(queue.removeFirst()));
      _listQueues.removeWhere((queue) => queue.isEmpty);
    });
  }

  int _lerp(double k, int min, int max) => (min * (1.0 - k) + max * k).floor();

  Map<String, dynamic> _state([int id, DateTime time, String state, int progress]) {
    return {
      'id':       id,
      'time':     time,
      'state':    state,
      'progress': progress
    };
  }

  DateTime _progress(Queue<Map<String, dynamic>> queue, int id, DateTime time, String state, int duration, int stepCount) {
    for(int i = 0; i < stepCount; ++i) {
      double k = i / (stepCount - 1);
      queue.add(_state(id, time.add(Duration(milliseconds: _lerp(k, 0, duration))), state, _lerp(k, 0, 100)));
    }

    return time.add(Duration(milliseconds: duration));
  }


  int trackNewObject() {
    var time = DateTime.now();
    var id = time.hashCode;
    var rnd = Random();

    Queue<Map<String, dynamic>> queue = Queue();

    queue.add(_state());

    time = _progress(queue, id, time, 'Регистрация', 2000, 3);
    time = _progress(queue, id, time, 'В очереди', _lerp(rnd.nextDouble(), 2000, 5000), _lerp(rnd.nextDouble(), 3, 9));
    time = _progress(queue, id, time, 'Передача', _lerp(rnd.nextDouble(), 6000, 15000), _lerp(rnd.nextDouble(), 8, 14));
    time = _progress(queue, id, time, 'Контроль целостности', _lerp(rnd.nextDouble(), 3000, 6000), _lerp(rnd.nextDouble(), 4, 10));

    queue.add(_state(id, time, 'Выгружено', 0));

    _listQueues.add(queue);
    return id;
  }

}
