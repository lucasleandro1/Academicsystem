# Melhoria: Seleção de Turmas no Registro de Faltas

## Implementação Realizada

Implementei a funcionalidade de seleção de turmas no sistema de registro de faltas, criando um fluxo mais organizado: **Disciplina → Turma → Alunos**.

## Motivação

Como sugerido, uma disciplina pode ter várias turmas, e era necessário permitir que o professor escolhesse especificamente qual turma deseja registrar a falta, ao invés de mostrar todos os alunos de todas as turmas misturados.

## Modificações Implementadas

### 1. **Novos Métodos no Model Subject**

```ruby
def available_classrooms
  # Retorna todas as turmas disponíveis para esta disciplina
  classrooms = []
  
  # Adicionar turma direta se existir
  classrooms << classroom if classroom.present?
  
  # Adicionar turmas via horários
  classrooms_from_schedules = class_schedules.joins(:classroom).includes(:classroom).map(&:classroom).uniq
  classrooms.concat(classrooms_from_schedules)
  
  classrooms.uniq
end

def students_from_classroom(classroom_id)
  # Retorna alunos de uma turma específica
  User.student.where(classroom_id: classroom_id)
end
```

### 2. **Controller Atualizado**

**Action `new` modificada:**
```ruby
def new
  @absence = Absence.new
  @subjects = current_user.teacher_subjects.includes(:classroom)
  @subject = params[:subject_id] ? current_user.teacher_subjects.find(params[:subject_id]) : nil
  @classrooms = @subject&.available_classrooms || []
  @selected_classroom = params[:classroom_id] ? Classroom.find(params[:classroom_id]) : nil
  @students = @selected_classroom ? @subject&.students_from_classroom(@selected_classroom.id) || [] : []
  
  # Preservar dados do form se houver erro de validação
  if params[:absence]
    @absence.assign_attributes(absence_params)
  end
end
```

**Parâmetros permitidos atualizados:**
```ruby
def absence_params
  params.require(:absence).permit(:subject_id, :user_id, :date, :justified, :classroom_id)
end
```

### 3. **View Reformulada**

**Novo fluxo de seleção:**
```erb
<!-- 1. Seleção de Disciplina -->
<div class="col-md-6 mb-3">
  <%= form.label :subject_id, "Disciplina", class: "form-label" %>
  <%= form.select :subject_id, 
      options_from_collection_for_select(@subjects, :id, :name, @subject&.id),
      { prompt: "Selecione a disciplina" }, 
      { class: "form-select", required: true, id: "subject_select" } %>
</div>

<!-- 2. Seleção de Turma -->
<div class="col-md-12 mb-3">
  <%= form.label :classroom_id, "Turma", class: "form-label" %>
  <%= form.select :classroom_id, 
      @classrooms.any? ? options_from_collection_for_select(@classrooms, :id, :name, @selected_classroom&.id) : [],
      { prompt: @subject ? "Selecione a turma" : "Primeiro selecione uma disciplina" }, 
      { class: "form-select", required: true, id: "classroom_select", disabled: @classrooms.empty? } %>
</div>

<!-- 3. Seleção de Aluno -->
<div class="mb-3">
  <%= form.label :user_id, "Aluno", class: "form-label" %>
  <%= form.select :user_id, 
      @students.any? ? options_from_collection_for_select(@students, :id, :full_name) : [],
      { prompt: @selected_classroom ? "Selecione o aluno" : (@subject ? "Primeiro selecione uma turma" : "Primeiro selecione uma disciplina") }, 
      { class: "form-select", required: true, id: "student_select", disabled: @students.empty? } %>
</div>
```

### 4. **JavaScript Aprimorado**

```javascript
// Fluxo de seleção em cascata
subjectSelect.addEventListener('change', function() {
  // Recarrega página com disciplina selecionada, limpa turma
  const url = new URL(window.location);
  url.searchParams.set('subject_id', subjectId);
  url.searchParams.delete('classroom_id');
  window.location.href = url.toString();
});

classroomSelect.addEventListener('change', function() {
  // Recarrega página com turma selecionada
  const url = new URL(window.location);
  url.searchParams.set('subject_id', subjectId);
  url.searchParams.set('classroom_id', classroomId);
  window.location.href = url.toString();
});
```

## Fluxo de Uso

### 📋 **Novo Processo:**

1. **Selecionar Disciplina**: Professor escolhe a matéria
2. **Selecionar Turma**: Sistema mostra turmas disponíveis para a disciplina
3. **Definir Data**: Professor define quando foi a falta
4. **Selecionar Aluno**: Sistema mostra apenas alunos da turma selecionada
5. **Configurar**: Marcar se justificada (opcional)
6. **Registrar**: Confirmar o registro da falta

### 🔄 **Comportamento Dinâmico:**

- **Disciplina selecionada** → Carrega turmas disponíveis
- **Turma selecionada** → Carrega alunos específicos da turma
- **Validações** → Impede seleção sem os pré-requisitos

## Exemplo Prático

### Teste realizado:
```bash
Disciplina: matematica
Turmas disponíveis:
   1. 1ª ano A
Turma selecionada: 1ª ano A
Alunos disponíveis:
   - Lucas Oliveira (lukkassoliveira2215@gmail.com)
```

### Comparação por disciplina:
- **Matemática**: 1º Ano A (2 alunos)
- **Português**: 1º Ano A (2 alunos)  
- **matematica (ID:4)**: 1ª ano A (1 aluno)
- **Portugues (ID:5)**: 1ª ano A (1 aluno)

## Benefícios da Implementação

### 🎯 **Precisão:**
- Professor seleciona exatamente a turma desejada
- Elimina confusão entre alunos de turmas diferentes
- Dados mais organizados e específicos

### 📱 **Usabilidade:**
- Fluxo intuitivo e progressivo
- Feedback visual claro em cada etapa
- Instruções contextuais

### 🔧 **Flexibilidade:**
- Suporta disciplinas com múltiplas turmas
- Funciona com associações diretas e via horários
- Compatível com estruturas existentes

### ⚡ **Performance:**
- Carrega apenas alunos da turma selecionada
- Evita consultas desnecessárias
- Interface responsiva

## Arquivos Modificados

- `app/models/subject.rb` - Novos métodos `available_classrooms` e `students_from_classroom`
- `app/controllers/teachers/absences_controller.rb` - Actions `new` e `create` atualizadas
- `app/views/teachers/absences/new.html.erb` - Interface reformulada com seleção de turmas

## Comandos de Teste

```bash
# Testar disciplina com múltiplas turmas
rails c
subject = Subject.find(1)
puts subject.available_classrooms.map(&:name)

# Testar alunos por turma
classroom = subject.available_classrooms.first
puts subject.students_from_classroom(classroom.id).map(&:full_name)
```

A implementação agora oferece um controle muito mais granular e organizado para o registro de faltas, permitindo que professores trabalhem com turmas específicas de forma clara e eficiente.