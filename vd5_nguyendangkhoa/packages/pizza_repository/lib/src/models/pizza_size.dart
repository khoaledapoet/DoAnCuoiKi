enum PizzaSize {
  small('Nhỏ', 1.0),
  medium('Vừa', 1.3),
  large('Lớn', 1.6);

  final String label;
  final double priceMultiplier;

  const PizzaSize(this.label, this.priceMultiplier);

  // Convert from string
  static PizzaSize fromString(String size) {
    switch (size.toLowerCase()) {
      case 'small':
      case 'nhỏ':
        return PizzaSize.small;
      case 'medium':
      case 'vừa':
        return PizzaSize.medium;
      case 'large':
      case 'lớn':
        return PizzaSize.large;
      default:
        return PizzaSize.medium; // Default
    }
  }

  // Convert to string for Firestore
  String toFirestore() {
    return name; // 'small', 'medium', 'large'
  }
}
