# frozen_string_literal: true

# Backend Ruby — Sistema ITR
# Requer: gem install sinatra sinatra-cross_origin
# Rodar: ruby server.rb

require 'sinatra'
require 'sinatra/cross_origin'
require 'json'

configure do
  enable :cross_origin
  set :port, 4567
  set :bind, '0.0.0.0'
end

before do
  response.headers['Access-Control-Allow-Origin'] = '*'
  content_type :json
end

options '*' do
  response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
  200
end

# ---------------------------------------------------------------------------
# Tabela de alíquotas ITR — Receita Federal (Lei 9.393/96, art. 11)
# Estrutura: { area_max => { gu_min => aliquota } }
# ---------------------------------------------------------------------------
TABELA_ALIQUOTAS = {
  50    => { 80 => 0.03, 65 => 0.20, 50 => 0.40, 30 => 0.70, 0 => 1.00 },
  200   => { 80 => 0.07, 65 => 0.40, 50 => 0.80, 30 => 1.40, 0 => 2.00 },
  500   => { 80 => 0.10, 65 => 0.60, 50 => 1.30, 30 => 2.30, 0 => 3.30 },
  1_000 => { 80 => 0.15, 65 => 0.85, 50 => 1.90, 30 => 3.40, 0 => 4.70 },
  5_000 => { 80 => 0.30, 65 => 1.60, 50 => 3.40, 30 => 6.00, 0 => 8.60 },
  Float::INFINITY => { 80 => 0.45, 65 => 3.00, 50 => 6.40, 30 => 12.00, 0 => 20.00 }
}.freeze

APTIDOES_VTN = %w[
  lavoura_aptidao_boa
  lavoura_aptidao_regular
  lavoura_aptidao_restrita
  pastagem_plantada
  pastagem_natural
  silvicultura_preservacao
].freeze

VTN_2025 = JSON.parse(
  File.read(File.join(__dir__, 'assets', 'data', 'vtn_2025.json'))
).freeze

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def buscar_aliquota(area_total, grau_utilizacao)
  faixa = TABELA_ALIQUOTAS.keys.find { |limite| area_total <= limite }
  faixa_gu = TABELA_ALIQUOTAS[faixa]

  gu_limite = faixa_gu.keys.sort.reverse.find { |limite| grau_utilizacao >= limite }
  faixa_gu[gu_limite]
end

def normalizar_municipio(texto)
  texto.to_s
       .unicode_normalize(:nfkd)
       .encode('ASCII', invalid: :replace, undef: :replace, replace: '')
       .upcase
       .gsub(/[^A-Z0-9 ]/, ' ')
       .squeeze(' ')
       .strip
end

def buscar_vtn_2025(municipio, uf, aptidao)
  aptidao = APTIDOES_VTN.include?(aptidao) ? aptidao : 'lavoura_aptidao_boa'
  municipio_normalizado = normalizar_municipio(municipio)
  uf_normalizada = uf.to_s.strip.upcase

  referencia = VTN_2025.find do |item|
    item['uf'] == uf_normalizada && item['municipio'] == municipio_normalizado
  end

  referencia ||= VTN_2025.find do |item|
    item['uf'] == 'GO' && item['municipio'] == 'CAMPINORTE'
  end

  [referencia, aptidao, referencia[aptidao].to_f]
end

def calcular(dados)
  area_total                = dados['area_total'].to_f
  area_app                  = dados['area_preservacao_permanente'].to_f
  area_rl                   = dados['area_reserva_legal'].to_f
  area_imp                  = dados['area_imprestavel'].to_f
  area_edif                 = dados['area_edificacoes'].to_f
  area_culturas             = dados['area_culturas'].to_f
  area_pastagens            = dados['area_pasagens'].to_f
  area_florestas            = dados['area_florestas_cultivadas'].to_f
  vtn_hectare               = dados['vtn_hectare'].to_f

  # Área tributável
  area_excluida   = area_app + area_rl + area_imp + area_edif
  area_tributavel = [area_total - area_excluida, 0].max

  # VTN total
  vtn_total = vtn_hectare * area_tributavel

  # Grau de utilização
  area_utilizada   = area_culturas + area_pastagens + area_florestas
  grau_utilizacao  = area_tributavel > 0 ? [(area_utilizada / area_tributavel) * 100, 100].min : 0.0

  # Isenção — pequena gleba (até 30 ha, agricultor familiar)
  isento = area_total <= 30.0

  # Alíquota e imposto
  aliquota  = isento ? 0.0 : buscar_aliquota(area_total, grau_utilizacao)
  itr_devido = vtn_total * (aliquota / 100.0)

  # Situação fiscal
  situacao =
    if isento then 'Isento'
    elsif grau_utilizacao >= 80 then 'Produtivo'
    elsif grau_utilizacao >= 50 then 'Em desenvolvimento'
    else 'Improdutivo — risco de desapropriação'
    end

  {
    area_tributavel:  area_tributavel.round(4),
    vtn_total:        vtn_total.round(2),
    grau_utilizacao:  grau_utilizacao.round(4),
    aliquota:         aliquota,
    itr_devido:       itr_devido.round(2),
    isento:           isento,
    situacao_fiscal:  situacao,
    area_excluida:    area_excluida.round(4),
    area_utilizada:   area_utilizada.round(4)
  }
end

# ---------------------------------------------------------------------------
# Rotas
# ---------------------------------------------------------------------------

# POST /calcular — recebe dados do imóvel e retorna o cálculo
post '/calcular' do
  dados = JSON.parse(request.body.read)
  resultado = calcular(dados)
  resultado.to_json
rescue JSON::ParserError => e
  status 400
  { erro: "JSON inválido: #{e.message}" }.to_json
rescue => e
  status 500
  { erro: e.message }.to_json
end

# GET /vtn — retorna VTN de referência para um município
get '/vtn' do
  referencia, aptidao, vtn = buscar_vtn_2025(
    params['municipio'],
    params['uf'] || 'GO',
    params['aptidao']
  )

  {
    municipio: params['municipio'],
    uf: params['uf'] || 'GO',
    aptidao: aptidao,
    vtn_hectare: vtn,
    referencia: referencia,
    fonte: 'Planilha VTN 2025 para publicacao',
    observacao: referencia['municipio'] == normalizar_municipio(params['municipio']) ? 'Valor especifico encontrado' : 'Valor padrao de Campinorte/GO aplicado'
  }.to_json
end

# GET /health — verificação de saúde do servidor
get '/health' do
  { status: 'ok', servico: 'Sistema ITR - Backend Ruby', versao: '1.0.0' }.to_json
end

# GET /tabela_aliquotas — retorna a tabela de alíquotas para consulta
get '/tabela_aliquotas' do
  tabela = TABELA_ALIQUOTAS.map do |area_max, faixas_gu|
    {
      area_max: area_max == Float::INFINITY ? 'Acima de 5.000 ha' : "Até #{area_max} ha",
      faixas: faixas_gu.map { |gu_min, aliq|
        {
          grau_utilizacao_minimo: "#{gu_min}%",
          aliquota: "#{aliq}%"
        }
      }
    }
  end
  tabela.to_json
end
