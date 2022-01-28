import 'package:our_books/helpers/helpers.dart';
import 'package:our_books/services/database.dart';
import 'package:our_books/screens/create_quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

var data;

DatabaseService databaseService = new DatabaseService();
Stream? quizStream;

class _HomeState extends State<Home> {
  bool _connected = false;
  static String? userRole;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  checkstatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        _connected = true;
      });
    } else {
      setState(() {
        _connected = false;
      });
    }
  }

  testingfun() {
    databaseService
        .getUserQuizResult(firebaseAuth.currentUser!.uid)
        .then((value) {
      QuerySnapshot snapshotUserInfo = value;

      data = snapshotUserInfo.docs.map((documentSnapshot) {
        return documentSnapshot.get('quizId');
      });
      print(data);
      setState(() {});
    });
  }

  Widget quizList() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 3),
      child: StreamBuilder(
        stream: quizStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.data == null
              ? Container(
                  child: Center(child: Text("No Quiz Available")),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 3,
                    childAspectRatio: 0.5,
                  ),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return QuizTile(
                      title: snapshot.data.docs[index].data()['quizTitle'],
                      description:
                          snapshot.data.docs[index].data()['quizDescription'],
                      imgUrl: snapshot.data.docs[index].data()['quizImgUrl'],
                      quizId: snapshot.data.docs[index].data()['quizId'],
                      userRole: userRole.toString(),
                    );
                  },
                );
        },
      ),
    );
  }

  @override
  void initState() {
    getuserRole();
    databaseService.getQuizData().then((value) {
      print(value);
      setState(() {
        quizStream = value;
      });
    });

    super.initState();
  }

  getuserRole() async {
    await HelperFunctions.getUserRole().then((value) {
      setState(() {
        userRole = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    checkstatus();
    testingfun();
    return Scaffold(
        // drawer: appDrawer(context),
        appBar: AppBar(
          title: Center(
              child: Text(
            "Ours Book",
            style: TextStyle(color: Colors.blue, fontSize: 24),
          )),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: _connected
            ? Container(
                child: quizList(),
              )
            : Container(
                color: Colors.white,
                child: Center(
                    child: Text(
                  "Opps! Please Check Your Connectivity",
                  style: TextStyle(color: Colors.black, fontSize: 17),
                )),
              ),
        floatingActionButton: userRole != "student"
            ? FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CreateBook()));
                },
              )
            : null);
  }
}

class QuizTile extends StatelessWidget {
  final String imgUrl;
  final String title;
  final String quizId;
  final String description;
  final String userRole;
  QuizTile({
    required this.imgUrl,
    required this.title,
    required this.description,
    required this.quizId,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Image.network(
                imgUrl,
                fit: BoxFit.cover,
              ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                ),
                alignment: Alignment.bottomCenter,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 5,
          ),
          new RichText(
            text: new TextSpan(
              text: 'Rs. 51',
              style: TextStyle(color: Colors.black),
              children: <TextSpan>[
                new TextSpan(
                  text: ' ₹ 112',
                  style: new TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
