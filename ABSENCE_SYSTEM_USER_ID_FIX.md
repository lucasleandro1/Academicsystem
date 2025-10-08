# Correção: Referências Incorretas ao Campo 'user' em Consultas SQL

## Problema Identificado

O erro `SQLite3::SQLException: no such column: absences.user` ocorria porque várias consultas estavam usando `user:` ao invés de `user_id:` nas cláusulas `where`.

## Causa

Os modelos `Absence`, `Grade` e `Document` têm uma associação `belongs_to :student, class_name: "User", foreign_key: "user_id"`, mas o campo na tabela é `user_id`, não `user`.

Quando usamos `.where(user: objeto)`, o ActiveRecord tenta usar um campo chamado `user`, que não existe.

## Correções Realizadas

### 1. **app/views/teachers/absences/index.html.erb** (Linha 55)

```erb
# ANTES (ERRO)
<% student_absences = @absences.where(user: student).count %>

# DEPOIS (CORRETO)  
<% student_absences = @absences.where(user_id: student.id).count %>
```

### 2. **app/views/teachers/absences/edit.html.erb** (Linha 127)

```erb
# ANTES (ERRO)
<% student_absences = @absence.subject.absences.where(user: @absence.student).count %>

# DEPOIS (CORRETO)
<% student_absences = @absence.subject.absences.where(user_id: @absence.student.id).count %>
```

### 3. **app/views/teachers/absences/show.html.erb** (Linha 129)

```erb
# ANTES (ERRO)
<% student_absences = @absence.subject.absences.where(user: @absence.student).count %>

# DEPOIS (CORRETO)
<% student_absences = @absence.subject.absences.where(user_id: @absence.student.id).count %>
```

### 4. **app/controllers/direction/reports_controller.rb** (Linhas 239-240)

```ruby
# ANTES (ERRO)
student_grades = subject.grades.where(user: student)
student_absences = subject.absences.where(user: student).count

# DEPOIS (CORRETO)
student_grades = subject.grades.where(user_id: student.id)
student_absences = subject.absences.where(user_id: student.id).count
```

### 5. **app/views/students/subjects/show.html.erb** (Linhas 78, 93)

```erb
# ANTES (ERRO)
<% grade = @subject.grades.where(user: current_user, grade_type: grade_type).first %>
<% user_grades = @subject.grades.where(user: current_user) %>

# DEPOIS (CORRETO)
<% grade = @subject.grades.where(user_id: current_user.id, grade_type: grade_type).first %>
<% user_grades = @subject.grades.where(user_id: current_user.id) %>
```

### 6. **app/controllers/students/documents_controller.rb** (Linha 6)

```ruby
# ANTES (ERRO)
@documents = Document.where(user: current_user)

# DEPOIS (CORRETO)
@documents = Document.where(user_id: current_user.id)
```

### 7. **app/controllers/direction/students_controller.rb** (Linhas 27-28)

```ruby
# ANTES (ERRO)
@grades = Grade.where(user: @student).includes(:subject).order(created_at: :desc).limit(10)
@absences = Absence.where(user: @student).order(date: :desc).limit(10)

# DEPOIS (CORRETO)
@grades = Grade.where(user_id: @student.id).includes(:subject).order(created_at: :desc).limit(10)
@absences = Absence.where(user_id: @student.id).order(date: :desc).limit(10)
```

### 8. **app/views/direction/documents/index.html.erb** (Linha 147)

```erb
# ANTES (ERRO)
<%= @documents.where(user: current_user).count %>

# DEPOIS (CORRETO)
<%= @documents.where(user_id: current_user.id).count %>
```

## Estrutura dos Modelos

### Associações Corretas:
```ruby
# Absence model
belongs_to :student, class_name: "User", foreign_key: "user_id"

# Grade model  
belongs_to :user, class_name: "User", foreign_key: "user_id"

# Document model
belongs_to :user, class_name: "User", foreign_key: "user_id"
```

### Campos nas Tabelas:
- `absences.user_id` ✅
- `grades.user_id` ✅
- `documents.user_id` ✅

## Regra para Lembrar

**Ao fazer consultas com associações:**

### ❌ **Incorreto:**
```ruby
Model.where(user: user_object)        # Busca campo 'user' (não existe)
Model.where(student: student_object)  # Busca campo 'student' (não existe)
```

### ✅ **Correto:**
```ruby
Model.where(user_id: user_object.id)     # Busca campo 'user_id' (existe)
Model.where(student_id: student_object.id) # Busca campo 'student_id' (existe)
```

### ✅ **Alternativa (usando associações):**
```ruby
user_object.absences                    # Usa associação definida no model
student_object.grades                   # Usa associação definida no model
```

## Verificação Final

```bash
# Comando para verificar se ainda há referências incorretas:
grep -r "\.where(user:" app/
# Resultado: Nenhuma referência encontrada ✅
```

## Arquivos Corrigidos

**Views:**
- `app/views/teachers/absences/index.html.erb`
- `app/views/teachers/absences/edit.html.erb`
- `app/views/teachers/absences/show.html.erb`
- `app/views/students/subjects/show.html.erb`
- `app/views/direction/documents/index.html.erb`

**Controllers:**
- `app/controllers/direction/reports_controller.rb`
- `app/controllers/students/documents_controller.rb`
- `app/controllers/direction/students_controller.rb`

## Status

✅ **Erro corrigido**: Todas as consultas agora usam `user_id` corretamente  
✅ **Verificação completa**: Nenhuma referência incorreta restante  
✅ **Funcionalidade**: Sistema de faltas deve funcionar sem erros SQL  

O sistema agora deve funcionar corretamente sem erros de SQL relacionados ao campo 'user' inexistente.