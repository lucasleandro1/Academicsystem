# Correção: Nomes das Rotas da Funcionalidade de Chamada

## Problema Identificado

O erro `undefined local variable or method 'teachers_absences_attendance_path'` ocorreu porque usei nomes incorretos para os helpers de rota.

## Causa

Quando definimos rotas com `collection` dentro de um namespace, o Rails gera os helpers com a seguinte convenção:

```ruby
# Rota definida:
namespace :teachers do
  resources :absences do
    collection do
      get :attendance
      post :bulk_create
    end
  end
end

# Helpers gerados:
attendance_teachers_absences_path  # NÃO teachers_absences_attendance_path
bulk_create_teachers_absences_path # NÃO teachers_absences_bulk_create_path
```

## Correções Realizadas

### 1. **app/views/teachers/absences/index.html.erb**

```erb
# ANTES (ERRO)
<%= link_to teachers_absences_attendance_path, class: "btn btn-success" do %>

# DEPOIS (CORRETO)
<%= link_to attendance_teachers_absences_path, class: "btn btn-success" do %>
```

### 2. **app/views/teachers/absences/attendance.html.erb**

```erb
# ANTES (ERRO)
<%= form_tag teachers_absences_attendance_path, method: :get, local: true do %>
<%= form_tag teachers_absences_bulk_create_path, local: true do %>

# DEPOIS (CORRETO)  
<%= form_tag attendance_teachers_absences_path, method: :get, local: true do %>
<%= form_tag bulk_create_teachers_absences_path, local: true do %>
```

### 3. **app/controllers/teachers/absences_controller.rb**

```ruby
# ANTES (ERRO)
redirect_to teachers_absences_attendance_path(
  subject_id: @subject.id,
  classroom_id: @selected_classroom.id,
  date: @date
), notice: "Chamada registrada! #{success_count} falta(s) registrada(s)."

# DEPOIS (CORRETO)
redirect_to attendance_teachers_absences_path(
  subject_id: @subject.id,
  classroom_id: @selected_classroom.id,
  date: @date
), notice: "Chamada registrada! #{success_count} falta(s) registrada(s)."
```

## Rotas Corretas Geradas

```bash
# Verificação das rotas:
rails routes | grep attendance
rails routes | grep bulk_create

# Resultado:
attendance_teachers_absences   GET    /teachers/absences/attendance(.:format)    teachers/absences#attendance
bulk_create_teachers_absences  POST   /teachers/absences/bulk_create(.:format)   teachers/absences#bulk_create
```

## Helpers de Rota Corretos

```ruby
# URL paths gerados:
attendance_teachers_absences_path   # => "/teachers/absences/attendance"
bulk_create_teachers_absences_path  # => "/teachers/absences/bulk_create"

# Com parâmetros:
attendance_teachers_absences_path(subject_id: 1, classroom_id: 2, date: "2025-10-08")
# => "/teachers/absences/attendance?subject_id=1&classroom_id=2&date=2025-10-08"
```

## Teste Realizado

```bash
# Console do Rails:
puts Rails.application.routes.url_helpers.attendance_teachers_absences_path
# => "/teachers/absences/attendance"

puts Rails.application.routes.url_helpers.bulk_create_teachers_absences_path  
# => "/teachers/absences/bulk_create"
```

## Regra para Lembrar

**Convenção do Rails para helpers de collection routes:**

```ruby
# Estrutura da rota:
namespace :namespace_name do
  resources :resource_name do
    collection do
      verb :action_name
    end
  end
end

# Helper gerado:
action_name_namespace_name_resource_name_path
```

**Exemplo:**
- **Namespace**: `teachers`
- **Resource**: `absences`  
- **Action**: `attendance`
- **Helper**: `attendance_teachers_absences_path`

## Status

✅ **Erro corrigido**: Todos os helpers de rota atualizados  
✅ **Testes realizados**: Rotas funcionando corretamente  
✅ **Sintaxe OK**: Controller sem erros  

A funcionalidade de "Fazer Chamada" agora deve funcionar corretamente sem erros de rota.