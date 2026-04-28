abstract class AppStrings {
  // App
  static const String appName = 'Sahem';
  static const String appTagline = "What's cooking today?";

  // Home Screen
  static const String goodMorning = 'Good Morning';
  static const String goodAfternoon = 'Good Afternoon';
  static const String goodEvening = 'Good Evening';
  static const String suggestedForYou = 'Suggested For You';
  static const String popularCategories = 'Popular Categories';
  static const String breakfastTime = 'Breakfast Time';
  static const String lunchTime = 'Lunch Time';
  static const String dinnerTime = 'Dinner Time';

  // Categories
  static const String breakfast = 'Breakfast';
  static const String lunch = 'Lunch';
  static const String dinner = 'Dinner';
  static const String dessert = 'Dessert';

  // Search Screen
  static const String searchRecipes = 'Search Recipes';
  static const String searchPlaceholder = 'Search for recipes...';
  static const String filterAll = 'All';
  static const String filterVegetarian = 'Vegetarian';
  static const String noRecipesFound = 'No recipes found';
  static const String tryAnother = 'Try something else!';

  // Recipe Detail
  static const String ingredients = 'Ingredients';
  static const String instructions = 'Instructions';
  static const String startCooking = 'Start Cooking';
  static const String servings = 'servings';
  static const String calories = 'cal';

  // Favorites Screen
  static const String mySavedRecipes = 'My Saved Recipes ❤️';
  static const String noFavoritesYet = 'No favorites yet!';
  static const String startExploring = 'Start exploring 🍽️';
  static const String swipeToDelete = '💡 Swipe left to delete';

  // Notifications
  static const String breakfastNotificationTitle = '🌅 Breakfast Time!';
  static const String breakfastNotificationBody =
      'Discover a delicious breakfast recipe to start your day!';
  static const String lunchNotificationTitle = '☀️ Lunch Time!';
  static const String lunchNotificationBody =
      'Time for a tasty lunch — check today\'s suggestion!';
  static const String dinnerNotificationTitle = '🌙 Dinner Time!';
  static const String dinnerNotificationBody =
      'Wind down with a wonderful dinner recipe!';
  static const String notificationChannelId = 'sahem_meal_channel';
  static const String notificationChannelName = 'Meal Reminders';
  static const String notificationChannelDesc =
      'Daily meal time recipe suggestions';

  // Errors
  static const String serverError = 'Server error. Please try again.';
  static const String networkError = 'No internet connection.';
  static const String cacheError = 'No cached data available.';
  static const String locationError = 'Could not determine your location.';
  static const String locationPermissionDenied = 'Location permission denied.';
  static const String unknownError = 'Something went wrong.';

  // Offline
  static const String offlineMessage =
      'You\'re offline — showing cached recipes';
  static const String backOnline = 'Back online!';

  // Empty States
  static const String emptySearchTitle = 'No recipes found';
  static const String emptySearchSubtitle =
      'We couldn\'t find a match. Try a different search!';
  static const String emptyFavoritesTitle = 'No favorites yet!';
  static const String emptyFavoritesSubtitle =
      'Tap ❤️ on a recipe to save it here.';

  // Location
  static const String locationDetecting = 'Detecting location...';
  static const String locationUnknown = 'Unknown Location';

  // Workmanager tasks
  static const String workBreakfast = 'sahem_breakfast_notification';
  static const String workLunch = 'sahem_lunch_notification';
  static const String workDinner = 'sahem_dinner_notification';
}
