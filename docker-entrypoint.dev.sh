#!/bin/bash
set -e

echo "🔧 Verificando dependências..."

# Instalar gems se necessário
if [ ! -d "/usr/local/bundle/gems" ] || [ -z "$(ls -A /usr/local/bundle/gems)" ]; then
  echo "📦 Instalando gems..."
  bundle install
else
  echo "✅ Gems já instaladas"
  # Verificar se há gems faltando
  bundle check || bundle install
fi

# Remove um PID de servidor pré-existente se existir
if [ -f tmp/pids/server.pid ]; then
  echo "🗑️  Removendo PID antigo..."
  rm -f tmp/pids/server.pid
fi

# Criar o banco de dados se não existir
echo "🗄️  Preparando banco de dados..."
bundle exec rails db:prepare

# Executar as migrations
echo "⬆️  Executando migrations..."
bundle exec rails db:migrate

echo "🚀 Iniciando servidor Rails..."
echo "📍 Acesse: http://localhost:3000"
echo ""

# Executar o comando passado como argumento
exec "$@"
