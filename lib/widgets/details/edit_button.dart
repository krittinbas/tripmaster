import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tripmaster/page/editdetail_page.dart';

class EditButtonWidget extends StatelessWidget {
  final String trip_id;
  final Color statusColor;
  const EditButtonWidget(
      {required this.trip_id, required this.statusColor, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 32),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () {
                showMenu(
                  color: Colors.white,
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  position: const RelativeRect.fromLTRB(0, 625, 0, 0),
                  items: [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        title: Text('Edit'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        title: Text('Delete'),
                      ),
                    ),
                  ],
                  elevation: 8.0,
                ).then((value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditdetailPage(
                          trip_id: trip_id,
                          statusColor: statusColor,
                        ),
                      ),
                    );
                  } else if (value == 'delete') {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          height: 150,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16.0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Are you sure you want to delete this trip?',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                'This action cannot be undone.',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        side: const BorderSide(
                                            color: Colors.black, width: 2),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 60, vertical: 15),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("cancel",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 60, vertical: 15),
                                      ),
                                      onPressed: () async {
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('Trips')
                                              .doc(trip_id)
                                              .delete();
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        } catch (e) {
                                          print('Error deleting trip: $e');
                                        }
                                      },
                                      child: const Text('delete',
                                          style:
                                              TextStyle(color: Colors.white))),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                });
              },
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.edit,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.black,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.map_outlined,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
