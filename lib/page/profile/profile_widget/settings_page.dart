import 'package:flutter/material.dart';
import 'package:tripmaster/utils/bottom_sheet_utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Setting',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: const SettingsContent(),
    );
  }
}

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    showCustomBottomSheet(
      context: context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to logout?',
      icon: Icons.logout,
      onOkPressed: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 16),
        // First group
        const SettingsItem(
          icon: Icons.person_outline,
          title: 'Account',
        ),
        const SettingsItem(
          icon: Icons.lock_outline,
          title: 'Privacy',
        ),
        const SettingsItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
        ),
        const SettingsItem(
          icon: Icons.send_outlined,
          title: 'Share profile',
        ),
        const SettingsItem(
          icon: Icons.headset_mic_outlined,
          title: 'Saved trip',
        ),
        const _Divider(),
        // Second group
        const SettingsItem(
          icon: Icons.help_outline,
          title: 'Help center',
        ),
        const SettingsItem(
          icon: Icons.article_outlined,
          title: 'About Trip Master',
        ),
        const _Divider(),
        SettingsItem(
          icon: Icons.logout,
          title: 'Log out',
          onTap: () => _handleLogout(context),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: Color(0x4D9E9E9E),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.black87,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 24,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}
