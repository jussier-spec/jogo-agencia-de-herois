#!/bin/bash
set -e

echo '1 - Criando arquivos Android/iOS/etc. do Flutter...'
flutter create .

echo '2 - Instalando dependencias Flutter...'
flutter pub get

# Permite que o Android acesse o json-server local por HTTP.
python3 - <<'PY2'
from pathlib import Path
p = Path('android/app/src/main/AndroidManifest.xml')
s = p.read_text()
if 'android:usesCleartextTraffic' not in s:
    s = s.replace('<application', '<application android:usesCleartextTraffic="true"', 1)
    p.write_text(s)
print('HTTP local liberado no Android.')
PY2

echo '3 - Entrando na API...'
cd api
npm install
npm run prepare-data

echo ''
echo 'Tudo pronto.'
echo 'Para iniciar a API: cd api && npm start'
echo 'Depois, em outro terminal: flutter run'
