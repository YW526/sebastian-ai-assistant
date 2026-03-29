import 'package:flutter/material.dart';

/// 앱 전역 버튼 스타일. [CustomButtonVariant]로 주요·보조·링크형을 구분합니다.
enum CustomButtonVariant {
  /// 로그인·회원가입 등 메인 CTA (흰 배경, 테두리, elevation)
  primary,

  /// 취소·뒤로 등 보조 CTA (Outlined)
  secondary,

  /// "회원가입하기" 등 링크형 [TextButton]
  text,
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.isLoading = false,
    this.width = 170,
    this.height = 35,
    this.expandWidth = false,
    this.centered = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final bool isLoading;
  final double? width;
  final double? height;
  final bool expandWidth;
  final bool centered;

  static const EdgeInsets _textPadding =
      EdgeInsets.symmetric(horizontal: 8, vertical: 4);

  @override
  Widget build(BuildContext context) {
    final button = _buildButton(context);
    if (variant == CustomButtonVariant.text || !centered) {
      return button;
    }
    return Center(child: button);
  }

  Widget _buildButton(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    switch (variant) {
      case CustomButtonVariant.primary:
        return SizedBox(
          width: expandWidth ? double.infinity : width,
          height: height,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            style: _primaryStyle,
            child: _buildLabelArea(),
          ),
        );
      case CustomButtonVariant.secondary:
        return SizedBox(
          width: expandWidth ? double.infinity : width,
          height: height,
          child: OutlinedButton(
            onPressed: effectiveOnPressed,
            style: _secondaryStyle,
            child: _buildLabelArea(isOutlined: true),
          ),
        );
      case CustomButtonVariant.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            padding: _textPadding,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(label, style: const TextStyle(fontSize: 14)),
        );
    }
  }

  Widget _buildLabelArea({bool isOutlined = false}) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Text(
      label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isOutlined ? Colors.black : null,
      ),
    );
  }

  static ButtonStyle get _primaryStyle => ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE1E1E1)),
        ),
      );

  static ButtonStyle get _secondaryStyle => OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: Color(0xFFE1E1E1)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );
}