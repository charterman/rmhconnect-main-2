import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/screens/admins/admin_view_events.dart';
import 'package:rmhconnect/theme.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class Events extends StatefulWidget {
  final String eventID;
  final String evname;
  final String evdescrip;
  final String evtime;
  final String evdate;
  final String orgName;
  final Timestamp evtimeunchanged;

  const Events({
    
    super.key,
    required this.eventID,
    required this.orgName,
    required this.evname,
    required this.evdescrip,
    required this.evtime,
    required this.evdate,
    required this.evtimeunchanged,
  });

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  SampleItem? selectedItem;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController namecontrol = TextEditingController();
  late TextEditingController descripcontrol = TextEditingController();


  late DateTime _selectedDate = DateTime.parse(widget.evdate);
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
  }

  Future<void> _createEvents(String orgName, String title, String description, DateTime date, TimeOfDay time) async {
    try {
      final orgQuery = await FirebaseFirestore.instance
          .collection('organizations')
          .where('name', isEqualTo: orgName)
          .limit(1)
          .get();

      if (orgQuery.docs.isEmpty) {
        throw Exception("Organization '$orgName' not found.");
      }

      final orgDocId = orgQuery.docs.first.id;

      final combinedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      final timestamp = Timestamp.fromDate(combinedDateTime);

      final eventRef = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(orgDocId)
          .collection('activities')
          .doc(widget.eventID)
          .update({
        'title': namecontrol.text.trim(),
        'description': descripcontrol.text.trim(),
        'dateTime': _selectedDate,
      });
      //await eventRef.update({'id': eventRef.id});
      print("Activity added successfully.");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Activity added successfully.")
          )
      );
    } catch (e) {
      print("Failed to add activity: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to add activity.")
          )
      );
    }
  }


  Future<void> deleteEventByUid(String orgName, String uid) async {
    try {
      final orgQuery = await FirebaseFirestore.instance
          .collection('organizations')
          .where('name', isEqualTo: orgName)
          .limit(1)
          .get();

      if (orgQuery.docs.isEmpty) {
        print("No organization found with name: $orgName");
        return;
      }

      final orgId = orgQuery.docs.first.id;

      final eventRef = FirebaseFirestore.instance
          .collection('organizations')
          .doc(orgId)
          .collection('activities')
          .doc(uid);

      final docSnapshot = await eventRef.get();

      if (docSnapshot.exists) {
        await eventRef.delete();
        print("Event deleted successfully");
      } else {
        print("Event not found");
      }
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  Future<bool?> showDeleteConfirmationDialog(
      BuildContext context, String orgName, String uid) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Event Deletion"),
        content:
        const Text("Are you sure you want to delete this event permanently?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await deleteEventByUid(orgName, uid);
              Navigator.of(context).pop(true);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Event deleted successfully "),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 25),
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            elevation: 8,
            color: CharityConnectTheme.cardColor,
            child: ExpansionTile(
              leading: const Icon(Icons.calendar_today_rounded),
              title: Text(widget.evname),
              subtitle: Text('${widget.evdate}    ${widget.evtime}'),
              trailing: PopupMenuButton<SampleItem>(
                icon: const Icon(Icons.more_horiz,
                    color: Colors.black, size: 30),
                onSelected: (SampleItem item) async {
                  if (item == SampleItem.itemThree) {
                    bool? deleted = await showDeleteConfirmationDialog(
                        context, widget.orgName, widget.eventID);
                    if (deleted == true) {
                      setState(() {}); // Refresh UI after delete
                    }
                  }
                  if (item == SampleItem.itemTwo) {
                    Navigator.pushReplacementNamed(context, '/admin_view_events', arguments: {"orgid" : widget.orgName, "eventid" : widget.eventID});
                  }
                  if (item == SampleItem.itemOne) {
                    descripcontrol.text = widget.evdescrip;
                    namecontrol.text = widget.evname;
                    showDialog(
                      builder: (context) => StatefulBuilder(
                        builder: (BuildContext context, void Function(void Function()) setDialogState) {
                          return AlertDialog(
                            title: Text("Edit Event"),
                            content: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: namecontrol,
                                    decoration: InputDecoration(
                                      labelText: "Edit Event Name",
                                    ),
                                    validator: (String? eventnamevalue){
                                      if (eventnamevalue == null || eventnamevalue.isEmpty) {
                                        return 'Please enter a screen name';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton.icon(
                                          onPressed: () async {
                                            DateTime mindate = DateTime.now();
                                            DateTime maxdate = DateTime.now().add(Duration(days:365));
                                            DateTime initial = _selectedDate;
                                            if(initial.isBefore(mindate)){
                                              initial = mindate;
                                            }
                                            else if(initial.isAfter(maxdate)){
                                              initial = maxdate;
                                            }

                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate: initial,
                                              firstDate: mindate,
                                              lastDate: maxdate,
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                _selectedDate = picked;
                                              });
                                              setDialogState(() {});
                                            }
                                          },
                                          icon: Icon(Icons.calendar_today),
                                          label: Text(
                                            DateFormat('MMM d, yyyy').format(_selectedDate),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextButton.icon(
                                          onPressed: () async {
                                            final picked = await showTimePicker(
                                              context: context,
                                              initialTime: _selectedTime,
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                _selectedTime = picked;
                                              });
                                              setDialogState(() {}); // Force dialog to rebuild
                                            }
                                          },
                                          icon: Icon(Icons.access_time),
                                          label: Text(_selectedTime.format(context)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  TextFormField(
                                      controller: descripcontrol,
                                      decoration: InputDecoration(
                                        labelText: "Edit Event Description",
                                      ),
                                      validator: (String? eventdescripvalue) {
                                        if (eventdescripvalue == null ||
                                            eventdescripvalue.isEmpty) {
                                          return 'Please enter a screen name';
                                        }
                                        return null;
                                      }
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Spacer(),
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          namecontrol.clear();
                                          descripcontrol.clear();
                                        },
                                        child: Text("Cancel"),
                                      ),
                                      SizedBox(width: 20),
                                      OutlinedButton(
                                        onPressed: () async {
                                          if(_formKey.currentState!.validate()) {
                                            setState(() {
                                              nbname = namecontrol.text;
                                              nbloc = descripcontrol.text;
                                              //namecontrol.clear();

                                            });
                                            await _createEvents(widget.orgName, nbname, nbloc,
                                               _selectedDate, _selectedTime);
                                            Navigator.pop(context);
                                            setState(() {
                                              namecontrol.clear();
                                              descripcontrol.clear();
                                            });
                                          }
                                          else{
                                            print("error");
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text("Error")
                                                )
                                            );
                                          }
                                        },
                                        child: Text("Create"),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ), context: context,
                    );
                  }
                },
                itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<SampleItem>>[
                  const PopupMenuItem(
                    value: SampleItem.itemOne,
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: SampleItem.itemTwo,
                    child: Text('View Participants'),
                  ),
                  const PopupMenuItem(
                    value: SampleItem.itemThree,
                    child: Text('Delete'),
                  ),
                ],
              ),
              children: [
                ListTile(
                  title: const Text(
                    'Description',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: Text(widget.evdescrip),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
