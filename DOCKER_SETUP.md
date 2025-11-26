# 🐳 Configuração Docker - Academic System

Este guia explica como executar o Academic System usando Docker.

## 📋 Pré-requisitos

- Docker instalado ([Instalar Docker](https://docs.docker.com/get-docker/))
- Docker Compose instalado ([Instalar Docker Compose](https://docs.docker.com/compose/install/))

## 🚀 Início Rápido

### 1. Build da imagem Docker

```bash
docker-compose build
```

### 2. Iniciar o sistema

```bash
docker-compose up
```

O sistema estará disponível em: http://localhost:3000

### 3. Parar o sistema

```bash
docker-compose down
```

## 🛠️ Comandos Úteis

### Executar comandos Rails no container

```bash
# Console Rails
docker-compose run --rm web rails console

# Executar migrations
docker-compose run --rm web rails db:migrate

# Criar seeds
docker-compose run --rm web rails db:seed

# Executar testes
docker-compose run --rm web rspec

# Bundle install (após adicionar gems)
docker-compose run --rm web bundle install
docker-compose up --build
```

### Acessar o terminal do container

```bash
docker-compose exec web bash
```

### Ver logs

```bash
# Todos os logs
docker-compose logs

# Logs em tempo real
docker-compose logs -f

# Logs de um serviço específico
docker-compose logs web
```

### Limpar volumes e reconstruir

```bash
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

## 🔧 Desenvolvimento

### Estrutura dos arquivos Docker

- **Dockerfile.dev** - Imagem Docker para desenvolvimento
- **docker-compose.yml** - Orquestração dos containers
- **docker-entrypoint.dev.sh** - Script de inicialização
- **.dockerignore** - Arquivos ignorados no build

### Volumes

O projeto usa volumes para:
- **Código fonte**: Montado em `/app` para hot-reload
- **Bundle cache**: Persiste as gems instaladas
- **Node modules**: Persiste os pacotes JavaScript

### Bancos de Dados

O SQLite está configurado para usar o diretório `storage/` que é persistido através do volume do código fonte.

## 🐛 Troubleshooting

### Porta 3000 já em uso

```bash
# Parar processo usando a porta
sudo lsof -ti:3000 | xargs kill -9

# Ou usar outra porta no docker-compose.yml
ports:
  - "3001:3000"
```

### Erro de permissões

```bash
# Ajustar permissões dos diretórios
sudo chown -R $USER:$USER .
```

### Rebuild completo

```bash
docker-compose down -v
docker system prune -a
docker-compose build --no-cache
docker-compose up
```

## 📦 Produção

Para produção, use o Dockerfile original:

```bash
# Build da imagem de produção
docker build -t academic_system .

# Executar container de produção
docker run -d \
  -p 80:80 \
  -v $(pwd)/storage:/rails/storage \
  -e RAILS_MASTER_KEY=$(cat config/master.key) \
  --name academic_system \
  academic_system
```

## 📚 Recursos Adicionais

- [Documentação Docker](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Rails com Docker](https://guides.rubyonrails.org/getting_started_with_devcontainer.html)
