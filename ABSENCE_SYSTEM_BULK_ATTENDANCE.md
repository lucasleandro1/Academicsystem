# Nova Funcionalidade: Chamada em Lote para Registro de Faltas

## Implementação Realizada

Criei uma nova funcionalidade de **"Fazer Chamada"** que permite ao professor registrar presença/falta de todos os alunos de uma turma de uma só vez, tornando o processo muito mais eficiente e prático.

## Motivação

A funcionalidade anterior exigia que o professor registrasse cada falta individualmente, o que era trabalhoso quando precisava fazer a chamada de uma turma inteira. A nova funcionalidade permite:

- ✅ **Eficiência**: Fazer chamada de toda a turma de uma vez
- ✅ **Praticidade**: Interface visual simples com radio buttons
- ✅ **Flexibilidade**: Botões para marcar todos presentes/ausentes
- ✅ **Controle**: Atualização em tempo real dos contadores

## Funcionalidades Implementadas

### 1. **Controller - Novas Actions**

#### `attendance` (GET)
```ruby
def attendance
  @subjects = current_user.teacher_subjects.includes(:classroom)
  @subject = params[:subject_id] ? current_user.teacher_subjects.find(params[:subject_id]) : nil
  @classrooms = @subject&.available_classrooms || []
  @selected_classroom = params[:classroom_id] ? Classroom.find(params[:classroom_id]) : nil
  @students = @selected_classroom ? @subject&.students_from_classroom(@selected_classroom.id) || [] : []
  @date = params[:date] ? Date.parse(params[:date]) : Date.current
  
  # Buscar faltas já registradas para esta data, disciplina e turma
  if @subject && @selected_classroom && @date
    existing_absences = @subject.absences.where(
      date: @date,
      user_id: @students.pluck(:id)
    )
    @absent_student_ids = existing_absences.pluck(:user_id)
  else
    @absent_student_ids = []
  end
end
```

#### `bulk_create` (POST)
```ruby
def bulk_create
  @subject = current_user.teacher_subjects.find(params[:subject_id])
  @selected_classroom = Classroom.find(params[:classroom_id])
  @students = @subject.students_from_classroom(@selected_classroom.id)
  @date = Date.parse(params[:date])
  
  # Obter lista de alunos faltosos
  absent_student_ids = params[:absent_students] || []
  
  # Limpar faltas existentes para esta data/disciplina/turma
  existing_absences = @subject.absences.where(
    date: @date,
    user_id: @students.pluck(:id)
  )
  existing_absences.destroy_all
  
  # Criar novas faltas
  success_count = 0
  absent_student_ids.each do |student_id|
    if @students.pluck(:id).include?(student_id.to_i)
      absence = @subject.absences.build(
        user_id: student_id,
        date: @date,
        justified: false
      )
      if absence.save
        success_count += 1
      end
    end
  end
  
  redirect_to teachers_absences_attendance_path(
    subject_id: @subject.id,
    classroom_id: @selected_classroom.id,
    date: @date
  ), notice: "Chamada registrada! #{success_count} falta(s) registrada(s)."
end
```

### 2. **Rotas Adicionadas**

```ruby
resources :absences do
  collection do
    get :attendance
    post :bulk_create
  end
end
```

**Rotas criadas:**
- `GET /teachers/absences/attendance` - Página de chamada
- `POST /teachers/absences/bulk_create` - Processar chamada

### 3. **Interface da Chamada**

#### **Seção de Configuração:**
- **Disciplina**: Dropdown com disciplinas do professor
- **Turma**: Dropdown com turmas da disciplina selecionada  
- **Data**: Campo de data (padrão: hoje)
- **Botão**: "Carregar Turma"

#### **Lista de Chamada:**
- **Tabela organizada** com numeração sequencial
- **Informações do aluno**: Nome completo + email
- **Radio buttons**: Presente/Ausente para cada aluno
- **Botões de ação rápida**:
  - "Marcar Todos Presentes"
  - "Marcar Todos Ausentes"
- **Contadores em tempo real**: Presentes/Ausentes

#### **Funcionalidades JavaScript:**
```javascript
// Marcar todos como presentes
function markAllPresent() {
  const presentRadios = document.querySelectorAll('input[type="radio"][value="present"]');
  presentRadios.forEach(function(radio) {
    radio.checked = true;
    radio.dispatchEvent(new Event('change'));
  });
}

// Marcar todos como ausentes  
function markAllAbsent() {
  const absentRadios = document.querySelectorAll('input[type="radio"][value="absent"]');
  absentRadios.forEach(function(radio) {
    radio.checked = true;
    radio.dispatchEvent(new Event('change'));
  });
}

// Atualizar contadores em tempo real
function updateCounts() {
  const presentCount = document.querySelectorAll('input[type="radio"][value="present"]:checked').length;
  const absentCount = document.querySelectorAll('input[type="radio"][value="absent"]:checked').length;
  
  const presentBadge = document.getElementById('present-count');
  const absentBadge = document.getElementById('absent-count');
  
  if (presentBadge) presentBadge.textContent = presentCount;
  if (absentBadge) absentBadge.textContent = absentCount;
}
```

## Fluxo de Uso

### 📋 **Processo Completo:**

1. **Acessar**: Professor clica em "Fazer Chamada" na página de gerenciar faltas
2. **Configurar**: 
   - Seleciona disciplina
   - Escolhe turma
   - Define data da aula
   - Clica "Carregar Turma"
3. **Fazer Chamada**:
   - Lista de todos os alunos aparece
   - Marca Presente/Ausente para cada um
   - Pode usar botões de "Marcar Todos" para agilizar
4. **Confirmar**: Clica "Salvar Chamada"
5. **Resultado**: Sistema registra todas as faltas de uma vez

### 🔄 **Comportamentos Inteligentes:**

- **Sobrescrita**: Se já existem faltas para a data, substitui pelos novos dados
- **Validação**: Apenas alunos da turma podem ter faltas registradas
- **Feedback**: Contador mostra quantos presentes/ausentes em tempo real
- **Persistência**: Mantém seleções mesmo se recarregar página

## Exemplo de Uso Prático

### Cenário: Professor de Matemática na turma 1º Ano A

1. **Configuração**:
   - Disciplina: "Matemática"
   - Turma: "1º Ano A" (2 alunos)
   - Data: "08/10/2025"

2. **Lista de Chamada**:
   ```
   # | Aluno           | Presente | Ausente
   1 | Pedro Aluno     |    ●     |    ○
   2 | Carla Aluna     |    ○     |    ●
   ```

3. **Resultado**: 
   - 1 Presente, 1 Ausente
   - Salva 1 falta para Carla Aluna

## Vantagens da Implementação

### 🚀 **Eficiência:**
- **Registro em lote**: Toda turma de uma vez
- **Botões rápidos**: Marcar todos presente/ausente
- **Interface intuitiva**: Radio buttons claros

### 📊 **Controle:**
- **Contadores**: Feedback visual imediato
- **Validação**: Impede erros de dados
- **Histórico**: Preserva registros anteriores se não sobrescrever

### 🔧 **Flexibilidade:**
- **Datas anteriores**: Pode registrar faltas de aulas passadas
- **Correções**: Pode alterar chamadas já feitas
- **Compatibilidade**: Funciona junto com registro individual

### 💡 **Usabilidade:**
- **Fluxo progressivo**: Disciplina → Turma → Data → Chamada
- **Feedback visual**: Badges com contadores
- **Responsivo**: Funciona em diferentes tamanhos de tela

## Arquivos Criados/Modificados

### **Novos:**
- `app/views/teachers/absences/attendance.html.erb` - Interface da chamada

### **Modificados:**
- `app/controllers/teachers/absences_controller.rb` - Actions `attendance` e `bulk_create`
- `config/routes.rb` - Rotas para chamada em lote
- `app/views/teachers/absences/index.html.erb` - Link para "Fazer Chamada"

## Comandos de Teste

```bash
# Verificar rotas
rails routes | grep attendance
rails routes | grep bulk_create

# Testar no console
rails c
teacher = User.teachers.first
subject = teacher.teacher_subjects.first
students = subject.students
puts "#{students.count} alunos disponíveis para chamada"
```

## Próximas Melhorias Sugeridas

1. **Faltas Justificadas**: Checkbox para marcar faltas como justificadas
2. **Observações**: Campo para comentários sobre a aula
3. **Frequência**: Cálculo automático de % de presença
4. **Relatórios**: Export da chamada para PDF
5. **Notificações**: Avisar pais sobre faltas dos filhos

A nova funcionalidade torna o registro de faltas muito mais eficiente e prático, especialmente para turmas com muitos alunos!