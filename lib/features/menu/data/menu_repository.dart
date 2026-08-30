import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import 'menu_model.dart';

class MenuRepository {
  MenuRepository(this._dio);

  final Dio _dio;

  Future<List<MenuCategory>> fetchCategories() async {
    final resp = await _dio.get('/menu/categories/', queryParameters: {'limit': 100});
    final results = resp.data['results'] as List<dynamic>;
    return results
        .map((j) => MenuCategory.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<MenuItem>> fetchItems({String? categoryUuid}) async {
    final resp = await _dio.get('/menu/items/', queryParameters: {
      'limit': 200,
      if (categoryUuid != null) 'category': categoryUuid,
    });
    final results = resp.data['results'] as List<dynamic>;
    return results
        .map((j) => MenuItem.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// FR-CAT-03: toggle availability — reflected immediately in discovery
  Future<MenuItem> toggleAvailability(String uuid) async {
    final resp = await _dio.post(
      '/menu/items/$uuid/toggle/',
      data: {},
    );
    return MenuItem.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<MenuItem> updatePrice(String uuid, int newPriceMinor) async {
    final resp = await _dio.patch(
      '/menu/items/$uuid/',
      data: {'base_price_minor': newPriceMinor},
    );
    return MenuItem.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<MenuItem> updateItem(String uuid, Map<String, dynamic> fields) async {
    final resp = await _dio.patch('/menu/items/$uuid/', data: fields);
    return MenuItem.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<MenuItem> createItem(Map<String, dynamic> data) async {
    final resp = await _dio.post('/menu/items/', data: data);
    return MenuItem.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteItem(String uuid) async {
    await _dio.delete('/menu/items/$uuid/');
  }

  /// Upload image via multipart; returns the image URL
  Future<String> uploadPhoto(String itemUuid, File photo) async {
    // Get signed URL from uploads endpoint
    final signedResp = await _dio.post('/uploads/', data: {
      'content_type': 'image/jpeg',
      'entity': 'menu_item',
      'entity_uuid': itemUuid,
    });

    final uploadUrl = signedResp.data['upload_url'] as String;
    final imageUrl = signedResp.data['image_url'] as String;

    // Direct upload to S3 (no proxy through API)
    final uploadDio = Dio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(photo.path),
    });
    await uploadDio.put(uploadUrl, data: formData);

    return imageUrl;
  }
}

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final apiClientAsync = ref.watch(apiClientProvider);
  final dio = apiClientAsync.when(
    data: (c) => c.dio,
    loading: () => Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1/')),
    error: (_, __) => Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1/')),
  );
  return MenuRepository(dio);
});
