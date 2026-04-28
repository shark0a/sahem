abstract class ApiEndpoints {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Recipe endpoints
  static const String searchByName = '/search.php'; // ?s=name
  static const String filterByCategory = '/filter.php'; // ?c=category
  static const String lookupById = '/lookup.php'; // ?i=id
  static const String randomMeal = '/random.php';
  static const String categories = '/categories.php';
  static const String listCategories = '/list.php'; // ?c=list

  // Query parameters
  static const String paramSearch = 's';
  static const String paramCategory = 'c';
  static const String paramId = 'i';
  static const String paramArea = 'a';
}
