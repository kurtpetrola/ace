// classroom.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ClassRooms {
  String className;
  String description;
  String creator;
  AssetImage bannerImg;
  List<double> clrs = [];

  ClassRooms(
      {required this.className,
      required this.description,
      required this.creator,
      required this.bannerImg,
      required this.clrs});
}

List<ClassRooms> classRoomList = [
  ClassRooms(
    className: "Introduction to Computing",
    description: "Second Year",
    creator: "Rolly Maniquez",
    bannerImg: const AssetImage("assets/images/banner/banner1.jpg"),
    clrs: [255, 233, 116, 57],
  ),
  ClassRooms(
    className: "Game Development",
    description: "Second Year",
    creator: "Francis Gonzales",
    bannerImg: const AssetImage("assets/images/banner/banner2.jpg"),
    clrs: [255, 101, 237, 153],
  ),
  ClassRooms(
    className: "Programming I",
    description: "First Year",
    creator: "Paul Rigor",
    bannerImg: const AssetImage("assets/images/banner/banner5.jpg"),
    clrs: [255, 111, 27, 198],
  ),
  ClassRooms(
      className: "Web Development",
      description: "Third Year",
      creator: "Zane Philip",
      bannerImg: const AssetImage("assets/images/banner/banner6.jpg"),
      clrs: [255, 0, 0, 0]),
  ClassRooms(
      className: "Capstone & Research Project I",
      description: "Third Year",
      creator: "Veronica Canlas",
      bannerImg: AssetImage("assets/images/banner/banner7.jpg"),
      clrs: [255, 102, 153, 204]),
  ClassRooms(
    className: "Data Structures & Algorithms",
    description: "Third Year",
    creator: "Angelica Vidal",
    bannerImg: AssetImage("assets/images/banner/banner8.jpg"),
    clrs: [255, 111, 27, 198],
  ),
  ClassRooms(
    className: "Human Computer Interaction",
    description: "First Year",
    creator: "Rolly Maniquez",
    bannerImg: AssetImage("assets/images/banner/banner9.jpg"),
    clrs: [255, 95, 139, 233],
  ),
  ClassRooms(
    className: "Integrative Programming",
    description: "Third Year",
    creator: "Paulo Cabrera",
    bannerImg: AssetImage("assets/images/banner/banner10.jpg"),
    clrs: [255, 95, 139, 233],
  ),
];
