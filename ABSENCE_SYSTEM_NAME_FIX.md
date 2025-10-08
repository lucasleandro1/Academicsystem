# Correção do Erro: undefined method `name' for User

## Problema

O sistema apresentava erro `NoMethodError (undefined method 'name' for an instance of User)` ao tentar acessar o formulário de registro de faltas.

### Causa Raiz

O modelo `User` não possui um método `name`, mas sim:
- `first_name` (campo da base de dados)
- `last_name` (campo da base de dados) 
- `full_name` (método calculado que combina os dois)

### Método `full_name` no Model User

```ruby
def full_name
  if first_name.present? || last_name.present?
    "#{first_name} #{last_name}".strip
  else
    email.split("@").first.humanize
  end
end
```

## Correções Realizadas

### 1. **app/views/teachers/absences/new.html.erb**

**Linha 47 - Select de alunos:**
```erb
# ANTES
options_from_collection_for_select(@students, :id, :name)

# DEPOIS  
options_from_collection_for_select(@students, :id, :full_name)
```

**Linha 127 - Lista de alunos na sidebar:**
```erb
# ANTES
<%= student.name %>

# DEPOIS
<%= student.full_name %>
```

### 2. **app/views/teachers/absences/index.html.erb**

**Linha 58 - Nome do aluno no resumo:**
```erb
# ANTES
<h6 class="mb-0"><%= student.name %></h6>

# DEPOIS
<h6 class="mb-0"><%= student.full_name %></h6>
```

**Linha 124 - Nome do aluno na tabela:**
```erb
# ANTES
<strong><%= absence.student.name %></strong>

# DEPOIS
<strong><%= absence.student.full_name %></strong>
```

### 3. **app/views/teachers/absences/edit.html.erb**

**Linha 52 - Select de alunos:**
```erb
# ANTES
options_from_collection_for_select(@students, :id, :name, @absence.user_id)

# DEPOIS
options_from_collection_for_select(@students, :id, :full_name, @absence.user_id)
```

**Linha 93 - Exibição do nome do aluno:**
```erb
# ANTES
<%= @absence.student.name %>

# DEPOIS
<%= @absence.student.full_name %>
```

### 4. **app/views/teachers/absences/show.html.erb**

**Linha 42 - Nome do aluno:**
```erb
# ANTES
<strong><%= @absence.student.name %></strong>

# DEPOIS
<strong><%= @absence.student.full_name %></strong>
```

## Resultado dos Testes

### ✅ Método `full_name` Funcionando:

```bash
# Teste realizado
User.students.limit(3).each do |s|
  puts "ID: #{s.id} - Email: #{s.email} - Nome: #{s.full_name}"
end

# Resultado
ID: 5 - Email: aluno1@escola.com - Nome: Pedro Aluno
ID: 6 - Email: aluno2@escola.com - Nome: Carla Aluna  
ID: 9 - Email: lukkassoliveira2215@gmail.com - Nome: Lucas Oliveira
```

### 🎯 **Comportamento do Método `full_name`:**

1. **Se tem `first_name` e/ou `last_name`**: Combina e retorna (ex: "Pedro Aluno")
2. **Se não tem nomes**: Usa o email como fallback (ex: "aluno1@escola.com" → "Aluno1")

## Arquivos Modificados

- `app/views/teachers/absences/new.html.erb`
- `app/views/teachers/absences/index.html.erb` 
- `app/views/teachers/absences/edit.html.erb`
- `app/views/teachers/absences/show.html.erb`

## Status

✅ **Erro corrigido**: Todas as views de absences agora usam `full_name` em vez de `name`  
✅ **Compatibilidade**: Método `full_name` funciona mesmo quando `first_name`/`last_name` estão vazios  
✅ **Consistência**: Todas as views do módulo de faltas padronizadas  

## Comando para Verificar

```bash
# Testar se o erro foi resolvido
rails c
teacher = User.teachers.first
subject = teacher.teacher_subjects.first
students = subject.students
students.each { |s| puts s.full_name }
```

O erro `undefined method 'name'` foi completamente resolvido em todas as views do sistema de faltas.