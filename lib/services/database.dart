import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  Future addQuizData(Map quizData, String quizId) async {
    // await FirebaseFirestore.instance
    //     .collection("Quiz")
    //     .doc(quizId)
    //     .set(quizData)
    //     .catchError((e) => print(e.toString()));
  }

  Future<void> addQuestionData(Map questionData, String quizId) async {
    // await FirebaseFirestore.instance
    //     .collection("Quiz")
    //     .doc(quizId)
    //     .collection("QNA")
    //     .add(questionData)
    //     .catchError((e) => print(e.toString()));
  }

  getQuizData() async {
    return FirebaseFirestore.instance.collection("Quiz").snapshots();
  }

  deleteQuiz(quizId) async {
    await FirebaseFirestore.instance
        .collection('Quiz')
        .doc(quizId)
        .collection("QNA")
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    await FirebaseFirestore.instance
        .collection('Quiz')
        .doc(quizId)
        .get()
        .then((res) {
      var str =
          FirebaseStorage.instance.refFromURL(res.get('quizImgUrl')).delete();
      print(str);
    });
    await FirebaseFirestore.instance.collection("Quiz").doc(quizId).delete();
  }

  uploadUserInfo(userMap, uid) {
    try {
      print('ss');
      FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(userMap)
          .catchError((e) {
        print(e.toString());
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> saveQuizResult(String uid, Map userResult) async {
    // await FirebaseFirestore.instance
    //     .collection("users")
    //     .doc(uid)
    //     .collection("QuizResult")
    //     .add(userResult)
    //     .catchError((e) {
    //   print(e.toString());
    // });
  }

  getUserQuizResult(uid) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("QuizResult")
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  getUserByUserEmail(String userEmail) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: userEmail)
        .get();
  }

  changeUserName(String userid, String userName) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .update({'name': userName});
  }

  getQuestionData(String quizId) async {
    return FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .collection("QNA")
        .get();
  }
}
