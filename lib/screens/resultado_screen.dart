import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/itr_model.dart';

class ResultadoScreen extends StatelessWidget {
  final ITRModel model;
  final Map<String, dynamic> resultado;

  const ResultadoScreen({
    super.key,
    required this.model,
    required this.resultado,
  });

  static final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  static final _percent = NumberFormat('##0.00', 'pt_BR');
  static final _decimal = NumberFormat('##0.00', 'pt_BR');

  bool get _isento => resultado['isento'] == true;
  double get _itrDevido => (resultado['itr_devido'] as num?)?.toDouble() ?? 0;
  double get _vtnTotal => (resultado['vtn_total'] as num?)?.toDouble() ?? 0;
  double get _areaTrib => (resultado['area_tributavel'] as num?)?.toDouble() ?? 0;
  double get _gu => (resultado['grau_utilizacao'] as num?)?.toDouble() ?? 0;
  double get _aliquota => (resultado['aliquota'] as num?)?.toDouble() ?? 0;
  String get _situacao => resultado['situacao_fiscal']?.toString() ?? '';

  Color get _situacaoColor {
    if (_isento) return const Color(0xFF1565C0);
    if (_situacao.contains('Produtivo')) return const Color(0xFF2E7D32);
    if (_situacao.contains('desenvolvimento')) return const Color(0xFFE65100);
    return const Color(0xFFC62828);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Resultado do Cálculo',
          style: TextStyle(color: Color(0xFF1B1B1B), fontSize: 17, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE8E8E8)),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerCard(),
                const SizedBox(height: 16),
                _itrCard(),
                const SizedBox(height: 16),
                _detalhesCard(),
                const SizedBox(height: 16),
                _areasCard(),
                const SizedBox(height: 16),
                _situacaoCard(),
                const SizedBox(height: 24),
                _actionButtons(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model.nomeProprietario.isNotEmpty ? model.nomeProprietario : 'Proprietário',
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${model.municipio} / ${model.uf} — Ano ${model.anoReferencia}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          if (model.nirf.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'NIRF: ${model.nirf}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _itrCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _isento ? const Color(0xFF1565C0) : const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            _isento ? Icons.check_circle_outline : Icons.receipt_long_outlined,
            color: Colors.white70,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            _isento ? 'Imóvel Isento de ITR' : 'ITR a Recolher',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            _isento ? 'R\$ 0,00' : _currency.format(_itrDevido),
            style: const TextStyle(
              fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white,
            ),
          ),
          if (_isento) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Pequena gleba — até 30 ha (Lei 9.393/96)',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detalhesCard() {
    return _card(
      'Detalhes do Cálculo',
      Icons.calculate_outlined,
      Column(
        children: [
          _linha('Área Total', '${_decimal.format(model.areaTotal)} ha'),
          _linha('Área Tributável', '${_decimal.format(_areaTrib)} ha'),
          _divisor(),
          _linha('VTN / hectare', _currency.format(model.vtnHectare)),
          _linha('VTN Total', _currency.format(_vtnTotal), destaque: true),
          _divisor(),
          _linha('Grau de Utilização (GU)', '${_percent.format(_gu)}%'),
          _linha('Alíquota aplicada', '${_percent.format(_aliquota)}%'),
          _divisor(),
          _linha(
            'ITR Devido',
            _isento ? 'Isento' : _currency.format(_itrDevido),
            destaque: true,
            cor: _isento ? const Color(0xFF1565C0) : const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }

  Widget _areasCard() {
    return _card(
      'Composição das Áreas',
      Icons.map_outlined,
      Column(
        children: [
          _subtitulo('Áreas excluídas da tributação'),
          _linha('Preservação Permanente (APP)', '${_decimal.format(model.areaPreservacaoPermanente)} ha'),
          _linha('Reserva Legal', '${_decimal.format(model.areaReservaLegal)} ha'),
          _linha('Área Imprestável', '${_decimal.format(model.areaImprestavel)} ha'),
          _linha('Edificações', '${_decimal.format(model.areaEdificacoes)} ha'),
          _divisor(),
          _subtitulo('Áreas utilizadas (GU)'),
          _linha('Culturas e Lavouras', '${_decimal.format(model.areaCulturas)} ha'),
          _linha('Pastagens', '${_decimal.format(model.areaPasagens)} ha'),
          _linha('Florestas Cultivadas', '${_decimal.format(model.areaFlorestasCultivadas)} ha'),
        ],
      ),
    );
  }

  Widget _situacaoCard() {
    final avisos = _buildAvisos();
    return _card(
      'Situação Fiscal',
      Icons.fact_check_outlined,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _situacaoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _situacaoColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _situacao,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _situacaoColor,
                  ),
                ),
              ),
            ],
          ),
          if (avisos.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...avisos,
          ],
        ],
      ),
    );
  }

  List<Widget> _buildAvisos() {
    final avisos = <Widget>[];

    if (_gu < 50 && !_isento) {
      avisos.add(_aviso(
        Icons.warning_amber_outlined,
        'Atenção: Grau de Utilização abaixo de 50%. O imóvel pode ser classificado como improdutivo, '
        'sujeito a desapropriação para fins de reforma agrária.',
        const Color(0xFFC62828),
      ));
    }

    if (_gu >= 80) {
      avisos.add(_aviso(
        Icons.check_circle_outline,
        'Parabéns! O imóvel possui alta produtividade (GU ≥ 80%), garantindo a menor alíquota de ITR.',
        const Color(0xFF2E7D32),
      ));
    }

    if (_isento) {
      avisos.add(_aviso(
        Icons.info_outline,
        'Imóvel com até 30 hectares explorado por agricultor familiar é isento de ITR. '
        'Mantenha a declaração em dia para preservar o benefício.',
        const Color(0xFF1565C0),
      ));
    }

    return avisos;
  }

  Widget _aviso(IconData icon, String texto, Color cor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(fontSize: 13, color: cor, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Editar dados'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
              side: const BorderSide(color: Color(0xFF2E7D32)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            icon: const Icon(Icons.home_outlined, size: 18),
            label: const Text('Novo cálculo'),
          ),
        ),
      ],
    );
  }

  Widget _card(String title, IconData icon, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF558B2F)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1B1B1B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _linha(String label, String valor, {bool destaque = false, Color? cor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: destaque ? const Color(0xFF1B1B1B) : const Color(0xFF555555),
                fontWeight: destaque ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 13,
              fontWeight: destaque ? FontWeight.w700 : FontWeight.w500,
              color: cor ?? const Color(0xFF1B1B1B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subtitulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: Color(0xFF2E7D32), letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _divisor() => const Divider(height: 20, color: Color(0xFFEEEEEE));
}
