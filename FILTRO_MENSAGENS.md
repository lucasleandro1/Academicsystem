# Sistema de Filtros para Seleção de Destinatários de Mensagens

## Funcionalidade Implementada

Foi implementado um sistema de filtros dinâmicos para facilitar a seleção de destinatários nas telas de criação de mensagens, permitindo que os usuários filtrem por tipo de usuário e turma para encontrar mais facilmente o destinatário desejado.

## Como Funciona

### Filtros Disponíveis

#### 1. **Filtro por Tipo de Usuário**
- **Direção**: Pode filtrar entre Professores e Alunos
- **Professores**: Pode filtrar entre Direção, Professores e Alunos  
- **Alunos**: Pode filtrar entre Direção e Professores

#### 2. **Filtro por Turma** (apenas para alunos)
- Disponível para Direção e Professores
- Permite selecionar uma turma específica para ver apenas os alunos daquela turma
- Só é habilitado quando "Alunos" está selecionado no filtro de tipo
- **Direção**: Vê todas as turmas da escola
- **Professores**: Vê apenas suas turmas

### Recursos Adicionais

- **Contador de Destinatários**: Mostra quantos destinatários estão disponíveis após aplicar os filtros
- **Botão Limpar Filtros**: Remove todos os filtros aplicados
- **Filtro Inteligente**: O filtro de turma é automaticamente desabilitado quando não é aplicável
- **Interface Responsiva**: Os filtros são organizados em cards colapsáveis e responsivos

## Arquivos Modificados

### Views Atualizadas

1. **`app/views/direction/messages/new.html.erb`** - Sistema completo de filtros
2. **`app/views/teachers/messages/new.html.erb`** - Sistema completo de filtros  
3. **`app/views/students/messages/new.html.erb`** - Filtro simplificado (apenas tipo)
4. **`app/views/messages/new.html.erb`** - Sistema completo de filtros

### Helpers Modificados

1. **`app/helpers/messages_helper.rb`** - Atualizado para incluir data attributes nas opções

## Tecnologias Utilizadas

- **Backend**: Ruby on Rails com helpers
- **Frontend**: JavaScript vanilla + Bootstrap 5
- **Dados**: Data attributes para identificação de tipos e turmas

## Funcionamento Técnico

### 1. **Data Attributes**
O helper `recipient_options_grouped` foi modificado para incluir data attributes em cada opção:
```ruby
options = users.map { |user| 
  [ 
    format_user_display_name(user), 
    user.id,
    { 
      'data-user-type' => user.user_type,
      'data-classroom-id' => user.classroom_id,
      'data-classroom-name' => user.classroom&.name
    }
  ] 
}
```

### 2. **Filtragem JavaScript**
- Armazena todas as opções originais ao carregar a página
- Aplica filtros dinamicamente baseado nos data attributes
- Reconstrói o select com apenas as opções que atendem aos critérios
- Preserva o prompt "Selecione o destinatário..."

### 3. **Interface Responsiva**
- Cards Bootstrap para organizar os filtros
- Grids responsivos que se adaptam a diferentes tamanhos de tela
- Controles desabilitados automaticamente quando não aplicáveis

## Como Usar

### Para Direção
1. Acesse a tela de nova mensagem
2. Use o filtro "Tipo de Usuário" para escolher entre Professores ou Alunos
3. Se selecionar "Alunos", use o filtro "Turma" para escolher uma turma específica
4. Selecione o destinatário da lista filtrada

### Para Professores  
1. Acesse a tela de nova mensagem
2. Use o filtro "Tipo de Usuário" para escolher entre Direção, Professores ou Alunos
3. Se selecionar "Alunos", use o filtro "Turma" para escolher uma de suas turmas
4. Selecione o destinatário da lista filtrada

### Para Alunos
1. Acesse a tela de nova mensagem  
2. Use o filtro "Tipo de Destinatário" para escolher entre Direção ou Professores
3. Selecione o destinatário da lista filtrada

## Benefícios

- **Melhor Usabilidade**: Facilita encontrar destinatários em escolas com muitos usuários
- **Navegação Intuitiva**: Filtros lógicos baseados na hierarquia escolar
- **Feedback Visual**: Contador mostra quantas opções estão disponíveis
- **Responsivo**: Funciona bem em desktop e mobile
- **Performático**: Filtragem acontece no client-side, sem requisições ao servidor

## Manutenção

O sistema é auto-contido e não requer manutenção especial. Os filtros se adaptam automaticamente conforme usuários e turmas são adicionados ao sistema.

## Compatibilidade

- Funciona com todos os tipos de usuários do sistema
- Compatível com as hierarquias existentes de permissões
- Mantém compatibilidade com funcionalidades existentes de mensagens