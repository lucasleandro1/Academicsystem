#!/usr/bin/env ruby

# Script para criar arquivos mais elaborados para o seed
require 'fileutils'
require 'date'
require 'json'

seed_files_dir = File.join(__dir__, 'seed_files')
FileUtils.mkdir_p(seed_files_dir)

# Função para criar um documento HTML que pode ser visualizado
def create_html_document(filename, title, content)
  html_content = <<~HTML
    <!DOCTYPE html>
    <html lang="pt-BR">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>#{title}</title>
        <style>
            body {#{' '}
                font-family: Arial, sans-serif;#{' '}
                max-width: 800px;#{' '}
                margin: 0 auto;#{' '}
                padding: 20px;
                line-height: 1.6;
            }
            .header {
                text-align: center;
                border-bottom: 2px solid #333;
                padding-bottom: 20px;
                margin-bottom: 30px;
            }
            .logo {
                font-size: 24px;
                font-weight: bold;
                color: #2c5aa0;
                margin-bottom: 10px;
            }
            .document-title {
                font-size: 20px;
                margin: 20px 0;
                color: #333;
            }
            .content {
                text-align: justify;
                margin: 20px 0;
            }
            .signature {
                margin-top: 50px;
                text-align: center;
            }
            .date {
                text-align: right;
                margin-top: 30px;
                font-style: italic;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin: 20px 0;
            }
            th, td {
                border: 1px solid #ddd;
                padding: 8px;
                text-align: left;
            }
            th {
                background-color: #f2f2f2;
            }
        </style>
    </head>
    <body>
        #{content}
    </body>
    </html>
  HTML

  File.write(filename, html_content)
end

# Função para criar uma imagem SVG simples
def create_svg_image(filename, width, height, content)
  svg_content = <<~SVG
    <?xml version="1.0" encoding="UTF-8"?>
    <svg width="#{width}" height="#{height}" xmlns="http://www.w3.org/2000/svg">
        <rect width="100%" height="100%" fill="#f8f9fa" stroke="#dee2e6" stroke-width="2"/>
        #{content}
    </svg>
  SVG

  File.write(filename, svg_content)
end

puts "📄 Criando documentos HTML mais elaborados..."

# Criar boletim escolar em HTML
boletim_html = <<~HTML
  <div class="header">
      <div class="logo">COLÉGIO ESTADUAL DOM PEDRO II</div>
      <div>Rua da Educação, 456 - Centro - São Paulo/SP</div>
      <div>Tel: (11) 3456-7890 | Email: secretaria@dompedroii.edu.br</div>
  </div>

  <h2 class="document-title">BOLETIM ESCOLAR - 3º BIMESTRE 2025</h2>

  <div class="content">
      <p><strong>Aluno:</strong> Ana Silva Santos</p>
      <p><strong>Turma:</strong> 2º Ano A - Ensino Médio</p>
      <p><strong>Período:</strong> 3º Bimestre (01/08/2025 a 30/09/2025)</p>
  #{'    '}
      <table>
          <thead>
              <tr>
                  <th>Disciplina</th>
                  <th>Nota</th>
                  <th>Faltas</th>
                  <th>Conceito</th>
              </tr>
          </thead>
          <tbody>
              <tr><td>Matemática</td><td>8.5</td><td>2</td><td>B</td></tr>
              <tr><td>Língua Portuguesa</td><td>7.8</td><td>0</td><td>B</td></tr>
              <tr><td>Física</td><td>9.2</td><td>1</td><td>A</td></tr>
              <tr><td>Química</td><td>6.9</td><td>3</td><td>C</td></tr>
              <tr><td>Biologia</td><td>8.1</td><td>1</td><td>B</td></tr>
              <tr><td>História</td><td>7.5</td><td>0</td><td>B</td></tr>
              <tr><td>Geografia</td><td>8.8</td><td>2</td><td>A</td></tr>
              <tr><td>Inglês</td><td>7.0</td><td>1</td><td>B</td></tr>
          </tbody>
      </table>
  #{'    '}
      <p><strong>Média Geral:</strong> 7.98</p>
      <p><strong>Total de Faltas:</strong> 10</p>
      <p><strong>Frequência:</strong> 91.7%</p>
  #{'    '}
      <p><strong>Observações:</strong> Aluno demonstra bom aproveitamento nas disciplinas.#{' '}
      Recomenda-se maior atenção em Química. Parabéns pelo desempenho!</p>
  </div>

  <div class="signature">
      <p>_______________________________</p>
      <p>Mariana Santos Coordenadora</p>
      <p>Coordenação Pedagógica</p>
  </div>

  <div class="date">
      São Paulo, #{Date.today.strftime('%d de %B de %Y')}
  </div>
HTML

create_html_document(
  File.join(seed_files_dir, 'boletim_completo.html'),
  'Boletim Escolar - 3º Bimestre',
  boletim_html
)

# Criar histórico escolar em HTML
historico_html = <<~HTML
  <div class="header">
      <div class="logo">COLÉGIO ESTADUAL DOM PEDRO II</div>
      <div>Rua da Educação, 456 - Centro - São Paulo/SP</div>
      <div>CNPJ: 12.345.678/0001-90</div>
  </div>

  <h2 class="document-title">HISTÓRICO ESCOLAR</h2>

  <div class="content">
      <p><strong>Aluno:</strong> Bruno Santos Silva</p>
      <p><strong>Data de Nascimento:</strong> 15/03/2007</p>
      <p><strong>Nome do Pai:</strong> José Silva</p>
      <p><strong>Nome da Mãe:</strong> Maria Santos</p>
      <p><strong>RG:</strong> 12.345.678-9</p>
  #{'    '}
      <h3>ENSINO MÉDIO</h3>
  #{'    '}
      <h4>1º ANO (2023)</h4>
      <table>
          <tr><th>Disciplina</th><th>Carga Horária</th><th>Nota Final</th><th>Situação</th></tr>
          <tr><td>Matemática</td><td>160h</td><td>7.5</td><td>Aprovado</td></tr>
          <tr><td>Língua Portuguesa</td><td>160h</td><td>8.2</td><td>Aprovado</td></tr>
          <tr><td>Física</td><td>120h</td><td>7.8</td><td>Aprovado</td></tr>
          <tr><td>Química</td><td>120h</td><td>7.0</td><td>Aprovado</td></tr>
          <tr><td>Biologia</td><td>120h</td><td>8.5</td><td>Aprovado</td></tr>
          <tr><td>História</td><td>120h</td><td>7.9</td><td>Aprovado</td></tr>
          <tr><td>Geografia</td><td>120h</td><td>8.1</td><td>Aprovado</td></tr>
          <tr><td>Inglês</td><td>80h</td><td>7.3</td><td>Aprovado</td></tr>
      </table>
  #{'    '}
      <h4>2º ANO (2024)</h4>
      <table>
          <tr><th>Disciplina</th><th>Carga Horária</th><th>Nota Final</th><th>Situação</th></tr>
          <tr><td>Matemática</td><td>160h</td><td>8.0</td><td>Aprovado</td></tr>
          <tr><td>Língua Portuguesa</td><td>160h</td><td>8.7</td><td>Aprovado</td></tr>
          <tr><td>Física</td><td>160h</td><td>8.2</td><td>Aprovado</td></tr>
          <tr><td>Química</td><td>160h</td><td>7.5</td><td>Aprovado</td></tr>
          <tr><td>Biologia</td><td>120h</td><td>8.8</td><td>Aprovado</td></tr>
          <tr><td>História</td><td>120h</td><td>8.3</td><td>Aprovado</td></tr>
          <tr><td>Geografia</td><td>120h</td><td>8.0</td><td>Aprovado</td></tr>
          <tr><td>Inglês</td><td>80h</td><td>7.8</td><td>Aprovado</td></tr>
      </table>
  #{'    '}
      <p><strong>Situação Final:</strong> APROVADO PARA O 3º ANO</p>
  </div>

  <div class="signature">
      <p>_______________________________</p>
      <p>Roberto Silva Diretor</p>
      <p>Direção Geral</p>
  </div>

  <div class="date">
      São Paulo, #{Date.today.strftime('%d de %B de %Y')}
  </div>
HTML

create_html_document(
  File.join(seed_files_dir, 'historico_completo.html'),
  'Histórico Escolar Completo',
  historico_html
)

# Criar certificado em HTML
certificado_html = <<~HTML
  <div style="text-align: center; border: 5px solid #2c5aa0; padding: 40px; margin: 20px;">
      <div style="font-size: 32px; font-weight: bold; color: #2c5aa0; margin-bottom: 20px;">
          CERTIFICADO
      </div>
  #{'    '}
      <div style="font-size: 24px; margin: 30px 0; color: #333;">
          COLÉGIO ESTADUAL DOM PEDRO II
      </div>
  #{'    '}
      <div style="font-size: 18px; margin: 40px 0; line-height: 1.8;">
          Certifica que o(a) aluno(a)
          <br><br>
          <strong style="font-size: 24px; color: #2c5aa0;">CARLA OLIVEIRA SANTOS</strong>
          <br><br>
          participou da <strong>FEIRA DE CIÊNCIAS 2025</strong>
          <br>
          realizada nos dias 15 e 16 de outubro de 2025,
          <br>
          com o projeto <strong>"Energia Solar nas Escolas"</strong>
          <br><br>
          obtendo <strong>MENÇÃO HONROSA</strong>
      </div>
  #{'    '}
      <div style="margin-top: 60px; display: flex; justify-content: space-between;">
          <div>
              <p>_______________________________</p>
              <p>Roberto Silva<br>Diretor</p>
          </div>
          <div>
              <p>_______________________________</p>
              <p>Prof. José Ricardo<br>Coordenador da Feira</p>
          </div>
      </div>
  #{'    '}
      <div style="margin-top: 40px; font-style: italic;">
          São Paulo, #{Date.today.strftime('%d de %B de %Y')}
      </div>
  </div>
HTML

create_html_document(
  File.join(seed_files_dir, 'certificado_feira.html'),
  'Certificado de Participação - Feira de Ciências',
  certificado_html
)

puts "✅ Documentos HTML criados!"

# Criar imagens SVG
puts "🎨 Criando imagens SVG..."

# Logo da escola
logo_svg = <<~SVG
  <circle cx="100" cy="60" r="40" fill="#2c5aa0" stroke="#1a365d" stroke-width="3"/>
  <text x="100" y="67" text-anchor="middle" fill="white" font-family="Arial" font-size="16" font-weight="bold">DP II</text>
  <text x="100" y="120" text-anchor="middle" fill="#2c5aa0" font-family="Arial" font-size="14" font-weight="bold">Dom Pedro II</text>
  <text x="100" y="140" text-anchor="middle" fill="#666" font-family="Arial" font-size="10">Colégio Estadual</text>
SVG

create_svg_image(
  File.join(seed_files_dir, 'logo_escola.svg'),
  200, 160, logo_svg
)

# Gráfico de notas
grafico_svg = <<~SVG
  <text x="150" y="25" text-anchor="middle" fill="#333" font-family="Arial" font-size="16" font-weight="bold">Desempenho por Disciplina</text>

  <!-- Barras do gráfico -->
  <rect x="30" y="50" width="25" height="85" fill="#4CAF50"/>
  <rect x="70" y="60" width="25" height="75" fill="#2196F3"/>
  <rect x="110" y="40" width="25" height="95" fill="#FF9800"/>
  <rect x="150" y="70" width="25" height="65" fill="#9C27B0"/>
  <rect x="190" y="55" width="25" height="80" fill="#F44336"/>
  <rect x="230" y="45" width="25" height="90" fill="#009688"/>

  <!-- Labels -->
  <text x="42" y="150" text-anchor="middle" fill="#333" font-family="Arial" font-size="8">Mat</text>
  <text x="82" y="150" text-anchor="middle" fill="#333" font-family="Arial" font-size="8">Port</text>
  <text x="122" y="150" text-anchor="middle" fill="#333" font-family="Arial" font-size="8">Fis</text>
  <text x="162" y="150" text-anchor="middle" fill="#333" font-family="Arial" font-size="8">Qui</text>
  <text x="202" y="150" text-anchor="middle" fill="#333" font-family="Arial" font-size="8">Bio</text>
  <text x="242" y="150" text-anchor="middle" fill="#333" font-family="Arial" font-size="8">Hist</text>

  <!-- Valores -->
  <text x="42" y="45" text-anchor="middle" fill="#333" font-family="Arial" font-size="10">8.5</text>
  <text x="82" y="55" text-anchor="middle" fill="#333" font-family="Arial" font-size="10">7.8</text>
  <text x="122" y="35" text-anchor="middle" fill="#333" font-family="Arial" font-size="10">9.2</text>
  <text x="162" y="65" text-anchor="middle" fill="#333" font-family="Arial" font-size="10">6.9</text>
  <text x="202" y="50" text-anchor="middle" fill="#333" font-family="Arial" font-size="10">8.1</text>
  <text x="242" y="40" text-anchor="middle" fill="#333" font-family="Arial" font-size="10">8.8</text>
SVG

create_svg_image(
  File.join(seed_files_dir, 'grafico_notas.svg'),
  300, 170, grafico_svg
)

# Foto de evento (representação abstrata)
evento_svg = <<~SVG
  <rect x="20" y="20" width="260" height="160" fill="#e3f2fd" stroke="#1976d2" stroke-width="2" rx="10"/>
  <text x="150" y="45" text-anchor="middle" fill="#1976d2" font-family="Arial" font-size="16" font-weight="bold">FEIRA DE CIÊNCIAS 2025</text>

  <!-- Representação de pessoas -->
  <circle cx="80" cy="80" r="15" fill="#ffcc80"/>
  <rect x="70" y="95" width="20" height="30" fill="#2196f3"/>

  <circle cx="120" cy="85" r="15" fill="#ffcc80"/>
  <rect x="110" y="100" width="20" height="25" fill="#4caf50"/>

  <circle cx="180" cy="80" r="15" fill="#ffcc80"/>
  <rect x="170" y="95" width="20" height="30" fill="#ff9800"/>

  <circle cx="220" cy="85" r="15" fill="#ffcc80"/>
  <rect x="210" y="100" width="20" height="25" fill="#9c27b0"/>

  <!-- Projetos -->
  <rect x="60" y="130" width="40" height="20" fill="#f5f5f5" stroke="#666" stroke-width="1"/>
  <text x="80" y="143" text-anchor="middle" fill="#333" font-family="Arial" font-size="8">Projeto 1</text>

  <rect x="120" y="130" width="40" height="20" fill="#f5f5f5" stroke="#666" stroke-width="1"/>
  <text x="140" y="143" text-anchor="middle" fill="#333" font-family="Arial" font-size="8">Projeto 2</text>

  <rect x="180" y="130" width="40" height="20" fill="#f5f5f5" stroke="#666" stroke-width="1"/>
  <text x="200" y="143" text-anchor="middle" fill="#333" font-family="Arial" font-size="8">Projeto 3</text>

  <text x="150" y="170" text-anchor="middle" fill="#666" font-family="Arial" font-size="10">15-16 Outubro 2025</text>
SVG

create_svg_image(
  File.join(seed_files_dir, 'foto_feira_ciencias.svg'),
  300, 200, evento_svg
)

puts "✅ Imagens SVG criadas!"

# Criar um documento JSON com dados estruturados
json_data = {
  escola: {
    nome: "Colégio Estadual Dom Pedro II",
    cnpj: "12.345.678/0001-90",
    endereco: "Rua da Educação, 456 - Centro - São Paulo/SP",
    telefone: "(11) 3456-7890",
    email: "secretaria@dompedroii.edu.br"
  },
  estatisticas_3_bimestre: {
    total_alunos: 150,
    aprovados: 142,
    reprovados: 8,
    media_geral: 7.6,
    disciplinas_com_maior_dificuldade: [ "Física", "Química", "Matemática" ],
    disciplinas_com_melhor_desempenho: [ "Educação Física", "Artes", "Geografia" ],
    eventos_realizados: 3,
    participacao_pais_reunioes: "87%"
  },
  metas_4_bimestre: [
    "Melhorar desempenho em Física e Química",
    "Aumentar participação dos pais",
    "Implementar projeto de reforço escolar",
    "Organizar feira de profissões",
    "Preparar alunos para ENEM 2025"
  ]
}

File.write(
  File.join(seed_files_dir, 'relatorio_pedagogico.json'),
  JSON.pretty_generate(json_data)
)

puts "✅ Arquivo JSON criado!"

puts "\nArquivos elaborados criados em: #{seed_files_dir}"
puts "Total de novos arquivos: #{Dir.glob(File.join(seed_files_dir, '*')).count}"

Dir.glob(File.join(seed_files_dir, '*')).sort.each do |file|
  size_kb = (File.size(file) / 1024.0).round(1)
  puts "- #{File.basename(file)} (#{size_kb} KB)"
end
