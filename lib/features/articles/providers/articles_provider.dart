import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ruang_sehat/features/articles/data/articles_model.dart';
import 'package:ruang_sehat/features/articles/data/articles_services.dart';

class ArticlesProvider with ChangeNotifier {
  List<ArticlesModel> _articles = [];
  List<ArticlesModel> _myArticles = [];
  ArticlesModel? _detailArticle;
  List<ArticlesModel> _featuredArticles = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isFetchingMore = false;
  int _currentPage = 1;
  bool _hasNextPage = true;

  

  List<ArticlesModel> get articles => _articles;
  List<ArticlesModel> get myArticles => _myArticles;
  List<ArticlesModel> get featuredArticles => _featuredArticles;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasNextPage => _hasNextPage;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  ArticlesModel? get detailArticle => _detailArticle;

  

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setFetchingMore(bool value) {
    _isFetchingMore = value;
    notifyListeners();
  }

  void _resetMessage() {
    _errorMessage = null;
    _successMessage = null;
  }

  String _parseError(Object e) {
    return e.toString().replaceAll('Exception: ', '');
  }

  

  Future<void> getArticles({bool isRefresh = true}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasNextPage = true;
      _setLoading(true);
    } else {
      if (!_hasNextPage || _isFetchingMore) return;
      _setFetchingMore(true);
    }

    _resetMessage();

    try {
      final result = await ArticleServices.getArticles(
        page: _currentPage,
        limit: 5,
      );

      final List<ArticlesModel> data = result['articles'];
      final int totalPages = result['totalPages'];

      if (isRefresh) {
        _articles = data;

        
        if (totalPages > 1) {
          final lastPage = await ArticleServices.getArticles(
            page: totalPages,
            limit: 5,
          );
          _featuredArticles = lastPage['articles'];
        } else {
          _featuredArticles =
              data.length > 5 ? data.sublist(0, 5) : List.from(data);
        }
      } else {
        _articles.addAll(data);
      }

      if (data.length < 5) {
        _hasNextPage = false;
      } else {
        _currentPage++;
      }

      if (data.isEmpty && isRefresh) {
        _errorMessage = 'Data artikel kosong';
      }
    } catch (e) {
      _errorMessage = _parseError(e);
      if (isRefresh) _articles = [];
    } finally {
      if (isRefresh) {
        _setLoading(false);
      } else {
        _setFetchingMore(false);
      }
    }
  }

  Future<void> getMyArticles() async {
    _setLoading(true);
    _resetMessage();

    try {
      final result = await ArticleServices.getMyArticles();
      _myArticles = result;
    } catch (e) {
      _errorMessage = _parseError(e);
      _myArticles = [];
    } finally {
      _setLoading(false);
    }
  }


  Future<void> getDetailArticle(String id) async {
    _setLoading(true);
    _resetMessage();

    try {
      final result = await ArticleServices.getDetailArticle(id);
      _detailArticle = result;
    } catch (e) {
      _errorMessage = _parseError(e);
      _detailArticle = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createArticle(
    String title,
    String description,
    String category,
    String imagePath,
  ) async {
    _setLoading(true);
    _resetMessage();

    try {
      final streamedResponse = await ArticleServices.createArtikel(
        File(imagePath),
        title,
        description,
        category,
      );

      final response = await http.Response.fromStream(streamedResponse);

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.body.startsWith('<')) {
        _errorMessage = "Server mengembalikan HTML. Cek BASE_URL / endpoint.";
        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _successMessage = data['message'] ?? 'Artikel berhasil dibuat';
      } else if (response.statusCode == 400) {
        final firstError = data['errors'][0];
        _errorMessage = firstError['message'] ?? 'Terjadi kesalahan';
      } else {
        _errorMessage = data['message'] ?? 'Terjadi kesalahan';
      }
    } catch (e) {
      _errorMessage = _parseError(e);
    } finally {
      _setLoading(false);
    }

    
    if (_errorMessage == null) {
      await getMyArticles();
      await getArticles();
    }
  }

  Future<void> updateArticle(
    String id, {
    String? title,
    String? description,
    String? category,
    String? imagePath,
  }) async {
    _setLoading(true);
    _resetMessage();

    try {
      final streamedResponse = await ArticleServices.updateArtikel(
        id,
        title: title,
        description: description,
        category: category,
        image: imagePath != null ? File(imagePath) : null,
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.body.startsWith('<')) {
        _errorMessage = "Server mengembalikan HTML. Cek endpoint.";
        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _successMessage = data['message'] ?? 'Artikel berhasil diperbarui';
      } else if (response.statusCode == 400) {
        final firstError = data['errors'][0];
        _errorMessage = firstError['message'] ?? 'Terjadi kesalahan';
      } else {
        _errorMessage = data['message'] ?? 'Terjadi kesalahan';
      }
    } catch (e) {
      _errorMessage = _parseError(e);
    } finally {
      _setLoading(false);
    }

    if (_errorMessage == null) {
      await getMyArticles();
      await getArticles();
      await getDetailArticle(id);
    }
  }

  Future<void> deleteArticle(String id) async {
    _setLoading(true);
    _resetMessage();

    try {
      final result = await ArticleServices.deleteArtikel(id);

      if (result.body.startsWith('<')) {
        _errorMessage = "Server mengembalikan HTML.";
        return;
      }

      final data = jsonDecode(result.body);

      if (result.statusCode == 200) {
        _successMessage = data['message'] ?? 'Artikel berhasil dihapus';
      } else if (result.statusCode == 400) {
        final firstError = data['errors'][0];
        _errorMessage = firstError['message'] ?? 'Terjadi kesalahan';
      } else {
        _errorMessage = data['message'] ?? 'Terjadi kesalahan';
      }
    } catch (e) {
      _errorMessage = _parseError(e);
    } finally {
      _setLoading(false);
    }

    if (_errorMessage == null) {
      await getMyArticles();
      await getArticles();
    }
  }
}