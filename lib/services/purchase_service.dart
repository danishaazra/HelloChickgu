class PurchaseService {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();

  final Set<String> _purchasedCourseTitles = <String>{};

  bool isPurchased(String courseTitle) => _purchasedCourseTitles.contains(courseTitle);

  void markPurchased(String courseTitle) {
    _purchasedCourseTitles.add(courseTitle);
  }
}


