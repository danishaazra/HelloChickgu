import 'package:flutter/material.dart';
import '../../../services/purchase_service.dart';
import '../course_outline.dart';

class PaymentFlow extends StatefulWidget {
  final String courseTitle;
  final String totalPriceText;
  final List<String> skills;
  final String? videoId; // when provided, act as per-video checkout

  const PaymentFlow({
    super.key,
    required this.courseTitle,
    required this.totalPriceText,
    required this.skills,
    this.videoId,
  });

  @override
  State<PaymentFlow> createState() => _PaymentFlowState();
}

class _PaymentFlowState extends State<PaymentFlow> {
  int _stepIndex = 0;
  String _method = 'card';
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe9f3fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (_stepIndex > 0) {
              setState(() => _stepIndex -= 1);
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _Progress(stepIndex: _stepIndex),
          Expanded(child: _buildStep()),
          _BottomBar(
            priceText: widget.totalPriceText,
            onContinue: _onContinue,
            isLast: _stepIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_stepIndex) {
      case 0:
        return _OverviewStep(
          courseTitle: widget.courseTitle,
          skills: widget.skills,
        );
      case 1:
        return _MethodStep(
          selected: _method,
          onChanged: (m) => setState(() => _method = m),
        );
      case 2:
        return _CardStep(
          cardNumber: _cardNumberController,
          cvv: _cvvController,
          expiry: _expiryController,
          name: _nameController,
        );
      case 3:
      default:
        return const _CompletedStep();
    }
  }

  void _onContinue() {
    try {
      if (_stepIndex == 1 && _method != 'card') {
        // For now only card supported
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only card method is supported in this demo'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_stepIndex == 2) {
        final cardNumber = _cardNumberController.text.trim();
        final cvv = _cvvController.text.trim();
        final expiry = _expiryController.text.trim();
        final name = _nameController.text.trim();

        if (cardNumber.isEmpty ||
            cvv.isEmpty ||
            expiry.isEmpty ||
            name.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill all card details'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Basic validation
        if (cardNumber.length < 13 || cardNumber.length > 19) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid card number'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (cvv.length < 3 || cvv.length > 4) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid CVV'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (_stepIndex < 3) {
        setState(() => _stepIndex += 1);
      } else {
        // Finalize purchase: per-video or full course
        if (widget.videoId != null && widget.videoId!.isNotEmpty) {
          Navigator.of(context).maybePop(true);
          return;
        }

        try {
          PurchaseService.instance.markPurchased(widget.courseTitle);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (_) => CourseOutlinePage(
                    courseTitle: widget.courseTitle,
                    university: 'Universiti Putra Malaysia',
                  ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _Progress extends StatelessWidget {
  final int stepIndex;
  const _Progress({required this.stepIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffe9f3fa),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Dot(label: '1', active: stepIndex >= 0),
          Expanded(child: Container(height: 2, color: const Color(0xffcfe9fb))),
          _Dot(label: '2', active: stepIndex >= 1),
          Expanded(child: Container(height: 2, color: const Color(0xffcfe9fb))),
          _Dot(label: '3', active: stepIndex >= 2),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final String label;
  final bool active;
  const _Dot({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor:
          active ? const Color(0xff47b2ff) : const Color(0xffcfe9fb),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _OverviewStep extends StatelessWidget {
  final String courseTitle;
  final List<String> skills;
  const _OverviewStep({required this.courseTitle, required this.skills});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Course Name:',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  courseTitle,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Skills',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (skills.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No skills specified',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  skills
                      .map(
                        (skill) => Chip(
                          label: Text(
                            skill,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.white,
                          elevation: 1,
                        ),
                      )
                      .toList(),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _MethodStep extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _MethodStep({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Select Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          RadioListTile<String>(
            value: 'card',
            groupValue: selected,
            onChanged: (v) => onChanged(v ?? 'card'),
            title: const Text('Credit / Debit Card'),
          ),
          RadioListTile<String>(
            value: 'tng',
            groupValue: selected,
            onChanged: (v) => onChanged(v ?? 'tng'),
            title: const Text('TouchNGo'),
          ),
        ],
      ),
    );
  }
}

class _CardStep extends StatelessWidget {
  final TextEditingController cardNumber;
  final TextEditingController cvv;
  final TextEditingController expiry;
  final TextEditingController name;
  const _CardStep({
    required this.cardNumber,
    required this.cvv,
    required this.expiry,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Add Card Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: cardNumber,
            keyboardType: TextInputType.number,
            maxLength: 19, // 16 digits + 3 spaces
            decoration: _decoration('Card Number (1234 5678 9012 3456)'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: cvv,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: _decoration('CVV'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: expiry,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  decoration: _decoration('MM/YY'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: name,
            textCapitalization: TextCapitalization.words,
            decoration: _decoration('Name on Card'),
            maxLength: 50,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      counterText: '', // Hide character counter
      errorStyle: const TextStyle(fontSize: 12),
    );
  }
}

class _CompletedStep extends StatelessWidget {
  const _CompletedStep();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Image.asset(
              'assets/chicken_payment.png',
              height: 220,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Start Your Learning Today\nBecome the King Chicken',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String priceText;
  final VoidCallback onContinue;
  final bool isLast;
  const _BottomBar({
    required this.priceText,
    required this.onContinue,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      color: const Color(0xffe9f3fa),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.payments, color: Color(0xff47b2ff)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Total Price',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Flexible(
                child: Text(
                  priceText,
                  style: const TextStyle(
                    color: Color(0xff47b2ff),
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff47b2ff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
              ),
              child: Text(
                isLast ? 'Done' : 'Continue',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
