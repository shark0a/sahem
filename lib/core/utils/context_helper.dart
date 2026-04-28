enum MealType { breakfast, lunch, dinner }

class ContextHelper {
  MealType getMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return MealType.breakfast;
    if (hour >= 12 && hour < 17) return MealType.lunch;
    return MealType.dinner;
  }

  String getMealTypeLabel() {
    switch (getMealType()) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }

  String getMealTypeEmoji() {
    switch (getMealType()) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
    }
  }

  String getGreeting() {
    switch (getMealType()) {
      case MealType.breakfast:
        return 'Good Morning';
      case MealType.lunch:
        return 'Good Afternoon';
      case MealType.dinner:
        return 'Good Evening';
    }
  }

  String getRegionCuisine(String countryCode) {
    const map = {
      'EG': 'Egyptian',
      'IT': 'Italian',
      'JP': 'Japanese',
      'IN': 'Indian',
      'FR': 'French',
      'MX': 'Mexican',
      'CN': 'Chinese',
      'GR': 'Greek',
      'US': 'American',
      'GB': 'British',
      'ES': 'Spanish',
      'TH': 'Thai',
      'TR': 'Turkish',
      'MA': 'Moroccan',
      'LB': 'Lebanese',
    };
    return map[countryCode] ?? 'International';
  }

  /// Map country cuisine → TheMealDB category param
  String getCuisineCategory(String countryCode) {
    const map = {
      'EG': 'Chicken',
      'IT': 'Pasta',
      'JP': 'Seafood',
      'IN': 'Vegetarian',
      'FR': 'Lamb',
      'MX': 'Miscellaneous',
      'CN': 'Beef',
      'GR': 'Lamb',
      'US': 'Beef',
      'GB': 'Breakfast',
      'TH': 'Seafood',
    };
    // Default by meal type
    final mealDefault = {
      MealType.breakfast: 'Breakfast',
      MealType.lunch: 'Chicken',
      MealType.dinner: 'Beef',
    };
    return map[countryCode] ?? mealDefault[getMealType()] ?? 'Chicken';
  }

  String getCountryFlag(String countryCode) {
    const flags = {
      'EG': '🇪🇬',
      'IT': '🇮🇹',
      'JP': '🇯🇵',
      'IN': '🇮🇳',
      'FR': '🇫🇷',
      'MX': '🇲🇽',
      'CN': '🇨🇳',
      'GR': '🇬🇷',
      'US': '🇺🇸',
      'GB': '🇬🇧',
      'ES': '🇪🇸',
      'TH': '🇹🇭',
      'TR': '🇹🇷',
      'MA': '🇲🇦',
      'LB': '🇱🇧',
    };
    return flags[countryCode] ?? '🌍';
  }
}
