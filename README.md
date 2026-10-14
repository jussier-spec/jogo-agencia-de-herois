# Trabalho Flutter - Agentes (versao simples)

Projeto feito para o Trabalho de Implementacao de Desenvolvimento para Dispositivos Moveis.

## O que o projeto faz
- Catalogo de herois usando json-server.
- Paginacao com infinite_scroll_pagination.
- Cache dos dados no SQLite.
- Uso offline depois da primeira sincronizacao.
- Cache de imagens com cached_network_image.
- Detalhes do agente com primer_progress_bar.
- Contrato diario com shared_preferences.
- Esquadrao com limite de 15 agentes.
- Missao com 3 a 5 rounds e comparacao de atributos.
- Confirmacao e resultado com awesome_dialog.

## Como executar

### 1. Criar a parte nativa do Flutter
Na raiz do projeto:

    flutter create .
    flutter pub get

### 2. Preparar a API

    cd api
    npm install
    npm run prepare-data
    npm start

### 3. Rodar o Flutter
Em outro terminal, na raiz:

    flutter run

### 4. Android Emulator
O endereco usado e:

    http://10.0.2.2:3000

### 5. Celular fisico
Troque o `baseUrl` em `lib/servicos/api.dart` pelo IP do computador, por exemplo:

    http://192.168.1.10:3000

O celular e o computador precisam estar na mesma rede.
