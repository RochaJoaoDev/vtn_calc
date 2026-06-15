import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../models/itr_model.dart';

class ITRService {
  static const String _baseUrl = 'http://localhost:4567';
  static List<Map<String, dynamic>>? _vtn2025Cache;

  static Future<Map<String, dynamic>> calcularITR(ITRModel model) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/calcular'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(model.toJson()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Erro no servidor: ${response.statusCode}');
      }
    } catch (_) {
      return _calcularLocal(model);
    }
  }

  static Future<double> buscarVTNMunicipio(
    String municipio,
    String uf, {
    String aptidao = 'lavoura_aptidao_boa',
  }) async {
    final referenciaLocal = await buscarReferenciaVTN2025(municipio, uf);
    final valorLocal = referenciaLocal?[aptidao];
    if (valorLocal is num) return valorLocal.toDouble();

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/vtn?municipio=${Uri.encodeComponent(municipio)}'
          '&uf=$uf&aptidao=$aptidao',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['vtn_hectare'] as num).toDouble();
      }
    } catch (_) {}

    return 10957.78;
  }

  static Future<Map<String, dynamic>?> buscarReferenciaVTN2025(
    String municipio,
    String uf,
  ) async {
    final dados = await _carregarVTN2025();
    final municipioNormalizado = _normalizar(municipio);
    final ufNormalizada = uf.trim().toUpperCase();

    for (final item in dados) {
      if (item['uf'] == ufNormalizada &&
          item['municipio'] == municipioNormalizado) {
        return item;
      }
    }

    return null;
  }

  static Future<List<Map<String, dynamic>>> _carregarVTN2025() async {
    if (_vtn2025Cache != null) return _vtn2025Cache!;

    final jsonString = await rootBundle.loadString('assets/data/vtn_2025.json');
    final dados = jsonDecode(jsonString) as List<dynamic>;
    _vtn2025Cache = dados.cast<Map<String, dynamic>>();
    return _vtn2025Cache!;
  }

  static String _normalizar(String texto) {
    const acentos = {
      'Á': 'A',
      'À': 'A',
      'Â': 'A',
      'Ã': 'A',
      'Ä': 'A',
      'É': 'E',
      'È': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Í': 'I',
      'Ì': 'I',
      'Î': 'I',
      'Ï': 'I',
      'Ó': 'O',
      'Ò': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ö': 'O',
      'Ú': 'U',
      'Ù': 'U',
      'Û': 'U',
      'Ü': 'U',
      'Ç': 'C',
    };

    var resultado = texto.trim().toUpperCase();
    acentos.forEach((origem, destino) {
      resultado = resultado.replaceAll(origem, destino);
    });
    return resultado.replaceAll(RegExp(r'\s+'), ' ');
  }

  static Map<String, dynamic> _calcularLocal(ITRModel model) {
    return {
      'area_tributavel': model.areaTributavel,
      'vtn_total': model.vtnTotal,
      'grau_utilizacao': model.grauUtilizacao,
      'aliquota': model.aliquota,
      'itr_devido': model.itrDevido,
      'isento': model.isento,
      'situacao_fiscal': model.situacaoFiscal,
    };
  }
}
