import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [];

  var _showFavouritesOnly = false;

  List<Product> get items {
    // if(_showFavouritesOnly){
    //   return _items.where((element) => element.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favouriteItems {
    // if(_showFavouritesOnly){
    //   return _items.where((element) => element.isFavorite).toList();
    // }
    return _items.where((element) => element.isFavorite).toList();
  }

  // void showFavouritesOnly(){
  //   _showFavouritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll(){
  //   _showFavouritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts() async {
    var url = Uri.parse(
        'https://flutter-test-f2ad4-default-rtdb.europe-west1.firebasedatabase.app/products.json');

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite: prodData['isFavorite']));
      });
      _items = loadedProducts;
      notifyListeners();
      //print(json.decode(response.body));
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    var url = Uri.parse(
        'https://flutter-test-f2ad4-default-rtdb.europe-west1.firebasedatabase.app/products.json');

    var jsonProduct = json.encode({
      'title': product.title,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'price': product.price,
      'isFavorite': product.isFavorite
    });
    try {
      final response = await http.post(url, body: jsonProduct);
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      // Insert at the start of the list
      // _items.insert(0, newProduct);
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> updateProduct(String id, Product product) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-test-f2ad4-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json');

      var jsonProduct = json.encode({
        'title': product.title,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'isFavorite': product.isFavorite
      });

      await http.patch(url, body: jsonProduct);

      _items[prodIndex] = product;
      notifyListeners();
    } else {}
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://flutter-test-f2ad4-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json');
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }

    // _items.removeWhere((element) => element.id == id);
  }
}
