import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/errors/exceptions.dart';
import '../models/recipe_model.dart';
class RecipeRemoteDatasource {
  final Dio _dio;

  RecipeRemoteDatasource(this._dio);

  Future<List<RecipeModel>> getByCategory(String category) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.filterByCategory,
        queryParameters: {ApiEndpoints.paramCategory: category},
      );

      final meals = response.data['meals'];
      if (meals == null) return [];

      // TheMealDB filter endpoint returns partial models (id + name + thumb)
      // We fetch details for the first 10 to keep it performant
      final partialList = (meals as List)
          .take(10)
          .map((m) => m['idMeal'].toString())
          .toList();

      final detailed = await Future.wait(
        partialList.map((id) => _fetchById(id)),
      );

      return detailed.whereType<RecipeModel>().toList();
    } on DioException catch (e) {
      throw ServerException(
        statusCode: e.response?.statusCode,
        message: e.message,
      );
    }
  }

  Future<List<RecipeModel>> searchByName(String query) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.searchByName,
        queryParameters: {ApiEndpoints.paramSearch: query},
      );

      final meals = response.data['meals'];
      if (meals == null) return [];

      return (meals as List)
          .map((m) => RecipeModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
          statusCode: e.response?.statusCode, message: e.message);
    }
  }

  Future<RecipeModel?> _fetchById(String id) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.lookupById,
        queryParameters: {ApiEndpoints.paramId: id},
      );
      final meals = response.data['meals'];
      if (meals == null || (meals as List).isEmpty) return null;
      return RecipeModel.fromJson(meals.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<RecipeModel?> getById(String id) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.lookupById,
        queryParameters: {ApiEndpoints.paramId: id},
      );
      final meals = response.data['meals'];
      if (meals == null || (meals as List).isEmpty) {
        throw ServerException(message: 'Recipe not found');
      }
      return RecipeModel.fromJson(meals.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
          statusCode: e.response?.statusCode, message: e.message);
    }
  }
}
