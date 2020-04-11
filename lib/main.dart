import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:todotask/components/task_save_dialog.dart';
import 'package:todotask/model/taskdata.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final getDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(getDocumentDirectory.path);
  Hive.registerAdapter(TaskDataAdapter());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: FutureBuilder(
        future: Hive.openBox('todo'),
          builder: (BuildContext context,AsyncSnapshot snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              if(!snapshot.hasData){
                return Center(child: Text(snapshot.error.toString()),);
              }else{
                return MyHomePage();
              }
            }else{
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }
          }),
    );
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    int totalTasks=Hive.box('todo').length;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          ClipPath(
            clipper: ClipperClass(),
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.deepOrange,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 30, bottom: 10, left: 6, right: 6),
                  child: Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.format_list_bulleted,
                                size: 35.0,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Todos',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Text('Total tasks $totalTasks', style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600
                          ),),
                        ],
                      ),
                      Spacer(),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: IconButton(
                            icon: Icon(
                              Icons.control_point,
                              size: 35,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (_) {
                                    return TaskSaveDialog();
                                  });
                            }),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: WatchBoxBuilder(
                    box: Hive.box('todo'),
                    builder: (context,taskBox){
                      return ListView.builder(
                          itemCount: taskBox.length,
                          itemBuilder: (context, index) {
                            TaskData task = taskBox.getAt(index) as TaskData;
                            return GestureDetector(
                              onTap: (){
                               showDialog(context: context,builder: (_){
                                 return  TaskSaveDialog(indexId: index,taskData: task,);
                               });
                              },
                              child: Container(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 10.0),
                                    child: Row(
                                      children: <Widget>[
                                        Flexible(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                '${task.taskName}',
                                                style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.w800),
                                              ),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Icon(
                                                    getIcon(task.status),
                                                    size: 26,
                                                    color:getColor(task.status),
                                                  ),
                                                  SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text(
                                                    '${task.status}',
                                                    style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 16.0,
                                                        fontWeight: FontWeight.w600),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                          fit: FlexFit.loose,
                                        ),
                                        IconButton(icon: Icon(
                                          Icons.cancel,
                                          size: 30,
                                          color: Colors.red,
                                        ), onPressed: (){
                                          taskBox.deleteAt(index);
                                          setState(() {});
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  IconData getIcon(String status) {
    if(status == 'pending'){
      return Icons.info_outline;
    }else{
      return Icons.check_circle;
    }
  }

  Color getColor(String status) {
    if(status == 'pending'){
      return Colors.amber;
    }else{
      return Colors.green;
    }
  }
}

class ClipperClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height / 4);
    path.quadraticBezierTo(3, size.height / 6.2, size.width / 6, size.height / 6.2);
    // path.quadraticBezierTo(size.width-(size.width/28), size.height/6, size.width, size.height/8.2);
    path.lineTo(size.width, size.height / 6.2);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}


