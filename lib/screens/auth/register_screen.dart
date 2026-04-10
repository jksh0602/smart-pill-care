// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../elder/elder_main_screen.dart';
import '../guardian/guardian_dashboard_screen.dart';
import 'snr_code_display_screen.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole role;
  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  bool _obscure = true;

  bool get isElder => widget.role == UserRole.elder;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();

    bool success;
    if (isElder) {
      success = await auth.registerElder(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        name: _nameCtrl.text.trim(),
        age: int.tryParse(_ageCtrl.text) ?? 0,
      );
    } else {
      success = await auth.registerGuardian(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        name: _nameCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    if (success) {
      final user = auth.currentUser!;
      if (isElder) {
        // 어르신은 SNR 코드 안내 화면 먼저
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => SnrCodeDisplayScreen(
              snrCode: user.snrCode,
              name: user.name,
            ),
          ),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const GuardianDashboardScreen()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? '회원가입 실패'),
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
        title: Text('${isElder ? '어르신' : '보호자'} 회원가입'),
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
              if (isElder) ...[
                _InfoBanner(
                  icon: '💡',
                  text: '회원가입 후 고유 관리 번호(SNR)가 발급됩니다.\n이 번호를 보호자에게 알려주시면 복약 현황을 모니터링할 수 있습니다.',
                ),
                const SizedBox(height: 20),
              ],
              _buildField('이름', _nameCtrl,
                hint: '홍길동',
                icon: Icons.person_outline,
                validator: (v) => (v == null || v.isEmpty) ? '이름을 입력해 주세요.' : null,
              ),
              const SizedBox(height: 16),
              if (isElder) ...[
                _buildField('나이', _ageCtrl,
                  hint: '75',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return '나이를 입력해 주세요.';
                    if (int.tryParse(v) == null) return '숫자를 입력해 주세요.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              _buildField('이메일', _emailCtrl,
                hint: 'example@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return '이메일을 입력해 주세요.';
                  if (!v.contains('@')) return '올바른 이메일 형식이 아닙니다.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                  : Text(isElder ? '가입하고 SNR 코드 받기' : '회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('비밀번호',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passCtrl,
          obscureText: _obscure,
          decoration: InputDecoration(
            hintText: '6자 이상 입력',
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
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String icon;
  final String text;
  const _InfoBanner({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primaryDark,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
