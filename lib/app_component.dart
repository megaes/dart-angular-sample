import 'package:angular/angular.dart';

import 'src/todo_list/todo_list_component.dart';
import 'src/services/http_service.dart';

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [TodoListComponent],
  providers: [ClassProvider(HttpService)],
)
class AppComponent {
}
