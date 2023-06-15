#!/bin/sh

cd /app/book
mdbook serve --open&
nginx -g 'daemon off;'