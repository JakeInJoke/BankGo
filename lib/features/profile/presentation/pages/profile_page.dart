import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/core/routes/app_router.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_event.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myProfile)),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;
          return SingleChildScrollView(
            child: Column(
              children: [
                _ProfileHeader(
                  name: user?.name ?? '—',
                  email: user?.email ?? '—',
                  avatarUrl: user?.avatarUrl,
                ),
                const SizedBox(height: AppDimensions.spaceSM),
                _buildSection(
                  context,
                  title: AppStrings.personalInfo,
                  items: [
                    _ProfileItem(
                      icon: Icons.person_outline,
                      label: 'Nombre completo',
                      value: user?.name ?? '—',
                      onTap: () {},
                    ),
                    _ProfileItem(
                      icon: Icons.email_outlined,
                      label: 'Correo electrónico',
                      value: user?.email ?? '—',
                      onTap: () {},
                    ),
                    _ProfileItem(
                      icon: Icons.phone_outlined,
                      label: 'Teléfono',
                      value: user?.phone ?? '—',
                      onTap: () {},
                    ),
                  ],
                ),
                _buildSection(
                  context,
                  title: AppStrings.security,
                  items: [
                    _ProfileItem(
                      icon: Icons.lock_outline,
                      label: 'Cambiar contraseña',
                      onTap: () {},
                    ),
                    _ProfileItem(
                      icon: Icons.fingerprint,
                      label: 'Biometría',
                      onTap: () {},
                    ),
                    _ProfileItem(
                      icon: Icons.shield_outlined,
                      label: 'Autenticación en 2 pasos',
                      onTap: () {},
                    ),
                  ],
                ),
                _buildSection(
                  context,
                  title: AppStrings.helpSupport,
                  items: [
                    _ProfileItem(
                      icon: Icons.help_outline,
                      label: 'Centro de ayuda',
                      onTap: () {},
                    ),
                    _ProfileItem(
                      icon: Icons.chat_bubble_outline,
                      label: 'Chat con soporte',
                      onTap: () {},
                    ),
                    _ProfileItem(
                      icon: Icons.privacy_tip_outlined,
                      label: AppStrings.privacyPolicy,
                      onTap: () {},
                    ),
                    _ProfileItem(
                      icon: Icons.description_outlined,
                      label: AppStrings.termsConditions,
                      onTap: () {},
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingPage),
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text(
                      AppStrings.logout,
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLG),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_ProfileItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingPage,
            AppDimensions.spaceMD,
            AppDimensions.paddingPage,
            AppDimensions.spaceXS,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.grey500,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingPage,
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: AppDimensions.paddingCard,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.pushReplacementNamed(context, AppRouter.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;

  const _ProfileHeader({
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXXL),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: AppDimensions.avatarSizeLG / 2,
            backgroundColor: AppColors.white.withValues(alpha: 0.2),
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.white,
                        ),
                  )
                : null,
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppDimensions.spaceXS),
          Text(
            email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _ProfileItem({
    required this.icon,
    required this.label,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey600),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: value != null
          ? Text(value!, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.grey400,
      ),
      onTap: onTap,
    );
  }
}
