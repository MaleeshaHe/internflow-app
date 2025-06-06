import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internflow/models/UserModel.dart';
import 'package:internflow/screens/home/work_update_detail_page.dart';

class InternListPage extends StatefulWidget {
  const InternListPage({super.key});

  @override
  State<InternListPage> createState() => _InternListPageState();
}

class _InternListPageState extends State<InternListPage> {
  List<UserModel> _interns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInterns();
  }

  Future<void> _loadInterns() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'intern')
          .get();

      setState(() {
        _interns = snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching interns: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Interns")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _interns.isEmpty
              ? const Center(child: Text("No interns found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _interns.length,
                  itemBuilder: (context, index) {
                    final intern = _interns[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: Text(intern.name ?? ''),
                        subtitle: Text(intern.email ?? ''),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkUpdateDetailPage(
                                userId: intern.uid,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
