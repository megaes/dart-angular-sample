import 'dart:async';
import 'package:angular/angular.dart';

import './state.dart';
import '../services/http_service.dart';

@Component(
  selector: 'time-line',
  styleUrls: ['time_line_component.css'],
  templateUrl: 'time_line_component.html',
  directives: [
    NgFor,
    NgIf,
    NgStyle
  ],
  pipes: [commonPipes]
)
class TimeLineComponent implements OnInit, OnDestroy {
  @Input()
  int objectID;

  HttpService _httpService;
  StreamSubscription _serverSubscription;

  final List<State> states = [State(), State()];

  TimeLineComponent(this._httpService);

  @override
  void ngOnInit() {
    _serverSubscription = _httpService.server.listen((Map<String, dynamic> data) {
      if(data['id'] != objectID) {
        return;
      }

      try {
        var state = states.firstWhere((state) => state.name == data['state']);
        state.progress = data['progress'];
      } catch (_) {
        int index = states.indexWhere((state) => state.name == '');
        states.insert(index, State(data['time'], data['state']));
      }

      _evaluate(data['time']);
    });

    _evaluate();
  }

  @override
  void ngOnDestroy() {
    _serverSubscription.cancel();
  }

  Map<String, String> setColorBar(int x) {
    return {
      'background': 'linear-gradient(to right, #4285f4 ${x}%, #0000001f ${x}%)'
    };
  }

  Map<String, String> setColorDot(bool isDefault) {
    return {
      'background-color': isDefault ? 'white' : '#4285f4',
      'border': '1px solid ${isDefault ? '#0000001f' : '#4285f4'}'
    };
  }

  Map<String, String> setWidth(double width) {
    return {
      'width': '${width}%',
    };
  }

  Map<String, String> setTxtOverflow(int index) {
    bool txtOverflow = (states[index].name != '') && (states[index + 1].name == '');
    return {
      'overflow': txtOverflow ? 'visible' : 'hidden',
      'white-space': 'nowrap',
      'text-overflow': 'ellipsis',
    };
  }

  Map<String, String> setCaptionStyle(int index) {
    var style = setTxtOverflow(index);
    style['width'] = '${states[index].width}%';
    return style;
  }

  void _evaluate([DateTime timeNow]) {
    var timeLast = states.first.time;

    List<double> timeList = [];
    for(var i = 0; (states[i].progress > 0.001); ++i) {
      var time = (states[i + 1].time ?? timeNow);
      timeList.add(time.difference(timeLast).inMicroseconds / states[i].progress);
      timeLast = time;
    }

    for(var i = 0; i < states.length; ++i) {
      states[i].width = (i != 0) ? 0.01 * states[i - 1].progress : 1.0;
    }

    var sum1 = timeList.fold(0.0, (sum, time) => sum + time);
    var sum2 = states.take(timeList.length).fold(0.0, (sum, state) => sum + state.width);

    for(var i = 0; i < timeList.length; ++i) {
      states[i].width = (sum2 / sum1) * timeList[i];
    }

    var invSum = 100.0 / states.fold(0.0, (sum, state) => sum + state.width);

    states.forEach((state) => state.width *= invSum);
  }
}
