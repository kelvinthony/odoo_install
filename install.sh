#!/bin/bash
################################################################################
# Instalacion de Odoo v14 sobre Ubuntu 20.0 x64
# Author: Kelvin Thony Meza Espiritu
# Realizar archivo ejecutable:
# sudo chmod +x odoo-install.sh
# Ejecutar con el siguiente comando:
# ./odoo-install
################################################################################

#VARIABLES DE ENTORNO.

WKHTMLTOX=https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb

#--------------------------------------------------
# Actualizar los repositorios en Ubuntu
#--------------------------------------------------
echo -e "\n--- Actualizando servidor ---"
sudo apt-get update
echo -e "\n--- Instalando Postgresql ---"
sudo apt install postgresql -y
#--------------------------------------------------
# Instar dependencias
#--------------------------------------------------
echo -e "\n--- Instalando wkhtmltopdf ---"
wget $WKHTMLTOX
sudo apt install ./wkhtmltox_0.12.6-1.focal_amd64.deb
sudo apt -f install -y
echo -e "\n--- Instalando pip3 ---"
sudo apt-get -y install python3-pip
echo -e "\n--- Instalando pip3 - xlwt ---"
sudo pip3 install xlwt
echo -e "\n--- Instalando pip3 - num2words ---"
sudo pip3 install xlwt
echo -e "\n--- Instalando pip3 - pyopenssl ---"
sudo pip3 install pyopenssl
echo -e "\n--- Actualizando pip3 - reportlab ---"
sudo pip3 install reportlab --upgrade
echo -e "\n--- Install Odoo ---"
#wget -O - https://nightly.odoo.com/odoo.key | apt-key add -
#echo "deb http://nightly.odoo.com/14.0/nightly/deb/ ./" >> /etc/apt/sources.list.d/odoo.list
apt-get update && apt-get install odoo -y
