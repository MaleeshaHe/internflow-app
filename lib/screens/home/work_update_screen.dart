import 'package:flutter/material.dart';
import 'package:internflow/services/work_update_service.dart';
import 'package:intl/intl.dart';

class WorkUpdateScreen extends StatefulWidget {
  const WorkUpdateScreen({Key? key, required String userId}) : super(key: key);

  @override
  State<WorkUpdateScreen> createState() => _WorkUpdateScreenState();
}

class _WorkUpdateScreenState extends State<WorkUpdateScreen> {
  final WorkUpdateService _service = WorkUpdateService();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _descriptionFocusNode = FocusNode();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  bool plan = false;
  bool coding = false;
  bool debugging = false;
  bool testing = false;
  bool waiting = false;
  bool onLeave = false;
  bool isLoading = false;

  void _handleOnLeaveChange(bool value) {
    setState(() {
      onLeave = value;
      if (onLeave) {
        plan = false;
        coding = false;
        debugging = false;
        testing = false;
        waiting = false;
      }
    });
  }

  void _handleOtherActivityChange(bool value, Function(bool) setStateFn) {
    if (onLeave) return;

    setState(() {
      setStateFn(value);
      if (value) {
        onLeave = false;
      }
    });
  }

  void _showSnackBar(String message, {bool isError = true}) {
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _submitUpdate() async {
    if (!plan && !coding && !debugging && !testing && !waiting && !onLeave) {
      _showSnackBar("Please select at least one activity");
      return;
    }

    final trimmedDescription = _descriptionController.text.trim();
    if (trimmedDescription.isEmpty) {
      _showSnackBar(onLeave
          ? "Please provide a reason for leave"
          : "Please describe your work");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await _service.submitDailyUpdate(
        plan: plan,
        coding: coding,
        debugging: debugging,
        testing: testing,
        waiting: waiting,
        onLeave: onLeave,
        description: trimmedDescription,
      );

      if (result != null) {
        _showSnackBar(result);
      } else {
        _showSnackBar("Update submitted successfully!", isError: false);
        setState(() {
          plan = false;
          coding = false;
          debugging = false;
          testing = false;
          waiting = false;
          onLeave = false;
          _descriptionController.clear();
        });
      }
    } catch (e) {
      _showSnackBar("An error occurred. Please try again.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildActivityCard(String label, String icon, bool value,
      Function(bool) onChanged, bool enabled) {
    return Card(
      elevation: value ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 10),
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
              Switch.adaptive(
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

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
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
                    (val) =>
                        _handleOtherActivityChange(val, (v) => testing = v),
                    otherActivitiesEnabled),
                const SizedBox(height: 8),
                _buildActivityCard(
                    "Waiting (for review)",
                    "waiting",
                    waiting,
                    (val) =>
                        _handleOtherActivityChange(val, (v) => waiting = v),
                    otherActivitiesEnabled),
                const SizedBox(height: 8),
                _buildActivityCard(
                    "On Leave", "leave", onLeave, _handleOnLeaveChange, true),
                const SizedBox(height: 24),
                Text(
                  onLeave ? "Leave Reason" : "Work Description",
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
                      hintText: onLeave
                          ? "Reason for taking leave..."
                          : "Describe what you worked on today...",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    enabled: true,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
