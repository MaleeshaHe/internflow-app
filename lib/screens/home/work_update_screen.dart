import 'package:flutter/material.dart';
import 'package:internflow/services/work_update_service.dart';
import 'package:intl/intl.dart';

class WorkUpdateScreen extends StatefulWidget {
  const WorkUpdateScreen({Key? key}) : super(key: key);

  @override
  State<WorkUpdateScreen> createState() => _WorkUpdateScreenState();
}

class _WorkUpdateScreenState extends State<WorkUpdateScreen> {
  final WorkUpdateService _service = WorkUpdateService();
  final TextEditingController _descriptionController = TextEditingController();

  bool plan = false;
  bool coding = false;
  bool debugging = false;
  bool testing = false;
  bool waiting = false;
  bool onLeave = false;
  bool isLoading = false;
  String statusMessage = "";

  void _submitUpdate() async {
    setState(() {
      isLoading = true;
      statusMessage = "";
    });

    final result = await _service.submitDailyUpdate(
      plan: plan,
      coding: coding,
      debugging: debugging,
      testing: testing,
      waiting: waiting,
      onLeave: onLeave,
      description: _descriptionController.text.trim(),
    );

    setState(() {
      isLoading = false;
      statusMessage =
          result == null ? "Update submitted successfully." : result;
    });
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: (val) => setState(() => onChanged(val)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Work Update"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(today, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              _buildToggle("Planned Today", plan, (val) => plan = val),
              _buildToggle("Coding", coding, (val) => coding = val),
              _buildToggle("Debugging", debugging, (val) => debugging = val),
              _buildToggle("Testing", testing, (val) => testing = val),
              _buildToggle("Waiting (e.g., for review)", waiting,
                  (val) => waiting = val),
              _buildToggle("On Leave", onLeave, (val) => onLeave = val),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Description of your work",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitUpdate,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text("Submit Update"),
                ),
              ),
              if (statusMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  statusMessage,
                  style: TextStyle(
                    color: statusMessage.contains("success")
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
