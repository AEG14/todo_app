import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'todo_item.dart';
import 'todo_service.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter((await getApplicationDocumentsDirectory()).path);
  Hive.registerAdapter(TodoItemAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final TodoService _todoService = TodoService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive TODO List',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _todoService.getAllTodos(),
        builder: (context, AsyncSnapshot<List<TodoItem>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return TodoListPage(snapshot.data ?? []);
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

class TodoListPage extends StatefulWidget {
  final List<TodoItem> todos;

  TodoListPage(this.todos);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TodoService _todoService = TodoService();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, MMMM d').format(now);
    const Color tMidnightBlue = Color(0xFF19202D);
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  '$formattedDate',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w300,
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      color: Color.fromARGB(255, 155, 155, 155),
                      height: 1.0),
                ),
                Text(
                  "To Do List",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: Color(0xff182a52),
                      fontSize: MediaQuery.of(context).size.width * 0.07,
                      height: 1.3),
                ),
              ],
            ),
            elevation: 0.0,
            backgroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
            child: ValueListenableBuilder(
              valueListenable: Hive.box<TodoItem>('todoBox').listenable(),
              builder: (context, Box<TodoItem> box, _) {
                return ListView.builder(
                  itemCount: box.values.length,
                  itemBuilder: (context, index) {
                    var todo = box.getAt(index);
                    Color backgroundColor = Colors.white;

                    if (todo != null) {}

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: tMidnightBlue.withOpacity(0.051),
                              offset: const Offset(0.0, 3.0),
                              blurRadius: 24.0,
                              spreadRadius: 0.0,
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 3.5),
                          title: Text(
                            todo!.title,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.033,
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          leading: Theme(
                            data: ThemeData(
                              checkboxTheme: CheckboxThemeData(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            ),
                            child: Checkbox(
                              value: todo.isCompleted,
                              onChanged: (val) {
                                _todoService.toggleCompleted(index, todo);
                              },
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 25,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: MediaQuery.of(context).size.height *
                                        0.030,
                                  ),
                                  onPressed: () async {
                                    _controller.text = todo.title;
                                    var editedTodo = await showDialog<TodoItem>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24)),
                                          title: Text(
                                            'Edit Task',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          content: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: TextField(
                                                controller: _controller,
                                                maxLines: null,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Edit the task',
                                                  hintStyle:
                                                      GoogleFonts.poppins(
                                                    color: Colors.grey,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.03,
                                                  ),
                                                ),
                                                style: GoogleFonts.poppins(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.03,
                                                ),
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              child: Text(
                                                'Save',
                                                style: GoogleFonts.poppins(),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          24.0),
                                                ),
                                                elevation: 4.0,
                                              ),
                                              onPressed: () {
                                                if (_controller
                                                    .text.isNotEmpty) {
                                                  var editedTodo = TodoItem(
                                                      _controller.text);
                                                  _todoService.editTodo(
                                                      index, editedTodo);
                                                  _controller.clear();
                                                  Navigator.pop(
                                                      context, editedTodo);
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (editedTodo != null) {}
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Color(0xffe55959),
                                  size: MediaQuery.of(context).size.height *
                                      0.030,
                                ),
                                onPressed: () {
                                  _todoService.deleteTodo(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xff58f2a9),
            elevation: 2.0,
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      title: Text(
                        'Add Task',
                        style: GoogleFonts.poppins(),
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextField(
                                controller: _controller,
                                maxLines: null,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'What needs to be done?',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.03,
                                  ),
                                ),
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.03,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          child: Text(
                            'Add',
                            style: GoogleFonts.poppins(),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            elevation: 4.0,
                          ),
                          onPressed: () {
                            if (_controller.text.isNotEmpty) {
                              var todo = TodoItem(_controller.text);
                              _todoService.addTodo(todo);
                              _controller.clear();
                              Navigator.pop(context);
                            }
                          },
                        )
                      ],
                    );
                  });
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
