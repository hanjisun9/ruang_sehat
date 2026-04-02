import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ruang_sehat/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:ruang_sehat/features/auth/providers/auth_providers.dart';
import 'package:ruang_sehat/features/home/screens/home_screen.dart';
import 'package:ruang_sehat/utils/snackbar_helper.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;
  final VoidCallback onSwitchToLogin;

  const AuthForm({
    super.key,
    required this.isLogin,
    required this.onSwitchToLogin,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isObscure = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProviders>();
    bool success;

    if (widget.isLogin) {
      success = await auth.login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );
    } else {
      success = await auth.register(
        nameController.text.trim(),
        usernameController.text.trim(),
        passwordController.text.trim(),
      );
    }

    if (!context.mounted) return;

    if (success) {
      if (auth.successMessage != null) {
        SnackbarHelper.show(
          context,
          message: auth.successMessage!,
        );
      }

      if (widget.isLogin) {
        Navigator.pushReplacementNamed(
          context,
          HomeScreen.routeName,
          arguments: 0,
        );
      } else {
        widget.onSwitchToLogin();

        nameController.clear();
        usernameController.clear();
        passwordController.clear();
      }
    } else {
      SnackbarHelper.show(
        context,
        message: auth.errorMessage ?? 'Terjadi kesalahan',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProviders>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isLogin == false) ...[
            const SizedBox(height: 18),
            const Text(
              'Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: nameController,
              validator: (value) {
                if (!widget.isLogin && (value == null || value.trim().isEmpty)) {
                  return 'Nama wajib diisi';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter Your Name',
                hintStyle: const TextStyle(color: AppColors.hintText),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 14.0,
                ),
              ),
            ),
          ],

          const SizedBox(height: 18),
          const Text(
            'Username',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: usernameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username wajib diisi';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter Your Username',
              hintStyle: const TextStyle(color: AppColors.hintText),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 14.0,
              ),
            ),
          ),

          const SizedBox(height: 18),
          const Text(
            'Password',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: passwordController,
            obscureText: _isObscure,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Password wajib diisi';
              }
              if (value.trim().length < 6) {
                return 'Password minimal 6 karakter';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter Your Password',
              hintStyle: const TextStyle(color: AppColors.hintText),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 14.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.hintText,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: authProvider.isLoading
                ? null
                : () => handleSubmit(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 53),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.isLogin ? 'Login' : 'Register',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          if (widget.isLogin) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  side: const BorderSide(color: AppColors.hintText, width: 2),
                ),
                const Text(
                  'Remember me',
                  style: TextStyle(
                    color: AppColors.hintText,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(child: Divider(thickness: 1, color: AppColors.border)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'Or login with',
                    style: TextStyle(
                      color: AppColors.hintText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Expanded(child: Divider(thickness: 1, color: AppColors.border)),
              ],
            ),
            const SizedBox(height: 18),
            Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: Center(
                  child: SvgPicture.asset('assets/icons/google.svg'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}