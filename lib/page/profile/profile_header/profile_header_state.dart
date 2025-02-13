import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripmaster/page/profile/profile_header/profile_header.dart';
import 'package:tripmaster/service/profile_header_service.dart';
import 'package:tripmaster/page/profile/profile_header/profile_header_ui.dart';
import 'dart:math' as math;

class ProfileHeaderState extends State<ProfileHeader> {
  // State variables
  bool isFollowing = false;
  bool isLoading = false;
  late int currentFollowers;
  late int currentFollowing;
  late Stream<int> postCountStream; // เพิ่ม stream สำหรับจำนวนโพสต์

  // Stream subscriptions
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      userSubscription;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      profileSubscription;
  late StreamSubscription<QuerySnapshot> followSubscription;

  // Service instances
  late final ProfileHeaderFirebase firebase;
  late final ProfileHeaderUI ui;

  @override
  void initState() {
    super.initState();
    firebase = ProfileHeaderFirebase(this);
    ui = ProfileHeaderUI(this);

    currentFollowers = math.max(0, widget.profileData.followers);
    currentFollowing = math.max(0, widget.profileData.following);
    postCountStream = firebase.getUserPostCount(
        widget.profileData.userId); // ใช้ฟังก์ชันจาก ProfileHeaderFirebase

    firebase.setupSubscriptions();
    firebase.setupFollowListener();
  }

  @override
  void dispose() {
    userSubscription.cancel();
    profileSubscription.cancel();
    followSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ui.build(context);
  }
}
