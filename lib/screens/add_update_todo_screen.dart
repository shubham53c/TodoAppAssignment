import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo_data.dart';
import '../core/app_colors.dart';
import '../core/app_utils.dart';
import '../provider/data_provider.dart';

class AddUpdateTodoScreen extends StatefulWidget {
  final String pageTitle;
  final Function submitFunction;
  final TodoData? todoData;
  const AddUpdateTodoScreen({
    Key? key,
    required this.pageTitle,
    required this.submitFunction,
    this.todoData,
  }) : super(key: key);

  @override
  State<AddUpdateTodoScreen> createState() => _AddUpdateTodoScreenState();
}

class _AddUpdateTodoScreenState extends State<AddUpdateTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionFocusNode = FocusNode();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  var _selectedDateString = "";
  var _selectedTimeString = "";
  DateTime? _finalTodoDate;
  DataProvider? _dataProvider;
  var _todoName = "";
  var _todoDesc = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dataProvider == null) {
      _dataProvider = Provider.of<DataProvider>(context, listen: false);
      _selectedDateString = _dataProvider!.localization.selectDateText;
      _selectedTimeString = _dataProvider!.localization.selectTimeText;
      if (widget.todoData != null) {
        _todoName = widget.todoData!.taskName;
        _todoDesc = widget.todoData!.taskDesc;
        _selectedDate = DateTime.parse(widget.todoData!.taskTime);
        _selectedTime = TimeOfDay(
          hour: _selectedDate!.hour,
          minute: _selectedDate!.minute,
        );
        _finalTodoDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
        _selectedDateString = DateFormat.yMMMEd().format(_finalTodoDate!);
        _selectedTimeString = DateFormat.jm().format(_finalTodoDate!);
      }
      _updateUI();
    }
  }

  void _updateUI() {
    if (mounted) {
      setState(() {});
    }
  }

  String? _todoNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return _dataProvider!.localization.formValidationErrorMessage;
    }
    _todoName = value;
    return null;
  }

  String? _todoDescriptionValidator(String? value) {
    if (value == null || value.isEmpty) {
      return _dataProvider!.localization.formValidationErrorMessage;
    }
    _todoDesc = value;
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _finalTodoDate == null) {
      AppUtils.showErrorSnackbar(
        context: context,
        message: _dataProvider!.localization.allFieldsAreRequiredMessageText,
      );
    } else {
      Navigator.of(context).pop();
      if (widget.todoData == null) {
        widget.submitFunction(
          TodoData(
            taskName: _todoName,
            taskDesc: _todoDesc,
            taskTime: _finalTodoDate!.toIso8601String(),
          ),
        );
      } else {
        widget.submitFunction(
          TodoData(
            docId: widget.todoData!.docId,
            taskName: _todoName,
            taskDesc: _todoDesc,
            taskTime: _finalTodoDate!.toIso8601String(),
            isCompleted: widget.todoData!.isCompleted,
          ),
        );
      }
    }
  }

  Widget _textFormField({
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
    FocusNode? focusNode,
    Function(String)? onFieldSubmitted,
    required String labelText,
    required String initialValue,
  }) {
    const accentColor = AppColors.accentColor;
    const errorColor = AppColors.errorColor;
    const textSize = 13.0;
    final inputBorder = OutlineInputBorder(
      borderSide: const BorderSide(
        color: accentColor,
      ),
      borderRadius: BorderRadius.circular(50),
    );
    final errorInputBorder = OutlineInputBorder(
      borderSide: const BorderSide(
        color: errorColor,
      ),
      borderRadius: BorderRadius.circular(50),
    );
    return TextFormField(
      initialValue: initialValue,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      cursorColor: accentColor,
      style: const TextStyle(
        color: accentColor,
        fontSize: textSize,
      ),
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: InputDecoration(
        isDense: true,
        label: Text(labelText),
        errorBorder: errorInputBorder,
        focusedErrorBorder: errorInputBorder,
        errorStyle: const TextStyle(
          color: accentColor,
        ),
        focusColor: accentColor,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder,
        border: inputBorder,
        labelStyle: const TextStyle(
          color: accentColor,
          fontSize: textSize,
        ),
      ),
    );
  }

  Widget _timePickerWidget() => GestureDetector(
        onTap: () async {
          if (_selectedDate != null) {
            _selectedTime = await AppUtils.showTimePickerDialog(context);
            if (_selectedTime == null) {
              AppUtils.showErrorSnackbar(
                context: context,
                message:
                    _dataProvider!.localization.invalidTimeSelectedErrorText,
              );
              _selectedTimeString = _dataProvider!.localization.selectTimeText;
              _finalTodoDate = null;
            } else {
              _finalTodoDate = DateTime(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
                _selectedTime!.hour,
                _selectedTime!.minute,
              );
              _selectedTimeString = DateFormat.jm().format(_finalTodoDate!);
            }
            _updateUI();
          } else {
            AppUtils.showErrorSnackbar(
              context: context,
              message: _dataProvider!.localization.dateNotSelectedErrorText,
            );
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.accentColor,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            _selectedTimeString,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.accentColor,
            ),
          ),
        ),
      );

  Widget _datePickerWidget() => GestureDetector(
        onTap: () async {
          _selectedDate = await AppUtils.showDatePickerDialog(context);
          _finalTodoDate = null;
          _selectedTime = null;
          _selectedTimeString = _dataProvider!.localization.selectTimeText;
          if (_selectedDate == null) {
            AppUtils.showErrorSnackbar(
              context: context,
              message: _dataProvider!.localization.invalidDateSelectedErrorText,
            );
            _selectedDateString = _dataProvider!.localization.selectDateText;
          } else {
            _selectedDateString = DateFormat.yMMMEd().format(_selectedDate!);
          }
          _updateUI();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.accentColor,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            _selectedDateString,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.accentColor,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.accentColor,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.pageTitle,
                    style: const TextStyle(
                      color: AppColors.accentColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: AppColors.white12Color,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const SizedBox(height: 10),
                      _textFormField(
                        initialValue: _todoName,
                        labelText: _dataProvider!.localization.nameLabelText,
                        textCapitalization: TextCapitalization.words,
                        onFieldSubmitted: (_) {
                          _descriptionFocusNode.requestFocus();
                        },
                        textInputAction: TextInputAction.go,
                        validator: _todoNameValidator,
                      ),
                      const SizedBox(height: 20),
                      _textFormField(
                        initialValue: _todoDesc,
                        labelText:
                            _dataProvider!.localization.descriptionLabelText,
                        focusNode: _descriptionFocusNode,
                        validator: _todoDescriptionValidator,
                      ),
                      const SizedBox(height: 20),
                      _datePickerWidget(),
                      const SizedBox(height: 20),
                      _timePickerWidget(),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                AppColors.accentColor,
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
                              shadowColor: MaterialStateProperty.all(
                                AppColors.shadowColor,
                              ),
                            ),
                            onPressed: _submit,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              child: Text(
                                widget.pageTitle,
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
