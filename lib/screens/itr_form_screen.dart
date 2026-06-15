import 'package:flutter/material.dart';
import '../models/itr_model.dart';
import '../services/itr_service.dart';
import 'resultado_screen.dart';

class ITRFormScreen extends StatefulWidget {
  const ITRFormScreen({super.key});

  @override
  State<ITRFormScreen> createState() => _ITRFormScreenState();
}

class _ITRFormScreenState extends State<ITRFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ITRModel _model = ITRModel();
  int _currentStep = 0;
  bool _loading = false;
  bool _buscandoVtn = false;
  String _aptidaoSelecionada = 'lavoura_aptidao_boa';

  static const _aptidoesVtn = {
    'lavoura_aptidao_boa': 'Lavoura - aptidao boa',
    'lavoura_aptidao_regular': 'Lavoura - aptidao regular',
    'lavoura_aptidao_restrita': 'Lavoura - aptidao restrita',
    'pastagem_plantada': 'Pastagem plantada',
    'pastagem_natural': 'Pastagem natural',
    'silvicultura_preservacao': 'Silvicultura ou preservacao',
  };

  // Controllers
  final _nirfCtrl = TextEditingController();
  final _nomeCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _municipioCtrl = TextEditingController(text: 'Campinorte');
  final _areaTotalCtrl = TextEditingController();
  final _areaAPPCtrl = TextEditingController(text: '0');
  final _areaRLCtrl = TextEditingController(text: '0');
  final _areaImpCtrl = TextEditingController(text: '0');
  final _areaEdifCtrl = TextEditingController(text: '0');
  final _areaCultCtrl = TextEditingController(text: '0');
  final _areaPastCtrl = TextEditingController(text: '0');
  final _areaFloreCtrl = TextEditingController(text: '0');
  final _vtnCtrl = TextEditingController(text: '10957,78');

  @override
  void initState() {
    super.initState();
    _buscarVTNPlanilha(mostrarMensagem: false);
  }

  @override
  void dispose() {
    for (var c in [
      _nirfCtrl,
      _nomeCtrl,
      _cpfCtrl,
      _municipioCtrl,
      _areaTotalCtrl,
      _areaAPPCtrl,
      _areaRLCtrl,
      _areaImpCtrl,
      _areaEdifCtrl,
      _areaCultCtrl,
      _areaPastCtrl,
      _areaFloreCtrl,
      _vtnCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double _parse(String v) => double.tryParse(v.replaceAll(',', '.')) ?? 0;

  String _formatarEntradaDecimal(double valor) {
    return valor.toStringAsFixed(2).replaceAll('.', ',');
  }

  Future<void> _buscarVTNPlanilha({bool mostrarMensagem = true}) async {
    setState(() => _buscandoVtn = true);
    try {
      final referencia = await ITRService.buscarReferenciaVTN2025(
        _municipioCtrl.text,
        _model.uf,
      );

      final valor = referencia?[_aptidaoSelecionada];
      if (valor is num) {
        _vtnCtrl.text = _formatarEntradaDecimal(valor.toDouble());
        if (mounted && mostrarMensagem) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('VTN atualizado com a planilha oficial de 2025.'),
            ),
          );
        }
      } else if (mounted && mostrarMensagem) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nao encontrei VTN 2025 para ${_municipioCtrl.text}/${_model.uf}.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _buscandoVtn = false);
    }
  }

  void _syncModel() {
    _model
      ..nirf = _nirfCtrl.text
      ..nomeProprietario = _nomeCtrl.text
      ..cpfCnpj = _cpfCtrl.text
      ..municipio = _municipioCtrl.text
      ..areaTotal = _parse(_areaTotalCtrl.text)
      ..areaPreservacaoPermanente = _parse(_areaAPPCtrl.text)
      ..areaReservaLegal = _parse(_areaRLCtrl.text)
      ..areaImprestavel = _parse(_areaImpCtrl.text)
      ..areaEdificacoes = _parse(_areaEdifCtrl.text)
      ..areaCulturas = _parse(_areaCultCtrl.text)
      ..areaPasagens = _parse(_areaPastCtrl.text)
      ..areaFlorestasCultivadas = _parse(_areaFloreCtrl.text)
      ..vtnHectare = _parse(_vtnCtrl.text);
  }

  Future<void> _calcular() async {
    _syncModel();
    setState(() => _loading = true);
    try {
      final resultado = await ITRService.calcularITR(_model);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                ResultadoScreen(model: _model, resultado: resultado),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Cálculo de ITR',
          style: TextStyle(
            color: Color(0xFF1B1B1B),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
            key: _formKey,
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 2) {
                  setState(() => _currentStep++);
                } else {
                  if (_formKey.currentState!.validate()) _calcular();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) setState(() => _currentStep--);
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: _loading ? null : details.onStepContinue,
                        child: _loading && _currentStep == 2
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _currentStep == 2 ? 'Calcular ITR' : 'Próximo',
                              ),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF555555),
                            side: const BorderSide(color: Color(0xFFCCCCCC)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                          child: const Text('Voltar'),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: [_stepDadosImovel(), _stepAreas(), _stepVTN()],
            ),
          ),
        ),
      ),
    );
  }

  Step _stepDadosImovel() {
    return Step(
      title: const Text('Dados do Imóvel'),
      subtitle: const Text('Identificação e localização'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          _field(
            label: 'NIRF (Número no INCRA)',
            hint: 'Ex: 123456789-0',
            controller: _nirfCtrl,
            icon: Icons.tag,
          ),
          _field(
            label: 'Nome do Proprietário',
            hint: 'Nome completo',
            controller: _nomeCtrl,
            icon: Icons.person_outline,
            validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
          ),
          _field(
            label: 'CPF / CNPJ',
            hint: '000.000.000-00',
            controller: _cpfCtrl,
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _field(
                  label: 'Município',
                  hint: 'Campinorte',
                  controller: _municipioCtrl,
                  icon: Icons.location_city_outlined,
                  validator: (v) => v!.isEmpty ? 'Informe o município' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _dropdownUF()),
            ],
          ),
          _field(
            label: 'Ano de Referência',
            hint: '2024',
            icon: Icons.calendar_today_outlined,
            initialValue: '2024',
            keyboardType: TextInputType.number,
            onChanged: (v) => _model.anoReferencia = int.tryParse(v) ?? 2024,
          ),
        ],
      ),
    );
  }

  Step _stepAreas() {
    return Step(
      title: const Text('Áreas do Imóvel'),
      subtitle: const Text('Informe as áreas em hectares'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Área total'),
          _field(
            label: 'Área Total (ha)',
            hint: '0.00',
            controller: _areaTotalCtrl,
            icon: Icons.crop_square_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              final d = _parse(v ?? '');
              return d <= 0 ? 'Informe a área total' : null;
            },
          ),
          _sectionLabel('Áreas excluídas da tributação'),
          _infoBox(
            'Estas áreas são deduzidas do cálculo do ITR conforme legislação.',
          ),
          _field(
            label: 'Área de Preservação Permanente — APP (ha)',
            hint: '0.00',
            controller: _areaAPPCtrl,
            icon: Icons.park_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          _field(
            label: 'Reserva Legal (ha)',
            hint: '0.00',
            controller: _areaRLCtrl,
            icon: Icons.forest_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          _field(
            label: 'Área Inaproveitável / Imprestável (ha)',
            hint: '0.00',
            controller: _areaImpCtrl,
            icon: Icons.terrain_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          _field(
            label: 'Edificações e Benfeitorias (ha)',
            hint: '0.00',
            controller: _areaEdifCtrl,
            icon: Icons.home_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          _sectionLabel('Áreas utilizadas (para cálculo do GU)'),
          _infoBox(
            'O Grau de Utilização (GU) define a alíquota do imposto. Quanto maior o aproveitamento, menor o imposto.',
          ),
          _field(
            label: 'Lavouras e Culturas (ha)',
            hint: '0.00',
            controller: _areaCultCtrl,
            icon: Icons.grass_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          _field(
            label: 'Pastagens (ha)',
            hint: '0.00',
            controller: _areaPastCtrl,
            icon: Icons.agriculture_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          _field(
            label: 'Florestas Cultivadas (ha)',
            hint: '0.00',
            controller: _areaFloreCtrl,
            icon: Icons.nature_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }

  Step _stepVTN() {
    return Step(
      title: const Text('Valor da Terra Nua — VTN'),
      subtitle: const Text('Base de cálculo do ITR'),
      isActive: _currentStep >= 2,
      state: StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoBox(
            'O VTN é o valor do imóvel rural sem considerar construções, culturas, florestas e benfeitorias. '
            'O app usa como base a Planilha VTN 2025 informada e permite ajuste manual quando necessario.',
          ),
          _dropdownAptidaoVTN(),
          _field(
            label: 'VTN por Hectare (R\$/ha)',
            hint: '0.00',
            controller: _vtnCtrl,
            icon: Icons.attach_money_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              final d = _parse(v ?? '');
              return d <= 0 ? 'Informe o VTN por hectare' : null;
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _buscandoVtn ? null : _buscarVTNPlanilha,
              icon: _buscandoVtn
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.table_chart_outlined, size: 18),
              label: const Text('Usar VTN da planilha 2025'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: const Color(0xFF2E7D32),
                side: const BorderSide(color: Color(0xFF2E7D32)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Color(0xFF558B2F),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Referencia para Campinorte/GO em 2025: R\$ 10.957,78/ha para lavoura de aptidao boa.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF3D3D3D)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E7D32),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _infoBox(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: Color(0xFF2E7D32),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1B5E20),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    String? initialValue,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF558B2F)),
        ),
      ),
    );
  }

  Widget _dropdownAptidaoVTN() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: _aptidaoSelecionada,
        decoration: const InputDecoration(
          labelText: 'Tipo de aptidao da planilha VTN 2025',
          prefixIcon: Icon(
            Icons.landscape_outlined,
            size: 20,
            color: Color(0xFF558B2F),
          ),
        ),
        items: _aptidoesVtn.entries
            .map(
              (entry) =>
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
            )
            .toList(),
        onChanged: (v) {
          if (v == null) return;
          setState(() => _aptidaoSelecionada = v);
          _buscarVTNPlanilha(mostrarMensagem: false);
        },
      ),
    );
  }

  Widget _dropdownUF() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: _model.uf,
        decoration: const InputDecoration(labelText: 'UF'),
        items: [
          'GO',
          'MT',
          'MS',
          'MG',
          'BA',
          'SP',
          'PR',
          'RS',
          'SC',
          'PA',
          'TO',
        ].map((uf) => DropdownMenuItem(value: uf, child: Text(uf))).toList(),
        onChanged: (v) {
          _model.uf = v ?? 'GO';
          _buscarVTNPlanilha(mostrarMensagem: false);
        },
      ),
    );
  }
}
