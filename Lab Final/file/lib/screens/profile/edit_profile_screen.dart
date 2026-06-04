import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/images.dart';
import '../../widgets/loading_animation.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController avatarController;
  String avatarPreview = '';

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    nameController = TextEditingController(text: authProvider.displayName);
    avatarController = TextEditingController(
      text: authProvider.currentUser?.userMetadata?['avatar_url']?.toString() ??
          '',
    );
    avatarPreview = avatarController.text;
    avatarController.addListener(() {
      setState(() {
        avatarPreview = avatarController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final avatarImage = avatarPreview.isNotEmpty
        ? NetworkImage(avatarPreview)
        : const AssetImage(AppImages.avatar) as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AppImages.logo),
        ),
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: avatarImage,
              backgroundColor: Colors.grey[900],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: avatarController,
              decoration: const InputDecoration(
                labelText: 'Avatar URL (optional)',
                hintText: 'https://example.com/avatar.png',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Leave blank to use the default avatar.',
              style: TextStyle(
                  color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.8) ??
                      Colors.black54,
                  fontSize: 12),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        final avatarUrl = avatarController.text.trim();

                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a display name'),
                            ),
                          );
                          return;
                        }

                        final success = await authProvider.updateProfile(
                          name: name,
                          avatarUrl: avatarUrl,
                        );

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                authProvider.authMessage ??
                                    'Profile updated successfully.',
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                authProvider.authError ??
                                    'Unable to update profile.',
                              ),
                            ),
                          );
                        }
                      },
                child: authProvider.isLoading
                    ? const LoadingAnimation(size: 24)
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
