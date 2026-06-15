class ITRModel {
  // Dados do imóvel
  String nirf;
  String nomeProprietario;
  String cpfCnpj;
  String municipio;
  String uf;
  double areaTotal; // em hectares

  // Áreas por uso (em hectares)
  double areaPreservacaoPermanente;
  double areaReservaLegal;
  double areaImprestavel;
  double areaEdificacoes;
  double areaCulturas;
  double areaPasagens;
  double areaFlorestasCultivadas;

  // VTN - Valor da Terra Nua
  double vtnHectare; // Valor por hectare conforme PATU

  // Ano de referência
  int anoReferencia;

  ITRModel({
    this.nirf = '',
    this.nomeProprietario = '',
    this.cpfCnpj = '',
    this.municipio = '',
    this.uf = 'GO',
    this.areaTotal = 0,
    this.areaPreservacaoPermanente = 0,
    this.areaReservaLegal = 0,
    this.areaImprestavel = 0,
    this.areaEdificacoes = 0,
    this.areaCulturas = 0,
    this.areaPasagens = 0,
    this.areaFlorestasCultivadas = 0,
    this.vtnHectare = 0,
    this.anoReferencia = 2024,
  });

  // Área Tributável = Área Total - áreas excluídas
  double get areaTributavel {
    final excluidas = areaPreservacaoPermanente +
        areaReservaLegal +
        areaImprestavel +
        areaEdificacoes;
    final result = areaTotal - excluidas;
    return result < 0 ? 0 : result;
  }

  // VTN Total = VTN/ha × Área Tributável
  double get vtnTotal => vtnHectare * areaTributavel;

  // Grau de Utilização = Área utilizada / Área tributável × 100
  double get grauUtilizacao {
    if (areaTributavel <= 0) return 0;
    final areaUtilizada = areaCulturas + areaPasagens + areaFlorestasCultivadas;
    final gu = (areaUtilizada / areaTributavel) * 100;
    return gu > 100 ? 100 : gu;
  }

  // Alíquota conforme tabela da Receita Federal (área e GU)
  double get aliquota {
    final gu = grauUtilizacao;
    final area = areaTotal;

    // Tabela progressiva ITR (simplificada)
    if (area <= 50) {
      if (gu >= 80) return 0.03;
      if (gu >= 65) return 0.20;
      if (gu >= 50) return 0.40;
      if (gu >= 30) return 0.70;
      return 1.00;
    } else if (area <= 200) {
      if (gu >= 80) return 0.07;
      if (gu >= 65) return 0.40;
      if (gu >= 50) return 0.80;
      if (gu >= 30) return 1.40;
      return 2.00;
    } else if (area <= 500) {
      if (gu >= 80) return 0.10;
      if (gu >= 65) return 0.60;
      if (gu >= 50) return 1.30;
      if (gu >= 30) return 2.30;
      return 3.30;
    } else if (area <= 1000) {
      if (gu >= 80) return 0.15;
      if (gu >= 65) return 0.85;
      if (gu >= 50) return 1.90;
      if (gu >= 30) return 3.40;
      return 4.70;
    } else if (area <= 5000) {
      if (gu >= 80) return 0.30;
      if (gu >= 65) return 1.60;
      if (gu >= 50) return 3.40;
      if (gu >= 30) return 6.00;
      return 8.60;
    } else {
      if (gu >= 80) return 0.45;
      if (gu >= 65) return 3.00;
      if (gu >= 50) return 6.40;
      if (gu >= 30) return 12.00;
      return 20.00;
    }
  }

  // ITR devido = VTN × alíquota / 100
  double get itrDevido => vtnTotal * (aliquota / 100);

  // Isenção para pequena gleba (agricultura familiar)
  bool get isento {
    // Imóvel com até 30 ha e único explorado pelo proprietário — isento
    return areaTotal <= 30;
  }

  // Situação fiscal resumida
  String get situacaoFiscal {
    if (isento) return 'Isento';
    if (grauUtilizacao >= 80) return 'Produtivo';
    if (grauUtilizacao >= 50) return 'Em desenvolvimento';
    return 'Improdutivo — risco de desapropriação';
  }

  Map<String, dynamic> toJson() => {
        'nirf': nirf,
        'nome_proprietario': nomeProprietario,
        'cpf_cnpj': cpfCnpj,
        'municipio': municipio,
        'uf': uf,
        'area_total': areaTotal,
        'area_preservacao_permanente': areaPreservacaoPermanente,
        'area_reserva_legal': areaReservaLegal,
        'area_imprestavel': areaImprestavel,
        'area_edificacoes': areaEdificacoes,
        'area_culturas': areaCulturas,
        'area_pasagens': areaPasagens,
        'area_florestas_cultivadas': areaFlorestasCultivadas,
        'vtn_hectare': vtnHectare,
        'ano_referencia': anoReferencia,
      };
}
