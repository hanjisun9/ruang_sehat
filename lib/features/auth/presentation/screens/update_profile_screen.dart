import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruang_sehat/features/auth/providers/auth_providers.dart';
import 'package:ruang_sehat/theme/app_colors.dart';
import 'package:ruang_sehat/utils/snackbar_helper.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _nameC = TextEditingController();
  final _usernameC = TextEditingController();
  final _passwordC = TextEditingController();

  static const String _profileAsset = 'assets/images/nana.jpeg';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProviders>().getProfile();
    });
  }

  @override
  void dispose() {
    _nameC.dispose();
    _usernameC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameC.text.trim();
    final username = _usernameC.text.trim();
    final password = _passwordC.text;

    if (name.isEmpty && username.isEmpty && password.isEmpty) {
      SnackbarHelper.show(
        context,
        message: 'Isi minimal 1 field untuk update profile',
        isError: true,
      );
      return;
    }

    final auth = context.read<AuthProviders>();

    final ok = await auth.updateProfile(
      name: name,
      username: username,
      password: password,
    );

    if (!mounted) return;

    if (ok) {
      SnackbarHelper.show(
        context,
        message: auth.successMessage ?? 'Profile berhasil diupdate',
        isError: false,
      );
      _nameC.clear();
      _usernameC.clear();
      _passwordC.clear();
    } else {
      SnackbarHelper.show(
        context,
        message: auth.errorMessage ?? 'Gagal update profile',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProviders>();
    final profile = auth.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 190,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(44),
                        bottomRight: Radius.circular(44),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 18),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'Edit Profil',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -52,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.text.withOpacity(0.12),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: AppColors.border,
                          backgroundImage: const AssetImage(_profileAsset),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 72),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (auth.isLoading && profile == null)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Center(child: CircularProgressIndicator()),
                      ),

                    const Text(
                      'Nama Lengkap',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameC,
                      decoration: InputDecoration(
                        hintText: profile?.name ?? '',
                        hintStyle: const TextStyle(color: AppColors.hintText),
                        filled: true,
                        fillColor: AppColors.secondary,
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameC,
                      decoration: InputDecoration(
                        hintText: profile?.username ?? '',
                        hintStyle: const TextStyle(color: AppColors.hintText),
                        filled: true,
                        fillColor: AppColors.secondary,
                        prefixIcon: const Icon(Icons.alternate_email, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Kata Sandi Baru (Opsional)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordC,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '',
                        filled: true,
                        fillColor: AppColors.secondary,
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.secondary, // warna teks/icon
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.secondary,
                                ),
                              )
                            : const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}