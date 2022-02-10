import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

// Create storage
final secureStorage = new FlutterSecureStorage();
FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseStorage storage = FirebaseStorage.instance;
final Uuid uuid = Uuid();

// Collection refs
CollectionReference reportRef = firestore.collection('report');
CollectionReference usersRef = firestore.collection('users');
CollectionReference usersToken = firestore.collection('token');

// Storage refs
Reference profilePic = storage.ref().child('profilePic');
