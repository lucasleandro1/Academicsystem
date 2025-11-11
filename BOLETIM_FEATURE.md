# Funcionalidade de Geração de Boletim Escolar

## Descrição
Esta funcionalidade permite que os alunos gerem e baixem seus boletins escolares em formato PDF diretamente pelo sistema acadêmico.

## Como Funciona

### Para os Alunos:

1. **Acesso às Notas**: Navegue para "Minhas Notas e Boletim" ou "Meus Documentos"

2. **Botão Gerar Boletim**: 
   - Estará disponível quando o aluno estiver matriculado em uma turma com disciplinas
   - Estará habilitado quando houver pelo menos uma nota lançada no sistema

3. **Download**: Clique no botão "Gerar Boletim Escolar" ou "Baixar Boletim PDF"
   - O arquivo será baixado automaticamente no formato PDF
   - Nome do arquivo: `boletim_[nome-do-aluno]_[data].pdf`

## Conteúdo do Boletim

O boletim gerado inclui:

### Cabeçalho
- Nome da escola
- Endereço da escola (se cadastrado)
- Ano letivo atual

### Dados do Aluno
- Nome completo
- Turma
- Data de emissão do boletim

### Tabela de Notas
- **Disciplinas**: Todas as disciplinas da turma do aluno
- **Notas por Bimestre**: 1º, 2º, 3º e 4º bimestre
- **Média da Disciplina**: Média das notas dos bimestres
- **Situação**: Aprovado/Reprovado/Em análise

### Informações Adicionais
- Média geral do aluno
- Legenda explicativa
- Data e hora de geração
- Espaço para assinatura da direção

## Validações Implementadas

1. **Aluno deve estar matriculado**: Verifica se o aluno está em uma turma
2. **Turma deve ter disciplinas**: Verifica se a turma possui horários/disciplinas cadastradas
3. **Deve haver notas**: Verifica se há pelo menos uma nota lançada

## Cálculos Realizados

### Média por Disciplina
- Soma das notas dos bimestres ÷ número de bimestres com nota

### Média por Bimestre
- Soma das notas de todas as disciplinas do bimestre ÷ número de disciplinas com nota

### Média Geral
- Soma das médias de todas as disciplinas ÷ número de disciplinas

## Critérios de Aprovação
- **Aprovado**: Média ≥ 6,0
- **Em Recuperação**: Média entre 5,0 e 5,9
- **Reprovado**: Média < 5,0
- **Em Análise**: Quando não há notas suficientes

## Localização no Sistema

### Botões Disponíveis:
1. **Página de Documentos** (`/students/documents`)
   - Botão: "Gerar Boletim Escolar"
   
2. **Página de Notas** (`/students/grades`)
   - Botão: "Baixar Boletim PDF"

### Rota da Funcionalidade:
```
GET /students/documents/generate_report_card
```

## Design do PDF

- **Layout**: A4, margens padronizadas
- **Cores**: Esquema de cores profissional (azul, cinza)
- **Fonte**: Helvetica
- **Elementos Visuais**: 
  - Cabeçalhos destacados
  - Tabelas organizadas
  - Caixas de destaque para informações importantes
  - Coloração diferenciada para status de aprovação

## Status dos Botões

### Habilitado (verde):
- Aluno matriculado em turma
- Turma com disciplinas cadastradas
- Pelo menos uma nota lançada

### Desabilitado (cinza):
- Aluno sem turma
- Turma sem disciplinas
- Nenhuma nota lançada

## Mensagens de Erro

- "Você precisa estar matriculado em uma turma para gerar o boletim."
- "Sua turma não possui disciplinas cadastradas. Entre em contato com a direção."
- "Você ainda não possui notas lançadas. O boletim será gerado assim que as notas estiverem disponíveis."

## Tecnologias Utilizadas
- **Ruby on Rails**: Backend e controle de rotas
- **Prawn**: Geração de PDF
- **Bootstrap**: Interface do usuário
- **Font Awesome**: Ícones

## Arquivos Modificados
1. `config/routes.rb` - Nova rota
2. `app/controllers/students/documents_controller.rb` - Nova ação
3. `app/views/students/documents/index.html.erb` - Botão
4. `app/views/students/grades/index.html.erb` - Botão
5. `Gemfile` - Gem Prawn adicionada

## Próximas Melhorias Sugeridas
1. Adicionar gráficos de desempenho
2. Incluir informações de frequência
3. Permitir personalização do layout pela escola
4. Histórico de boletins gerados
5. Integração com sistema de notificações