#!/usr/bin/env bash
set -e

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use

if [ ! -d "node_modules" ]; then
  npm ci
fi

cd tabbycat
python ./manage.py migrate --no-input
python ./manage.py compilejsi18n
cd ..

npm run cp-fonts
npm run cp-jquery
npm run cp-barcode
npm run cp-validate
npm run cp-i18n

cd tabbycat
python ./manage.py runserver 0.0.0.0:8000 &
DJANGO_PID=$!
cd ..

npm run serve-sass &
SASS_PID=$!

npm run serve-vue &
VITE_PID=$!

wait $DJANGO_PID $SASS_PID $VITE_PID
