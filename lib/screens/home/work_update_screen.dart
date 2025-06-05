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
  final FocusNode _descriptionFocusNode = FocusNode();

  bool plan = false;
  bool coding = false;
  bool debugging = false;
  bool testing = false;
  bool waiting = false;
  bool onLeave = false;
  bool isLoading = false;
  String statusMessage = "";

  void _handleOnLeaveChange(bool value) {
    setState(() {
      onLeave = value;
      if (onLeave) {
        // If onLeave is true, set all others to false
        plan = false;
        coding = false;
        debugging = false;
        testing = false;
        waiting = false;
      }
    });
  }

  void _handleOtherActivityChange(bool value, Function(bool) setStateFn) {
    if (onLeave) return; // Don't allow changes if onLeave is true

    setState(() {
      setStateFn(value);
      if (value) {
        // If any other activity is selected, ensure onLeave is false
        onLeave = false;
      }
    });
  }

  void _submitUpdate() async {
    if (!plan && !coding && !debugging && !testing && !waiting && !onLeave) {
      setState(() {
        statusMessage = "Please select at least one activity";
      });
      return;
    }

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
      statusMessage = result ?? "Update submitted successfully!";

      if (result == null) {
        plan = false;
        coding = false;
        debugging = false;
        testing = false;
        waiting = false;
        onLeave = false;
        _descriptionController.clear();
      }
    });
  }

  Widget _buildActivityCard(String label, String icon, bool value,
      Function(bool) onChanged, bool enabled) {
    return Card(
      elevation: value ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: value ? Theme.of(context).primaryColor : Colors.grey.shade300,
          width: 1,
        ),
      ),
      color: enabled ? null : Colors.grey.shade100,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? () => onChanged(!value) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: value
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconData(icon),
                  color: value
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: value
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade800,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: enabled ? (val) => onChanged(val) : null,
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'plan':
        return Icons.assignment_outlined;
      case 'coding':
        return Icons.code_outlined;
      case 'debugging':
        return Icons.bug_report_outlined;
      case 'testing':
        return Icons.verified_outlined;
      case 'waiting':
        return Icons.access_time_outlined;
      case 'leave':
        return Icons.beach_access_outlined;
      default:
        return Icons.work_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
    final otherActivitiesEnabled = !onLeave;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Daily Work Update"),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Date Header
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      today,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Activities Section
              Text(
                "Today's Activities",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _buildActivityCard(
                  "Planning",
                  "plan",
                  plan,
                  (val) => _handleOtherActivityChange(val, (v) => plan = v),
                  otherActivitiesEnabled),
              const SizedBox(height: 8),
              _buildActivityCard(
                  "Coding",
                  "coding",
                  coding,
                  (val) => _handleOtherActivityChange(val, (v) => coding = v),
                  otherActivitiesEnabled),
              const SizedBox(height: 8),
              _buildActivityCard(
                  "Debugging",
                  "debugging",
                  debugging,
                  (val) =>
                      _handleOtherActivityChange(val, (v) => debugging = v),
                  otherActivitiesEnabled),
              const SizedBox(height: 8),
              _buildActivityCard(
                  "Testing",
                  "testing",
                  testing,
                  (val) => _handleOtherActivityChange(val, (v) => testing = v),
                  otherActivitiesEnabled),
              const SizedBox(height: 8),
              _buildActivityCard(
                  "Waiting (for review)",
                  "waiting",
                  waiting,
                  (val) => _handleOtherActivityChange(val, (v) => waiting = v),
                  otherActivitiesEnabled),
              const SizedBox(height: 8),
              _buildActivityCard(
                  "On Leave", "leave", onLeave, _handleOnLeaveChange, true),
              const SizedBox(height: 24),

              // Description Section
              Text(
                "Work Description",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _descriptionController,
                  focusNode: _descriptionFocusNode,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Describe what you worked on today...",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  enabled:
                      otherActivitiesEnabled, // Disable if on leave is selected
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : _submitUpdate,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Submit Update",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Status Message
              if (statusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusMessage.contains("success")
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusMessage.contains("success")
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        statusMessage.contains("success")
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        color: statusMessage.contains("success")
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          statusMessage,
                          style: TextStyle(
                            color: statusMessage.contains("success")
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
