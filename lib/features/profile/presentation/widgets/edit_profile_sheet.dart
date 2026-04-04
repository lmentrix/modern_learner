import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:modern_learner_production/features/profile/presentation/bloc/profile_bloc.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({
    super.key,
    required this.currentName,
    required this.currentEmail,
  });

  final String currentName;
  final String currentEmail;

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameController;
  bool _isLoading = false;
  bool _hasSubmittedUpdate = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSubmittedUpdate = true;
    });

    context.read<ProfileBloc>().add(
          ProfileUpdateRequested(
            name: newName,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        // Only show success/error after user has submitted an update
        if (!_hasSubmittedUpdate) return;

        if (state.status == ProfileStatus.success) {
          // Update AuthBloc with the new name to reflect changes immediately
          context.read<AuthBloc>().add(
            AuthUpdateUserInfoRequested(
              name: _nameController.text.trim(),
            ),
          );
          
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppColors.primary,
            ),
          );
        } else if (state.status == ProfileStatus.error) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to update profile'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          top: 12,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            const SizedBox(height: 20),
            _buildTitle(),
            const SizedBox(height: 24),
            _buildAvatarSection(),
            const SizedBox(height: 24),
            _buildNameField(),
            const SizedBox(height: 16),
            _buildEmailField(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.outlineVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.edit_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Edit Profile',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    final initial = widget.currentName.isNotEmpty
        ? widget.currentName[0].toUpperCase()
        : 'U';

    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: Center(
            child: Text(
              initial,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.currentName.isEmpty ? 'User' : widget.currentName,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                widget.currentEmail,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Avatar upload coming soon')),
            );
          },
          icon: const Icon(Icons.camera_alt_outlined),
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NAME',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          enabled: !_isLoading,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.onSurfaceVariant,
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          textCapitalization: TextCapitalization.words,
          autocorrect: true,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMAIL',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          enabled: false,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.onSurfaceVariant,
          ),
          decoration: InputDecoration(
            hintText: widget.currentEmail,
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.onSurfaceVariant,
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerHighest.withValues(alpha: 0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: const Icon(
              Icons.lock_outline,
              size: 18,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Email cannot be changed',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: _isLoading ? null : _handleSave,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Save Changes'),
      ),
    );
  }
}
