#!/bin/sh

set -e

# 런타임 실행시 구성 값을 nginx로 전달
envsubst < /etc/nginx/default.conf.tpl > /etc/nginx/conf.d/default.conf
nginx -g 'daemon off;'