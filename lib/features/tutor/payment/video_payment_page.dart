import 'package:flutter/material.dart';
import 'package:hellochickgu/services/purchase_service.dart';
import 'payment_flow.dart';

class VideoPaymentPage extends StatelessWidget {
  final String videoId;
  final String title;
  final String priceText;
  const VideoPaymentPage({
    super.key,
    required this.videoId,
    required this.title,
    this.priceText = 'RM 9.90',
  });

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
          onPressed: () => Navigator.of(context).maybePop(false),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unlock Video',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.payments, color: Color(0xff47b2ff)),
                      const SizedBox(width: 8),
                      const Text('Price'),
                      const Spacer(),
                      Text(
                        priceText,
                        style: const TextStyle(
                          color: Color(0xff47b2ff),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder:
                          (_) => PaymentFlow(
                            courseTitle: title,
                            totalPriceText: priceText,
                            skills: const [],
                            videoId: videoId,
                          ),
                    ),
                  );
                  if (result == true) {
                    PurchaseService.instance.markPurchased(videoId);
                    if (context.mounted) {
                      Navigator.of(context).maybePop(true);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff47b2ff),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
