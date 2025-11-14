# Padronização do Sistema de Mensagens

## Problema Identificado

O sistema possuía duas rotas diferentes para mensagens:
1. **Rota geral**: `resources :messages` - que apontava para `/messages`
2. **Rotas específicas por perfil**:
   - `/admin/messages` 
   - `/direction/messages`
   - `/teachers/messages`
   - `/students/messages`

Isso causava confusão na navegação, pois alguns links levavam para a view geral enquanto outros levavam para as views específicas do perfil.

## Solução Implementada

### 1. **Padronização dos Links de Navegação**

**Arquivos Modificados:**
- `app/views/shared/_sidebar.html.erb`
- `app/views/layouts/application.html.erb` 
- `app/views/shared/_navbar.html.erb`

**Mudanças:**
- Todos os links de mensagens agora redirecionam para as rotas específicas de cada perfil
- Adicionado contador de mensagens não lidas em todos os links
- Inclusão da seção de mensagens para admin na sidebar

### 2. **Controller Geral de Redirecionamento**

**Arquivo Modificado:**
- `app/controllers/messages_controller.rb`

**Mudança:**
O controller geral agora funciona apenas como redirecionador, enviando cada usuário para sua interface específica:

```ruby
def redirect_to_specific_controller
  redirect_url = case current_user.user_type
  when 'admin'
    admin_messages_path
  when 'direction'
    direction_messages_path
  when 'teacher'
    teachers_messages_path
  when 'student'
    students_messages_path
  else
    root_path
  end
  
  redirect_to redirect_url
end
```

### 3. **Mapeamento de Rotas por Perfil**

| Tipo de Usuário | Rota Específica | View Específica |
|-----------------|-----------------|-----------------|
| **Admin** | `/admin/messages` | `app/views/admin/messages/` |
| **Direção** | `/direction/messages` | `app/views/direction/messages/` |
| **Professor** | `/teachers/messages` | `app/views/teachers/messages/` |
| **Aluno** | `/students/messages` | `app/views/students/messages/` |

## Benefícios da Padronização

### ✅ **Consistência na Navegação**
- Todos os links levam para a interface específica do perfil
- Eliminação de confusão entre views diferentes
- Experiência uniforme para o usuário

### ✅ **Melhor Organização**
- Cada perfil tem suas próprias funcionalidades específicas
- Filtros adequados para cada tipo de usuário
- Permissões corretas aplicadas em cada controller

### ✅ **Manutenção Facilitada**
- Código mais organizado e específico
- Fácil identificação de funcionalidades por perfil
- Redução de código duplicado

### ✅ **Segurança Aprimorada**
- Cada controller aplica suas próprias validações
- Permissões específicas para cada tipo de usuário
- Melhor controle de acesso

## Funcionalidades Específicas por Perfil

### **Admin (Municipal)**
- Envio de comunicados para todas as escolas
- Broadcast para diretores, professores e alunos
- Gestão de mensagens municipais

### **Direção (Escola)**
- Comunicação com professores e alunos da escola
- Broadcast para turmas específicas
- Gestão de mensagens escolares

### **Professores**
- Mensagens para alunos de suas turmas
- Comunicação com direção
- Templates específicos para professores

### **Alunos**
- Mensagens para professores e direção
- Interface simplificada
- Filtros básicos

## Links de Navegação Atualizados

### **Sidebar**
- ✅ Admin: `admin_messages_path`
- ✅ Direção: `direction_messages_path` 
- ✅ Professor: `teachers_messages_path`
- ✅ Aluno: `students_messages_path`

### **Navbar Principal**
- ✅ Ícone de envelope no topo redireciona para rota específica
- ✅ Dropdown do usuário com link específico

### **Navbar Secundário**
- ✅ Dropdowns específicos por perfil
- ✅ Contadores de mensagens não lidas

## Resultado Final

Agora o sistema tem navegação 100% padronizada:
- **Um único ponto de entrada** por tipo de usuário
- **Interfaces específicas** com funcionalidades adequadas
- **Filtros personalizados** já implementados em cada view
- **Experiência consistente** em toda a aplicação

Não há mais links duplicados ou confusão entre diferentes interfaces de mensagens.