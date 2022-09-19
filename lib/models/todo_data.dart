class TodoData {
  final String docId;
  final String taskName;
  final String taskDesc;
  final String taskTime;
  bool isCompleted;

  TodoData({
    this.docId = "",
    required this.taskName,
    required this.taskDesc,
    required this.taskTime,
    this.isCompleted = false,
  });
}
