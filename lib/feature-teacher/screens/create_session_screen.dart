import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../layouts/teacher_layout.dart';
import '../widgets/create_session_form.dart';
import '../../core/services/supabase_service.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/supabase_provider.dart';

class CreateSessionScreen extends ConsumerStatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  ConsumerState<CreateSessionScreen> createState() =>
      _CreateSessionScreenState();
}

class _CreateSessionScreenState extends ConsumerState<CreateSessionScreen> {
  bool _isLoading = false;

  Future<void> _handleCreateSession(Map<String, dynamic> formData) async {
    setState(() => _isLoading = true);

    try {
      final supabase = ref.read(supabaseServiceProvider);
      final userProfile = ref.read(currentProfileProvider);

      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      // TODO: Get selected course and group IDs
      // For now, using placeholder values
      const courseId = 'COURSE_ID';
      const groupId = 'GROUP_ID';

      await supabase.createSession(
        courseId: courseId,
        groupId: groupId,
        teacherId: userProfile.id,
        title: formData['title'],
        sessionDate: formData['session_date'],
        startTime: formData['start_time'],
        endTime: formData['end_time'],
        room: formData['room'],
        type: formData['type_c'],
      );

      if (mounted) {
        context.pop(); // Go back to sessions list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create session: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TeacherLayout(
      title: 'Create Session',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Session',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new session for your course',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            CreateSessionForm(
              onSubmit: _handleCreateSession,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
