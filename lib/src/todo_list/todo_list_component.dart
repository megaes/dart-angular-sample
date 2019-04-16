import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import '../services/http_service.dart';
import '../time_line/time_line_component.dart';

@Component(
  selector: 'todo-list',
  styleUrls: ['todo_list_component.css'],
  templateUrl: 'todo_list_component.html',
  directives: [
    MaterialCheckboxComponent,
    MaterialFabComponent,
    MaterialIconComponent,
    materialInputDirectives,
    NgFor,
    NgIf,
    TimeLineComponent
  ],
)
class TodoListComponent implements OnInit {
  final HttpService _httpService;

  Map<int, String> items = {};

  String objName = '';

  TodoListComponent(this._httpService);

  @override
  void ngOnInit() {
  }

  void add() {
    int objID = _httpService.trackNewObject();
    items[objID] = objName;
    objName = '';
  }

  void remove(int id) {
    items.remove(id);
  }
}
