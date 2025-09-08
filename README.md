# Sistema de Gestão Acadêmica

Um sistema completo de gerenciamento acadêmico desenvolvido em Ruby on Rails 8.0.2, projetado para atender às necessidades de escolas e instituições educacionais com funcionalidades avançadas para administradores, direção, professores e alunos.

## 📋 Índice

- [Características Principais](#características-principais)
- [Funcionalidades Implementadas](#funcionalidades-implementadas)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Estrutura do Sistema](#estrutura-do-sistema)
- [Funcionalidades por Módulo](#funcionalidades-por-módulo)
- [Instalação e Configuração](#instalação-e-configuração)
- [Uso do Sistema](#uso-do-sistema)
- [Estrutura do Banco de Dados](#estrutura-do-banco-de-dados)
- [Status do Projeto](#status-do-projeto)

## 🚀 Características Principais

- **Multi-perfil**: Sistema com 4 tipos de usuários (Admin, Direção, Professor, Aluno)
- **Interface Responsiva**: Desenvolvido com Bootstrap 5 para acesso via dispositivos móveis
- **Autenticação Segura**: Sistema de login implementado com Devise
- **Sistema de Mensagens**: Comunicação interna entre usuários
- **Gestão Completa**: Notas, faltas, horários, documentos, eventos e ocorrências
- **Dashboards Personalizados**: Interface específica para cada tipo de usuário
- **Relatórios Estatísticos**: Métricas e análises de desempenho

## ✅ Funcionalidades Implementadas

### 🔐 Sistema de Autenticação
- Login no sistema para 4 tipos de usuários
- Controle de acesso baseado em perfis
- Redirecionamento automático para dashboards específicos

### 👤 Módulo Administrador
- Gerenciar dados da escola (nome, endereço, contato)
- Cadastrar, editar e excluir usuários (todos os tipos)
- Visualizar relatórios gerais do sistema
- Dashboard com estatísticas globais

### 🏫 Módulo Direção
- Gerenciar dados da escola
- Cadastrar, editar e excluir professores
- Cadastrar, editar e excluir alunos
- Gerenciar turmas e salas de aula
- Aprovar matrículas de alunos
- Cadastrar e gerenciar disciplinas
- Programar eventos escolares
- Visualizar e gerenciar ocorrências
- Sistema de mensagens interno

### 👨‍🏫 Módulo Professor
- Visualizar suas disciplinas e turmas
- Lançar notas dos alunos (4 bimestres)
- Registrar faltas dos alunos
- Criar e gerenciar atividades/trabalhos
- Avaliar submissões de atividades
- Registrar ocorrências disciplinares
- Visualizar horários de aula
- Sistema de mensagens com alunos e direção

### 🧑‍🎓 Módulo Aluno
- Visualizar suas notas por disciplina
- Consultar frequência e faltas
- Ver horários de aula
- Acessar documentos disponibilizados
- Visualizar eventos da escola
- Consultar suas disciplinas e professores
- Ver ocorrências registradas
- Sistema de mensagens com professores e direção
- **Gestão Completa**: Desde cadastros básicos até relatórios detalhados
- **Sistema de Mensagens**: Comunicação interna entre usuários
- **Controle de Acesso**: Permissões específicas para cada tipo de usuário

## 🛠 Tecnologias Utilizadas

- **Ruby on Rails 8.0.2**: Framework principal
- **Ruby 3.3.8**: Linguagem de programação
- **SQLite3**: Banco de dados (desenvolvimento)
- **Devise**: Autenticação de usuários
- **Bootstrap 5.1.3**: Framework CSS
- **Bootstrap Icons**: Ícones
- **Stimulus**: JavaScript framework
- **Turbo**: SPA-like experience

## 🏗 Estrutura do Sistema

### Modelos Principais

- **User**: Usuários do sistema (Admin, Direção, Professor, Aluno)
- **School**: Escolas cadastradas
- **Classroom**: Turmas/salas de aula
- **Subject**: Disciplinas
- **Activity**: Atividades/tarefas
- **Grade**: Notas dos alunos
- **Absence**: Faltas dos alunos
- **Event**: Eventos escolares
- **Occurrence**: Ocorrências disciplinares
- **Message**: Sistema de mensagens
- **ClassSchedule**: Grade de horários

## 📚 Funcionalidades por Módulo

### 👑 MÓDULO ADMIN (Super Administrador)
- ✅ Cadastro e gestão de escolas
- ✅ Criação de usuários direção
- ✅ Dashboard administrativo
- ✅ Controle total do sistema

### 🏫 MÓDULO DIREÇÃO (Gestão Escolar)
- ✅ Dashboard com estatísticas da escola
- ✅ Cadastro, edição e exclusão de alunos
- ✅ Cadastro, edição e exclusão de professores
- ✅ Gerenciamento de turmas (nome, ano letivo, turno, nível)
- ✅ Gerenciamento de disciplinas por turma e professor
- ✅ Configuração de grade de horários
- ✅ Visualização de relatórios do sistema
- ✅ Acesso a documentos da escola
- ✅ Criação e edição de eventos escolares
- ✅ Acompanhamento de ocorrências disciplinares
- ✅ Aprovação/gestão de matrículas
- ✅ Envio de mensagens
- ✅ Consulta de dados e atividades

### 👨‍🏫 MÓDULO PROFESSOR
- ✅ Dashboard personalizado
- ✅ Visualização de turmas e disciplinas atribuídas
- ✅ Visualização da grade de horários
- ✅ Registro de notas por bimestre e tipo
- ✅ Registro de faltas de alunos
- ✅ Cadastro de documentos associados a alunos
- ✅ Registro de ocorrências por aluno
- ✅ Criação de atividades para alunos
- ✅ Correção de atividades enviadas
- ✅ Envio de mensagens e avisos
- ✅ Geração de relatórios de desempenho

### 🧑‍🎓 MÓDULO ALUNO
- ✅ Dashboard personalizado
- ✅ Visualização de dados pessoais e matrícula
- ✅ Consulta de grade de horários
- ✅ Consulta de notas por bimestre e disciplina
- ✅ Verificação de frequência (faltas)
- ✅ Consulta de documentos (boletins, declarações)
- ✅ Visualização de eventos escolares
- ✅ Visualização de ocorrências registradas
- ✅ Recebimento de mensagens e avisos
- ✅ Visualização de atividades do professor
- ✅ Envio de respostas para atividades
- ✅ Visualização de feedback e notas das atividades

### 🔄 FUNCIONALIDADES GERAIS
- ✅ Acesso via navegador (interface responsiva)
- ✅ Sistema de autenticação seguro com Devise
- ✅ Painel personalizado por tipo de usuário
- ✅ Relacionamento com escolas
- ✅ Sistema de anexos (em desenvolvimento)
- ✅ Sistema de mensagens integrado
- ✅ Relatórios (em desenvolvimento)
- ✅ Sistema de notificações

## 🔧 Instalação e Configuração

### Pré-requisitos

- Ruby 3.3.8+
- Rails 8.0+
- SQLite3
- Node.js (para assets)

### Passos de Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/lucasleandro1/academic_system.git
cd academic_system
```

2. **Instale as dependências**
```bash
bundle install
```

3. **Configure o banco de dados**
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. **Inicie o servidor**
```bash
rails server
```

5. **Acesse o sistema**
- URL: http://localhost:3000
- Admin: admin@sistema.com / password123
- Direção: direcao@escola.com / password123
- Professor: professor1@escola.com / password123
- Aluno: aluno1@escola.com / password123

## 💻 Uso do Sistema

### Login e Navegação

1. Acesse http://localhost:3000
2. Faça login com uma das contas criadas no seed
3. O sistema redirecionará automaticamente para o dashboard específico do seu perfil

### Funcionalidades Principais

#### Como Admin
- Crie escolas no menu "Escolas"
- Cadastre usuários direção no menu "Usuários"

#### Como Direção
- Gerencie alunos e professores nos respectivos menus
- Crie turmas e disciplinas
- Aprove matrículas
- Monitore ocorrências e eventos

#### Como Professor
- Acesse suas disciplinas e turmas
- Registre notas e faltas
- Crie atividades para os alunos
- Corrija submissions dos alunos

#### Como Aluno
- Visualize suas notas e faltas
- Consulte atividades pendentes
- Envie respostas para atividades
- Receba mensagens dos professores

## 🗄 Estrutura do Banco de Dados

### Principais Tabelas

- **users**: Armazena todos os usuários do sistema
- **schools**: Dados das escolas
- **classrooms**: Turmas/salas de aula
- **subjects**: Disciplinas
- **activities**: Atividades criadas pelos professores
- **submissions**: Respostas dos alunos às atividades
- **grades**: Notas dos alunos
- **absences**: Faltas dos alunos
- **events**: Eventos escolares
- **occurrences**: Ocorrências disciplinares
- **messages**: Sistema de mensagens
- **class_schedules**: Grade de horários

### Relacionamentos Principais

- User pertence a School
- Classroom pertence a School
- Subject pertence a Classroom e Teacher
- Student pertence diretamente a Classroom (sem enrollment)
- Activity pertence a Subject e Teacher
- Grade conecta Student e Subject
- Message conecta Sender e Recipient (Users)

## 🎨 Interface e Design

### Características da Interface

- **Design Responsivo**: Funciona em desktop, tablet e mobile
- **Bootstrap 5**: Interface moderna e componentes prontos
- **Sidebar de Navegação**: Menu lateral contextual por tipo de usuário
- **Cards Informativos**: Dashboards com estatísticas visuais
- **Tabelas Organizadas**: Listagens claras e funcionais
- **Formulários Validados**: Entrada de dados consistente
- **Sistema de Alertas**: Feedback visual para ações do usuário

### Estrutura de Views

```
app/views/
├── layouts/
│   └── application.html.erb      # Layout principal
├── shared/
│   └── _sidebar.html.erb         # Menu lateral
├── admin/                        # Views do admin
├── direction/                    # Views da direção
├── teachers/                     # Views dos professores
└── students/                     # Views dos alunos
```

## 📊 Dashboards Específicos

### Dashboard do Admin
- Total de escolas cadastradas
- Estatísticas gerais do sistema
- Links rápidos para gestão

### Dashboard da Direção
- Total de alunos, professores e turmas
- Matrículas pendentes
- Ocorrências recentes
- Eventos próximos
- Estatísticas de desempenho

### Dashboard do Professor
- Disciplinas atribuídas
- Atividades recentes
- Submissions pendentes de correção
- Aulas do dia
- Mensagens não lidas

### Dashboard do Aluno
- Turmas matriculadas
- Atividades pendentes
- Notas recentes
- Total de faltas
- Mensagens não lidas
- Ocorrências registradas

## 🔐 Sistema de Permissões

### Controle de Acesso

- **Admin**: Acesso total ao sistema
- **Direção**: Acesso limitado à sua escola
- **Professor**: Acesso às suas disciplinas e alunos
- **Aluno**: Acesso aos seus dados pessoais

### Implementação

```ruby
# Example: Verificação de permissão no controller
before_action :authenticate_user!
before_action :ensure_direction!

def ensure_direction!
  unless current_user&.direction?
    redirect_to root_path, alert: "Acesso não autorizado."
  end
end
```

## 📱 Recursos Responsivos

### Adaptação Mobile

- Menu colapsível em dispositivos móveis
- Cards e tabelas responsivas
- Formulários otimizados para touch
- Navegação intuitiva

### Breakpoints Bootstrap

- **sm**: ≥576px (smartphones em landscape)
- **md**: ≥768px (tablets)
- **lg**: ≥992px (desktops pequenos)
- **xl**: ≥1200px (desktops grandes)

## 🧪 Dados de Teste

O sistema inclui um seeder completo com dados de exemplo:

```bash
rails db:seed
```

### Usuários Criados:

| Tipo | Email | Senha | Descrição |
|------|-------|-------|-----------|
| Admin | admin@sistema.com | password123 | Super administrador |
| Direção | direcao@escola.com | password123 | Diretora da escola |
| Professor | professor1@escola.com | password123 | Prof. de Matemática |
| Professor | professor2@escola.com | password123 | Prof. de Português |
| Aluno | aluno1@escola.com | password123 | Pedro Aluno |
| Aluno | aluno2@escola.com | password123 | Carla Aluna |

## 🚧 Desenvolvimentos Futuros

### Recursos Planejados

- [ ] Sistema de relatórios avançados
- [ ] Upload e gestão de arquivos
- [ ] Sistema de notificações em tempo real
- [ ] API REST para integração
- [ ] Sistema de backup automático
- [ ] Integração com sistemas de pagamento
- [ ] Mobile app nativo
- [ ] Dashboard analítico avançado
- [ ] Sistema de chat em tempo real
- [ ] Integração com Google Classroom

### Melhorias Técnicas

- [ ] Implementação de testes automatizados
- [ ] Configuração de CI/CD
- [ ] Docker containerization
- [ ] Performance optimization
- [ ] SEO optimization
- [ ] Accessibility improvements

## 🤝 Contribuição

### Como Contribuir

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

### Padrões de Código

- Siga as convenções do Ruby on Rails
- Use nomes descritivos para variáveis e métodos
- Mantenha os controllers enxutos
- Implemente validações nos models
- Escreva testes para novas funcionalidades

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 👥 Autor

- **Lucas Leandro** - Desenvolvedor Principal
- GitHub: [@lucasleandro1](https://github.com/lucasleandro1)

## 📞 Suporte

Para suporte e dúvidas:
- Abra uma issue no GitHub
- Entre em contato através do email: suporte@sistemacademico.com

---

**Sistema de Gestão Acadêmica** - Simplificando a gestão educacional com tecnologia moderna e interface intuitiva.
