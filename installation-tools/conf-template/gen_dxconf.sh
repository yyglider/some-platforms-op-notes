#!/bin/sh

dxname=$@
cp -R /var/www/html/DX3-conf /var/www/html/$dxname-conf
sed -i "s/DX3/$dxname/g" /var/www/html/$dxname-conf/*
