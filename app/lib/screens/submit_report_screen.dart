import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotfix/services/auth_service.dart';
import 'package:spotfix/services/database_service.dart';
import 'package:spotfix/services/storage_service.dart';
import 'package:spotfix/screens/success_screen.dart';
import 'package:spotfix/utils/reference_utils.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({Key? key}) : super(key: key);

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  String _selectedIssueType = 'Potholes';
  File? _image;
  bool _isLoading = false;

  // Dummy location for Bangalore
  final double _latitude = 12.9716;
  final double _longitude = 77.5946;

  final List<String> _issueTypes = [
    'Potholes',
    'Garbage Accumulation',
    'Broken Streetlights',
    'Traffic Lights',
    'Other',
  ];

  Future<void> _pickImage() async {
    print("REPORT: Picking image");
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      print("REPORT: Image picked successfully");
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitReport() async {
    print("REPORT: Submit button pressed");
    if (_descriptionController.text.isEmpty) {
      print("REPORT: Description is empty");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a description')),
      );
      return;
    }

    if (_image == null) {
      print("REPORT: No image selected");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a photo of the issue')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    print("REPORT: Setting loading state to true");

    try {
      // Check if user is logged in
      final user = _authService.currentUser;
      final userId = user?.id ?? 'anonymous';
      print("REPORT: User ID: $userId");

      // Upload image
      print("REPORT: Uploading image");
      final imageUrl = await _storageService.uploadImage(_image!);
      print("REPORT: Image uploaded successfully: $imageUrl");

      // Generate reference number
      final String referenceNumber = generateReferenceNumber();

      // Save issue to database
      print("REPORT: Saving issue to database");
      await _databaseService.reportIssue(
        title: _selectedIssueType,
        description: _descriptionController.text,
        imageUrl: imageUrl,
        latitude: _latitude,
        longitude: _longitude,
        userId: userId,
      );
      print("REPORT: Issue saved successfully");

      // Clear form
      _descriptionController.clear();
      setState(() {
        _image = null;
      });

      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(referenceNumber: referenceNumber),
        ),
      );
    } catch (e) {
      print("REPORT ERROR: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      print("REPORT: Setting loading state to false");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Report'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/park_cleanup.jpg',
                    height: 30,
                    width: 30,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SpotFix',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Text(
                    'Submit Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Issue Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Column(
                children:
                    _issueTypes.map((type) {
                      return RadioListTile<String>(
                        title: Text(type),
                        value: type,
                        groupValue: _selectedIssueType,
                        onChanged: (value) {
                          setState(() {
                            _selectedIssueType = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Describe the issue...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload Photos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      _image == null
                          ? const Center(
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.pink,
                              size: 40,
                            ),
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/map.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Text('Map placeholder'));
                        },
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.location_on,
                        color: Colors.blue[700],
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Submit Report',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
