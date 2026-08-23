/// # Mini Project 2 — Calculator App
///
/// **Tujuan:** Praktikkan topik Phase 2:
/// - StatefulWidget (state angka, operator, display)
/// - GridView untuk tombol
/// - Custom widget extraction (tombol kalkulator)
/// - Business logic sederhana di Flutter
///
/// **Fitur:**
/// - Operasi dasar: +, -, ×, ÷
/// - Clear (AC) dan backspace
/// - Toggle +/-
/// - Persen (%)
/// - History operasi sederhana
/// - Display dua baris (expression + result)
///
/// Jalankan: `flutter run -t lib/phase2/mini_projects/calculator/calculator_app.dart`

import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

// ===========================================================================
// APP ROOT
// ===========================================================================

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true, brightness: Brightness.dark),
      home: const CalculatorScreen(),
    );
  }
}

// ===========================================================================
// BUSINESS LOGIC
// ===========================================================================

/// Semua logic kalkulator dipisah dari UI agar mudah ditest.
class CalculatorLogic {
  String _display = '0';      // angka yang ditampilkan saat ini
  String _expression = '';    // ekspresi lengkap (misal: "12 + 34")
  double? _firstOperand;      // operand pertama
  String? _pendingOperator;   // operator yang belum dieksekusi
  bool _resetNext = false;    // flag: input berikutnya reset display

  String get display => _display;
  String get expression => _expression;

  /// Klik angka atau titik desimal.
  void inputDigit(String digit) {
    if (_resetNext) {
      _display = digit == '.' ? '0.' : digit;
      _resetNext = false;
    } else {
      if (digit == '.' && _display.contains('.')) return; // hanya satu titik
      _display = _display == '0' && digit != '.' ? digit : _display + digit;
    }
  }

  /// Klik operator (+, -, ×, ÷).
  void inputOperator(String op) {
    final current = double.tryParse(_display) ?? 0;

    if (_pendingOperator != null && !_resetNext) {
      // Ada operator pending & user sudah ketik angka → hitung dulu
      _firstOperand = _calculate(_firstOperand!, _pendingOperator!, current);
      _display = _formatResult(_firstOperand!);
    } else {
      _firstOperand = current;
    }

    _pendingOperator = op;
    _expression = '${_formatResult(_firstOperand!)} $op';
    _resetNext = true;
  }

  /// Klik equals.
  void equals() {
    if (_firstOperand == null || _pendingOperator == null) return;

    final second = double.tryParse(_display) ?? 0;
    final result = _calculate(_firstOperand!, _pendingOperator!, second);

    _expression = '${_formatResult(_firstOperand!)} $_pendingOperator ${_formatResult(second)} =';
    _display = _formatResult(result);
    _firstOperand = null;
    _pendingOperator = null;
    _resetNext = true;
  }

  /// AC — clear semua.
  void clear() {
    _display = '0';
    _expression = '';
    _firstOperand = null;
    _pendingOperator = null;
    _resetNext = false;
  }

  /// Backspace — hapus satu karakter.
  void backspace() {
    if (_resetNext || _display.length <= 1) {
      _display = '0';
      _resetNext = false;
    } else {
      _display = _display.substring(0, _display.length - 1);
    }
  }

  /// Toggle +/-.
  void toggleSign() {
    final value = double.tryParse(_display) ?? 0;
    _display = _formatResult(-value);
  }

  /// Persen.
  void percent() {
    final value = double.tryParse(_display) ?? 0;
    _display = _formatResult(value / 100);
  }

  // Hitung operasi
  double _calculate(double a, String op, double b) {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case '×': return a * b;
      case '÷': return b == 0 ? 0 : a / b;
      default: return b;
    }
  }

  // Format hasil: hilangkan .0 untuk bilangan bulat
  String _formatResult(double value) {
    if (value == value.truncateToDouble() && !value.isInfinite) {
      return value.toStringAsFixed(0);
    }
    // Max 8 digit di belakang koma, hapus trailing zeros
    return double.parse(value.toStringAsFixed(8)).toString();
  }
}

// ===========================================================================
// CALCULATOR SCREEN
// ===========================================================================

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _calc = CalculatorLogic();

  void _onButton(String label) {
    setState(() {
      switch (label) {
        case 'AC': _calc.clear();
        case '⌫': _calc.backspace();
        case '+/-': _calc.toggleSign();
        case '%': _calc.percent();
        case '=': _calc.equals();
        case '+': case '-': case '×': case '÷': _calc.inputOperator(label);
        default: _calc.inputDigit(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Display
          Expanded(child: _CalcDisplay(expression: _calc.expression, display: _calc.display)),
          // Keypad
          _CalcKeypad(onButton: _onButton),
        ],
      ),
    );
  }
}

// ===========================================================================
// DISPLAY
// ===========================================================================

class _CalcDisplay extends StatelessWidget {
  final String expression;
  final String display;

  const _CalcDisplay({required this.expression, required this.display});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Ekspresi kecil di atas
          Text(
            expression,
            style: const TextStyle(color: Colors.grey, fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Angka utama besar
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              display,
              style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.w300),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// KEYPAD
// ===========================================================================

class _CalcKeypad extends StatelessWidget {
  final ValueChanged<String> onButton;

  const _CalcKeypad({required this.onButton});

  // Layout tombol: [label, type]
  // type: 'func' = fungsi, 'op' = operator, 'num' = angka
  static const _buttons = [
    ['AC', 'func'],  ['+/-', 'func'], ['%', 'func'],    ['÷', 'op'],
    ['7', 'num'],    ['8', 'num'],    ['9', 'num'],      ['×', 'op'],
    ['4', 'num'],    ['5', 'num'],    ['6', 'num'],      ['-', 'op'],
    ['1', 'num'],    ['2', 'num'],    ['3', 'num'],      ['+', 'op'],
    ['⌫', 'func'],  ['0', 'num'],    ['.', 'num'],      ['=', 'op'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.1,
        ),
        itemCount: _buttons.length,
        itemBuilder: (_, index) {
          final label = _buttons[index][0];
          final type = _buttons[index][1];
          return _CalcButton(label: label, type: type, onTap: () => onButton(label));
        },
      ),
    );
  }
}

// ===========================================================================
// CALC BUTTON
// ===========================================================================

/// Tombol kalkulator — di-extract ke widget sendiri agar reusable dan bersih.
class _CalcButton extends StatelessWidget {
  final String label;
  final String type; // 'func', 'op', 'num'
  final VoidCallback onTap;

  const _CalcButton({required this.label, required this.type, required this.onTap});

  // Warna tombol berdasarkan tipe
  Color get _backgroundColor {
    switch (type) {
      case 'func': return const Color(0xFF505050); // abu-abu
      case 'op':   return const Color(0xFFFF9500); // oranye
      default:     return const Color(0xFF333333); // gelap
    }
  }

  Color get _textColor {
    switch (type) {
      case 'func': return Colors.white;
      case 'op':   return Colors.white;
      default:     return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _backgroundColor,
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        splashColor: Colors.white.withOpacity(0.2),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: _textColor, fontSize: 22, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
