import 'dart:convert';
import 'package:http/http.dart' as http;

/// A service class to fetch word definitions from a public dictionary API.
class DictionaryService {
  static const String _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  /// Fetches the definition of a word.
  ///
  /// Returns a [String] with the first definition, or `null` if not found or an error occurs.
  Future<String?> fetchDefinition(String word) async {
    final url = Uri.parse('$_baseUrl/$word');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final definition = data[0]['meanings'][0]['definitions'][0]['definition'];
        return definition.toString();
      } else {
        // Word not found or API error
        return null;
      }
    } catch (e) {
      print('DictionaryService error: $e');
      return null;
    }
  }
}
