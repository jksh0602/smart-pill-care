// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../elder/elder_main_screen.dart';
import '../guardian/guardian_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final UserRole role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  bool get isElder => widget.role == UserRole.elder;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (success) {
      final user = auth.currentUser!;
      // 역할 검증: 어르신 화면으로 왔는데 보호자 계정이면 오류
      if (user.role != widget.role) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isElder
              ? '보호자 계정입니다. 보호자 화면에서 로그인해 주세요.'
              : '어르신 계정입니다. 어르신 화면에서 로그인해 주세요.'),
            backgroundColor: AppColors.danger,
          ),
        );
        await auth.signOut();
        return;
      }
      // 역할에 따라 화면 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => user.isElder
            ? const ElderMainScreen()
            : const GuardianDashboardScreen(),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? '로그인 실패'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('${isElder ? '어르신' : '보호자'} 로그인'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text('이메일',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'example@email.com',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return '이메일을 입력해 주세요.';
                  if (!v.contains('@')) return '올바른 이메일 형식이 아닙니다.';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('비밀번호',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: '비밀번호 입력',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined
                               : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return '비밀번호를 입력해 주세요.';
                  if (v.length < 6) return '6자 이상 입력해 주세요.';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                  : const Text('로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
