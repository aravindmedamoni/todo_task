
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todotask/model/taskdata.dart';

class TaskSaveDialog extends StatefulWidget {
  final TaskData taskData;
  final int indexId;
  TaskSaveDialog({this.taskData, this.indexId});

  @override
  _TaskSaveDialogState createState() => _TaskSaveDialogState();
}

class _TaskSaveDialogState extends State<TaskSaveDialog> {
  //task status
  final coffeeNames = ['pending','completed'];
  final _formKey = GlobalKey<FormState>();

  TextEditingController taskNameController = TextEditingController();

  //TextEditingController statusController = TextEditingController();

  bool isEditing = false;
  TaskData task;
  String taskStatus;
  @override
  void initState() {
    super.initState();
    if(widget.indexId!=null){
      isEditing = true;
      task = widget.taskData;
      taskStatus = task.status;
      taskNameController.text = task.taskName;
      // statusController.text = task.status;
      //taskStatus = task.status;
    }else{
      taskStatus = null;
    }

  }

  @override
  Widget build(BuildContext context) {

    return Container(
        child: Card(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 80.0,horizontal: 30.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 10.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(isEditing ? 'Editing the Task' : 'Create New Task',style: TextStyle(
                      color: Colors.indigoAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0
                  ),),
                  SizedBox(
                    height: 30.0,
                  ),
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: TextFormField(
                      controller: taskNameController,
                      validator: (taskName) => taskName.isEmpty? 'please enter task' : null,
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500),
                      onChanged: (value) {
                        updateTitle();
                      },
                      decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(
                            fontSize: 18.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text('Task Status', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),),
                  ),
                  Column(
                    children: createRadioListCoffees(),
                  ),
//              Padding(
//                padding: EdgeInsets.all(15.0),
//                child: TextFormField(
//                  controller: statusController,
//                  style: TextStyle(
//                      color: Colors.black54,
//                      fontSize: 16.0,
//                      fontWeight: FontWeight.w500),
//                  decoration: InputDecoration(
//                    labelText: 'task status',
//                      labelStyle: TextStyle(
//                        fontSize: 18.0,
//                      ),
//                    border: OutlineInputBorder(
//                        borderRadius: BorderRadius.circular(10.0),
//                      )
//                  ),
//                    validator: (status) => status.isEmpty? 'please enter task' : null,
//                  onChanged: (value) {
//                    updateStatus();
//                  },
//                ),
//              ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height/18,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      MaterialButton(
                        color: Colors.orange[50],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 12.0),
                          child: Text('Cancle',style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),),
                        ),
                      ),
                      MaterialButton(
                          color: Colors.green[50],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 12.0),
                            child: Text('Save',style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold
                            ),),
                          ),
                          onPressed: (){
                            if(_formKey.currentState.validate()){
                              TaskData task = TaskData(taskName: taskNameController.text,status: taskStatus);
                              if(widget.indexId!=null){
                                updateTask(task);
                              }else{
                                saveTask(task);
                              }
                              Navigator.pop(context);
                            }
                          }),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }

  void saveTask(TaskData task) {
    // print('Task Name:${task.taskName}');
    final taskBox = Hive.box('todo');
    taskBox.add(task);
  }

  void updateTask(TaskData task) {
    final taskBox = Hive.box('todo');
    taskBox.putAt(widget.indexId,task);
  }

  void updateTitle() {
    task.taskName = taskNameController.text;
  }
  void setSelectedStatus(String value) {
    setState(() {
      taskStatus = value;
    });
  }

//  void updateStatus() {
//    task.status = statusController.text;
//  }

  List<Widget> createRadioListCoffees() {
    final List<Widget> taskStatusListWidget = <Widget>[];
    for (final String status in coffeeNames) {
      taskStatusListWidget.add(Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            // ignore: always_specify_types
            child: RadioListTile(
              value: status,
              groupValue: taskStatus,
              title: Text(status),
              // ignore: always_specify_types
              onChanged: (newStatus) {
                // print('task status $coffeeName');
                setSelectedStatus(newStatus);

              },
              selected: taskStatus == status,
              activeColor: Colors.deepOrange,
            ),
          ),
        ],
      ));
    }
    return taskStatusListWidget;
  }

}