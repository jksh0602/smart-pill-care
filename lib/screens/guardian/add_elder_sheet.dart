// lib/screens/guardian/add_elder_sheet.dart
// 보호자가 SNR 코드를 입력해서 어르신을 연결하는 바텀시트

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class AddElderSheet extends StatefulWidget {
  final String guardianUid;
  const AddElderSheet({super.key, required this.guardianUid});

  @override
  State<AddElderSheet> createState() => _AddElderSheetState();
}

class _AddElderSheetState extends State<AddElderSheet> {
  final _ctrl = TextEditingController();
  bool _isSearching = false;
  String? _foundName;
  String? _errorMsg;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final code = _ctrl.text.trim().toUpperCase();
    if (code.length < 4) {
      setState(() => _errorMsg = 'SNR 코드를 정확히 입력해 주세요.');
      return;
    }

    setState(() { _isSearching = true; _errorMsg = null; _foundName = null; });
    final auth = context.read<AuthProvider>();
    final elder = await auth.findElderBySnrCode(code);
    setState(() => _isSearching = false);

    if (elder == null) {
      setState(() => _errorMsg = '해당 SNR 코드의 어르신을 찾을 수 없습니다.\n코드를 다시 확인해 주세요.');
    } else if (auth.currentUser!.linkedElderCodes.contains(elder.snrCode)) {
      setState(() => _errorMsg = '이미 연결된 어르신입니다.');
    } else {
      setState(() => _foundName = '${elder.name} (${elder.age}세)');
    }
  }

  Future<void> _connect() async {
    final code = _ctrl.text.trim().toUpperCase();
    final auth = context.read<AuthProvider>();
    setState(() => _isSearching = true);
    final success = await auth.linkElder(code);
    setState(() => _isSearching = false);

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('어르신이 연결되었습니다! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      setState(() => _errorMsg = '연결에 실패했습니다. 다시 시도해 주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('어르신 추가',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text(
            '어르신 앱에서 발급받은 SNR 코드를 입력해 주세요.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          // SNR 입력
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'SNR-XXXX',
                    filled: true,
                    fillColor: AppColors.bgSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    prefixText: 'SNR-',
                    prefixStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _isSearching ? null : _search,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(72, 56),
                ),
                child: _isSearching
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                  : const Text('검색'),
              ),
            ],
          ),
          // 오류 메시지
          if (_errorMsg != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                    color: AppColors.danger, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_errorMsg!,
                      style: const TextStyle(
                        fontSize: 13, color: AppColors.danger)),
                  ),
                ],
              ),
            ),
          ],
          // 검색 결과
          if (_foundName != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Text('👴', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_foundName!,
                          style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        const Text('어르신을 찾았습니다!',
                          style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSearching ? null : _connect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size(72, 40),
                    ),
                    child: const Text('연결'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
