#!/usr/bin/env ruby

# Script para criar arquivos de exemplo para o seed
require 'fileutils'

seed_files_dir = File.join(__dir__, 'seed_files')
FileUtils.mkdir_p(seed_files_dir)

# Criar um PDF simples usando texto
def create_simple_pdf(filename, title, content)
  pdf_content = <<~PDF
    %PDF-1.4
    1 0 obj
    <<
    /Type /Catalog
    /Pages 2 0 R
    >>
    endobj

    2 0 obj
    <<
    /Type /Pages
    /Kids [3 0 R]
    /Count 1
    >>
    endobj

    3 0 obj
    <<
    /Type /Page
    /Parent 2 0 R
    /MediaBox [0 0 612 792]
    /Resources <<
    /Font <<
    /F1 4 0 R
    >>
    >>
    /Contents 5 0 R
    >>
    endobj

    4 0 obj
    <<
    /Type /Font
    /Subtype /Type1
    /BaseFont /Helvetica
    >>
    endobj

    5 0 obj
    <<
    /Length #{content.bytesize + 100}
    >>
    stream
    BT
    /F1 12 Tf
    50 750 Td
    (#{title}) Tj
    0 -20 Td
    (#{content}) Tj
    ET
    endstream
    endobj

    xref
    0 6
    0000000000 65535 f#{' '}
    0000000009 00000 n#{' '}
    0000000074 00000 n#{' '}
    0000000120 00000 n#{' '}
    0000000274 00000 n#{' '}
    0000000351 00000 n#{' '}
    trailer
    <<
    /Size 6
    /Root 1 0 R
    >>
    startxref
    #{500 + content.bytesize}
    %%EOF
  PDF

  File.write(filename, pdf_content)
end

# Criar uma imagem simples usando formato PBM (texto)
def create_simple_image(filename, width = 100, height = 50)
  # Criar um padrão simples em formato PBM (Portable Bitmap)
  content = "P1\n#{width} #{height}\n"

  height.times do |y|
    width.times do |x|
      # Criar um padrão xadrez simples
      if (x / 10 + y / 10) % 2 == 0
        content += "1 "
      else
        content += "0 "
      end
    end
    content += "\n"
  end

  File.write(filename, content)
end

# Criar PDFs de exemplo
puts "Criando arquivos PDF de exemplo..."

create_simple_pdf(
  File.join(seed_files_dir, 'regulamento_escolar.pdf'),
  'REGULAMENTO ESCOLAR - Colegio Dom Pedro II',
  'Este documento contem as normas e regulamentos da instituicao de ensino. Todos os alunos devem seguir as regras estabelecidas para um ambiente harmonioso de aprendizagem.'
)

create_simple_pdf(
  File.join(seed_files_dir, 'boletim_exemplo.pdf'),
  'BOLETIM ESCOLAR - 3o Bimestre',
  'Matematica: 8.5 - Lingua Portuguesa: 7.8 - Fisica: 9.2 - Quimica: 6.9 - Biologia: 8.1 - Historia: 7.5 - Geografia: 8.8 - Ingles: 7.0'
)

create_simple_pdf(
  File.join(seed_files_dir, 'comunicado_reuniao.pdf'),
  'COMUNICADO - Reuniao de Pais',
  'Comunicamos que havera reuniao de pais e responsaveis no dia 25/10/2025 as 19h00 no auditorio da escola. Assunto: Resultados do 3o bimestre e planejamento do 4o bimestre.'
)

create_simple_pdf(
  File.join(seed_files_dir, 'historico_escolar.pdf'),
  'HISTORICO ESCOLAR',
  'Historico escolar completo do aluno contendo todas as notas e frequencia dos anos anteriores. Documento oficial para transferencias e matriculas.'
)

create_simple_pdf(
  File.join(seed_files_dir, 'declaracao_matricula.pdf'),
  'DECLARACAO DE MATRICULA',
  'Declaramos que o aluno encontra-se regularmente matriculado nesta instituicao de ensino no ano letivo de 2025, cursando o Ensino Medio.'
)

puts "✅ PDFs criados!"

# Criar imagens de exemplo
puts "Criando arquivos de imagem de exemplo..."

create_simple_image(File.join(seed_files_dir, 'logo_escola.pbm'), 80, 40)
create_simple_image(File.join(seed_files_dir, 'foto_evento.pbm'), 120, 80)
create_simple_image(File.join(seed_files_dir, 'certificado_template.pbm'), 150, 100)

puts "✅ Imagens criadas!"

# Criar alguns arquivos de texto como exemplo
puts "Criando arquivos de texto de exemplo..."

File.write(File.join(seed_files_dir, 'ata_reuniao.txt'), <<~TEXT)
ATA DA REUNIÃO PEDAGÓGICA
Data: 15/10/2025
Horário: 14h00 às 16h00
Local: Sala de Reuniões

PARTICIPANTES:
- Diretor: Roberto Silva
- Coordenadora: Mariana Santos#{'  '}
- Professores presentes: 12

PAUTA:
1. Análise dos resultados do 3º bimestre
2. Planejamento do 4º bimestre
3. Preparação para o ENEM
4. Eventos escolares

DECISÕES:
- Intensificar o acompanhamento dos alunos com baixo rendimento
- Organizar simulados mensais para o 3º ano
- Programar feira de profissões para novembro

Roberto Silva - Diretor
Mariana Santos - Coordenadora
TEXT

File.write(File.join(seed_files_dir, 'circular_001.txt'), <<~TEXT)
CIRCULAR Nº 001/2025

Assunto: Normas para o 4º Bimestre

Senhores Pais e Responsáveis,

Comunicamos as principais normas e datas importantes para o 4º bimestre:

1. PERÍODO: 01/11/2025 a 20/12/2025
2. PROVAS FINAIS: 16/12 a 18/12/2025#{'  '}
3. CONSELHO DE CLASSE: 19/12/2025
4. ENTREGA DE BOLETINS: 20/12/2025

Solicitamos o acompanhamento das atividades escolares e o cumprimento dos prazos estabelecidos.

Atenciosamente,
Direção
TEXT

puts "✅ Arquivos de texto criados!"

puts "\nArquivos criados em: #{seed_files_dir}"
puts "Total de arquivos: #{Dir.glob(File.join(seed_files_dir, '*')).count}"

Dir.glob(File.join(seed_files_dir, '*')).each do |file|
  puts "- #{File.basename(file)} (#{File.size(file)} bytes)"
end
