import 'package:app/screens/addEntry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/sidebar.dart';

class HomePage extends StatefulWidget {
  final String title;
  final String uid;
  final String name;
  final String imageUrl;
  HomePage({
    Key key,
    this.title,
    this.uid,
    this.name,
    this.imageUrl,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState(
        uid: uid,
        name: name,
        imageUrl: imageUrl,
      );
}

class _HomePageState extends State<HomePage> {
  String name;
  String imageUrl;
  String uid;
  final firestoreInstance = Firestore.instance;
  _HomePageState({
    this.uid,
    this.name,
    this.imageUrl,
  });

  _showPoem(BuildContext context, DocumentSnapshot doc) {
    Widget continueButton = FlatButton(
      color: Theme.of(context).backgroundColor,
      child: Text("Continue"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(7.0),
        ),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    Widget editButton = FlatButton(
      color: Theme.of(context).backgroundColor,
      child: Text("Edit"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(7.0),
        ),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return Entry(uid: uid, name: name, imageUrl: imageUrl, doc: doc);
            },
          )
        );
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: <Widget>[
            Text(
              doc["title"],
              style: TextStyle(
                color: Theme.of(context).backgroundColor,
                fontSize: 25,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  Text(
                    doc["body"],
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      actions: <Widget>[
        editButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      child: alert,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Sidebar(
          name: name,
          imgURL: imageUrl,
        ),
        appBar: AppBar(
          title: Text(
            "Drabble",
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: MediaQuery.of(context).size.height * 0.05,
            ),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              color: Theme.of(context).backgroundColor,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return Entry(
                          uid: uid, name: name, imageUrl: imageUrl, doc: null);
                    },
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.87,
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: firestoreInstance.collection(uid).snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: Text(
                      'Loading...',
                      style: TextStyle(fontSize: 50),
                    ),
                  );
                default:
                  return ListView(
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.height * 0.07,
                        padding: EdgeInsets.all(15),
                        margin: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 4,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                document["title"],
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.025,
                                ),
                              ),
                            ),
                            IconButton(
                              iconSize: 20.0,
                              icon: Icon(
                                Icons.description,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                _showPoem(context, document);
                              },
                            ),
                            IconButton(
                              iconSize: 20.0,
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                document.reference.delete();
                              },
                            ),
                          ],
                        ),
                        // color: Theme.of(context).accentColor,
                      );
                    }).toList(),
                  );
              } // Switch
            }, // Builder
          ),
        ),
      ),
    );
  }
}

// CustomScrollView(
//           slivers: <Widget>[
//             SliverAppBar(
//               expandedHeight: 200.0,
//               floating: true,
//               snap: true,
//               pinned: true,
//               backgroundColor: Theme.of(context).primaryColor,
//               flexibleSpace: FlexibleSpaceBar(
//                 centerTitle: true,
//                 titlePadding: EdgeInsets.only(top: 10),
//                 title: Text(
//                   "Drabble",
//                   style: TextStyle(
//                     color: Theme.of(context).accentColor,
//                     fontSize: 35,
//                   ),
//                 ),
//               ),
//               elevation: 0,
//               centerTitle: true,
//               actions: <Widget>[
//                 // new IconButton(
//                 //   icon: Icon(Icons.search),
//                 //   color: Theme.of(context).backgroundColor,
//                 //   onPressed: () => {},
//                 // ),
//                 new IconButton(
//                     icon: Icon(Icons.add),
//                     color: Theme.of(context).backgroundColor,
//                     onPressed: _addEntry),
//               ],
//             ),
//             SliverFillRemaining(
//               child: FractionallySizedBox(
//                 heightFactor: 0.91,
//                 alignment: Alignment.bottomCenter,
//                 child: Container(
//                   margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
//                   decoration: new BoxDecoration(
//                     color: Theme.of(context).backgroundColor,
//                     borderRadius: new BorderRadius.all(
//                       Radius.circular(40),
//                     ),
//                   ),
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: firestoreInstance.collection(uid).snapshots(),
//                     builder: (BuildContext context,
//                         AsyncSnapshot<QuerySnapshot> snapshot) {
//                       if (snapshot.hasError)
//                         return new Text('Error: ${snapshot.error}');
//                       switch (snapshot.connectionState) {
//                         case ConnectionState.waiting:
//                           return new Text('Loading...');
//                         default:
//                           return ListView(
//                             children: snapshot.data.documents
//                                 .map((DocumentSnapshot document) {
//                               return Container(
//                                 width: 200,
//                                 height: 20,
//                                 child: Text(document["title"]),
//                                 color: Theme.of(context).accentColor,
//                               );
//                             }).toList(),
//                           );
//                       } // Switch
//                     }, // Builder
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
