import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo_data.dart';
import '../core/app_colors.dart';
import '../core/app_utils.dart';
import '../provider/data_provider.dart';
import '../widgets/logout_dialog_widget.dart';

class TodoListScreen extends StatefulWidget {
  final BuildContext ctxForProgressDialog;
  const TodoListScreen({Key? key, required this.ctxForProgressDialog})
      : super(key: key);

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  DataProvider? _dataProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dataProvider == null) {
      _dataProvider = Provider.of<DataProvider>(context);
      _updateUI();
      Future.delayed(Duration.zero).then((_) {
        _dataProvider!.clearTodoList();
        _fetchTodos();
      });
    }
  }

  void _fetchTodos() {
    AppUtils.showProgressBar(context);
    _dataProvider!.fetchTodos(context).then(
          (_) => Navigator.of(context).pop(),
        );
  }

  void _addTodos() {
    AppUtils.showProgressBar(context);
    _dataProvider!
        .addTodo(
      context: context,
      todoData: TodoData(
        taskName: "Dummy test",
        taskDesc: "This is a dummy todo for testing",
        taskTime: DateTime.now().toIso8601String(),
      ),
    )
        .then(
      (_) {
        Navigator.of(context).pop();
        _fetchTodos();
      },
    );
  }

  void _deleteTodo(String documentId) {
    AppUtils.showProgressBar(context);
    _dataProvider!
        .deleteTodo(
      context: context,
      docId: documentId,
    )
        .then(
      (_) {
        Navigator.of(context).pop();
        _fetchTodos();
      },
    );
  }

  void _updateTodo(TodoData todoData) {
    AppUtils.showProgressBar(context);
    _dataProvider!
        .updateTodo(
      context: context,
      todoData: TodoData(
        docId: todoData.docId,
        taskName: todoData.taskName,
        taskDesc: todoData.taskDesc,
        taskTime: todoData.taskTime,
        isCompleted: todoData.isCompleted,
      ),
    )
        .then(
      (_) {
        Navigator.of(context).pop();
        _fetchTodos();
      },
    );
  }

  void _updateUI() {
    if (mounted) {
      setState(() {});
    }
  }

  String _getFormattedDate(String dateString) =>
      "${DateTime.parse(dateString).day}\n${DateFormat.MMM().format(DateTime.parse(dateString))} '${DateTime.parse(dateString).year.toString().substring(2)}";

  String _getFormattedTime(String dateString) => DateFormat.jm().format(
        DateTime.parse(dateString),
      );

  void _logout() {
    AppUtils.showProgressBar(widget.ctxForProgressDialog);
    _dataProvider!.signOut(context).then(
      (_) {
        Navigator.of(widget.ctxForProgressDialog).pop();
        _dataProvider!.clearTodoList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _dataProvider == null
        ? const SizedBox()
        : Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.menu,
                              color: AppColors.accentColor,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              _dataProvider!.localization.todosTitleText,
                              style: const TextStyle(
                                color: AppColors.accentColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => LogoutDialog(
                                logout: _logout,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.account_circle,
                            color: AppColors.accentColor,
                          ),
                          label: Text(
                            _dataProvider!.localization.userText,
                            style: const TextStyle(
                              color: AppColors.accentColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    color: AppColors.white12Color,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _dataProvider!.todosList.isEmpty
                        ? Center(
                            child: Text(
                              _dataProvider!.localization.noTodoAddedText,
                              style: const TextStyle(
                                color: AppColors.accentColor,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemBuilder: (ctx, i) => Container(
                              margin: i == _dataProvider!.todosList.length - 1
                                  ? const EdgeInsets.only(bottom: 100)
                                  : EdgeInsets.zero,
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppColors.white70Color,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            _getFormattedDate(
                                              _dataProvider!
                                                  .todosList[i].taskTime,
                                            ),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: AppColors.accentColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  _dataProvider!
                                                      .todosList[i].taskName,
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.accentColor,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 7),
                                              Flexible(
                                                child: Text(
                                                  _dataProvider!
                                                      .todosList[i].taskDesc,
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.white70Color,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _getFormattedTime(
                                          _dataProvider!.todosList[i].taskTime,
                                        ),
                                        style: const TextStyle(
                                          color: AppColors.accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () => _updateTodo(
                                          TodoData(
                                            docId: _dataProvider!
                                                .todosList[i].docId,
                                            taskName: _dataProvider!
                                                .todosList[i].taskName,
                                            taskDesc: _dataProvider!
                                                .todosList[i].taskDesc,
                                            taskTime: DateTime.now()
                                                .toIso8601String(),
                                            isCompleted: _dataProvider!
                                                .todosList[i].isCompleted,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.edit,
                                          color: AppColors.accentColor,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      IconButton(
                                        onPressed: () => _deleteTodo(
                                          _dataProvider!.todosList[i].docId,
                                        ),
                                        icon: const Icon(
                                          Icons.delete,
                                          color: AppColors.accentColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _dataProvider!.localization.doneText,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppColors.accentColor,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Theme(
                                        data: ThemeData(
                                          unselectedWidgetColor:
                                              AppColors.white70Color,
                                        ),
                                        child: Checkbox(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: _dataProvider!
                                              .todosList[i].isCompleted,
                                          onChanged: (value) {
                                            _updateTodo(
                                              TodoData(
                                                docId: _dataProvider!
                                                    .todosList[i].docId,
                                                taskName: _dataProvider!
                                                    .todosList[i].taskName,
                                                taskDesc: _dataProvider!
                                                    .todosList[i].taskDesc,
                                                taskTime: _dataProvider!
                                                    .todosList[i].taskTime,
                                                isCompleted: value!,
                                              ),
                                            );
                                          },
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      )
                                    ],
                                  ),
                                  const Divider(
                                    color: AppColors.accentColor,
                                  ),
                                ],
                              ),
                            ),
                            itemCount: _dataProvider!.todosList.length,
                          ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(
                  right: 25,
                  bottom: 30,
                ),
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      AppColors.primaryColor,
                    ),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.all(15),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    elevation: MaterialStateProperty.all(5),
                    shadowColor: MaterialStateProperty.all(Colors.black),
                  ),
                  onPressed: _addTodos,
                  icon: const Icon(
                    Icons.add,
                    color: AppColors.accentColor,
                  ),
                  label: Text(
                    _dataProvider!.localization.addTodoText,
                    style: const TextStyle(
                      color: AppColors.accentColor,
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
