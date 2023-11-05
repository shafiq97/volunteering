import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:volunteering/model/Event.dart';

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _activityName = '';
  String _description = '';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  String _venue = '';
  String _urgency = '';
  String _activityType = '';
  int? _numVolunteers;
  String _approvalLetter = '';
  File? _imageFile; // Add this line to have a file variable

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Event has been successfully registered.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = path.basename(imageFile.path);
      Reference storageRef =
          FirebaseStorage.instance.ref().child('event_posters/$fileName');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // Handle errors
      print(e);
      return null;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path); // Update the _imageFile variable
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_imageFile != null)
                SizedBox(
                  height:
                      200, // Fixed height for the image, you can change it as needed
                  child: Image.file(_imageFile!),
                )
              else
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Upload Poster'),
                ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Activity Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the activity name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _activityName = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Venue'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the venue';
                  }
                  return null;
                },
                onSaved: (value) {
                  _venue = value!;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Urgency'),
                value: _urgency.isNotEmpty
                    ? _urgency
                    : null, // Set to null if _urgency is empty
                items: ['High', 'Medium', 'Low']
                    .map((urgency) => DropdownMenuItem(
                          value: urgency,
                          child: Text(urgency),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _urgency = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select urgency';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Activity Type'),
                value: _activityType.isNotEmpty ? _activityType : null,
                items: ['Type 1', 'Type 2', 'Type 3']
                    .map((activityType) => DropdownMenuItem(
                          value: activityType,
                          child: Text(activityType),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _activityType = value!;
                  });
                },
                validator: (value) {
                  if (_activityType.isEmpty) {
                    return 'Please select activity type';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Number of Volunteers'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the number of volunteers';
                  }
                  return null;
                },
                onSaved: (value) {
                  _numVolunteers = int.tryParse(value!);
                },
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Add this line
                children: [
                  const Text('Start Date: '),
                  Text(_startDate != null
                      ? "${_startDate.toLocal()}".split(' ')[0]
                      : ''),
                  ElevatedButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _startDate = selectedDate;
                        });
                      }
                    },
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Add this line
                children: [
                  const Text('End Date: '),
                  Text(_endDate != null
                      ? "${_endDate.toLocal()}".split(' ')[0]
                      : ''),
                  ElevatedButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _endDate = selectedDate;
                        });
                      }
                    },
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (selectedTime != null) {
                    setState(() {
                      _time = selectedTime;
                    });
                  }
                },
                child: const Text('Select Time'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Approval Letter'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the approval letter';
                  }
                  return null;
                },
                onSaved: (value) {
                  _approvalLetter = value!;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Save the form data
                    _formKey.currentState!.save();

                    String? posterUrl;
                    if (_imageFile != null) {
                      // Upload image to Firebase Storage and get the URL
                      posterUrl = await uploadImageToFirebase(_imageFile!);
                    }

                    // Create an Event object
                    Event event = Event(
                      activityName: _activityName,
                      description: _description,
                      startDate: _startDate,
                      endDate: _endDate,
                      time: _time,
                      venue: _venue,
                      urgency: _urgency,
                      activityType: _activityType,
                      numVolunteers: _numVolunteers ?? 0,
                      approvalLetter: _approvalLetter,
                      posterUrl: posterUrl,
                    );

                    // Save the event to Firestore
                    await FirebaseFirestore.instance
                        .collection('events')
                        .add(event.toJson());
                    _showSuccessDialog();
                  }
                },
                child: const Text('Register Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
