import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ IMPORT PARA SA DRAFT

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _descController = TextEditingController();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadDraft(); // ✅ I-LOAD ANG DRAFT INIG OPEN
  }

  // ✅ FUNCTION PARA MA-LOAD ANG DRAFT
  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = prefs.getString('report_draft');
    if (draft != null) {
      setState(() {
        _descController.text = draft;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft loaded automatically.'), backgroundColor: Colors.blue),
        );
      }
    }
  }

  // ✅ FUNCTION PARA MA-SAVE ANG DRAFT
  Future<void> _saveDraft() async {
    if (_descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a description first.'), backgroundColor: Colors.orange),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('report_draft', _descController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved locally!'), backgroundColor: Colors.green),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            dropdownColor: const Color(0xFF222B36),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true, 
              fillColor: const Color(0xFF222B36), 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.category, color: Color(0xFF00E676)),
            ),
            items: const [
              DropdownMenuItem(value: 'missed', child: Text('Missed Pickup')), 
              DropdownMenuItem(value: 'dumping', child: Text('Illegal Dumping')),
              DropdownMenuItem(value: 'overflow', child: Text('Overflowing Bin')),
            ],
            onChanged: (val) {},
          ),
          const SizedBox(height: 20),
          
          const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true, 
              fillColor: const Color(0xFF222B36), 
              hintText: 'Describe the issue in detail...', 
              hintStyle: const TextStyle(color: Colors.grey), 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),

          // 📸 PHOTO UPLOAD SECTION
          const Text('Photo Evidence', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          
          if (_imageFile != null)
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00E676).withOpacity(0.5), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: kIsWeb 
                  ? Image.network(_imageFile!.path, fit: BoxFit.cover) 
                  : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt, color: Color(0xFF00E676)),
              label: const Text('Attach Photo', style: TextStyle(color: Color(0xFF00E676))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00E676), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
          const SizedBox(height: 32),
          
          // ✅ SAVE DRAFT BUTTON
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                side: const BorderSide(color: Colors.blueAccent, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _saveDraft,
              icon: const Icon(Icons.save),
              label: const Text('Save as Draft', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
          
          // SUBMIT BUTTON
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00E676), 
                foregroundColor: Colors.black, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                shadowColor: const Color(0xFF00E676).withOpacity(0.5),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report Submitted!'), backgroundColor: Color(0xFF00E676)),
                );
                // Clear draft after submit
                SharedPreferences.getInstance().then((prefs) => prefs.remove('report_draft'));
                setState(() {
                  _imageFile = null;
                  _descController.clear();
                });
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}