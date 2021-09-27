#!/bin/sh

npm run build
rm -rf assets/sass
rm assets/js/main.js assets/js/util.js
rm -rf node_modules tf
rm -rf LICENSE.MD README.MD package*.json .git*
