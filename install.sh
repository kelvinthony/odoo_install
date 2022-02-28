#!/bin/bash
################################################################################
# Instalacion de Odoo v14 sobre Ubuntu 20.0 x64
# Author: Kelvin Thony Meza Espiritu
# Realizar archivo ejecutable:
# sudo chmod +x install.sh
# Ejecutar con el siguiente comando:
# ./install.sh
################################################################################

#VARIABLES DE ENTORNO.
OE_VERSION="14.0"
WITH_PROXY="False"
IS_ENTERPRISE="True"
DOMAIN=indumed.pragmatic.com.pe
WKHTMLTOX=https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb

#--------------------------------------------------
# Actualizar los repositorios en Ubuntu
#--------------------------------------------------
echo -e "\n--- Actualizando servidor ---"
#sudo apt-get update
echo -e "\n--- Instalando Postgresql ---"
#sudo apt install postgresql -y
#--------------------------------------------------
# Instar dependencias
#--------------------------------------------------
echo -e "\n--- Instalando nodejs npm ---"
sudo apt-get install nodejs npm -y
echo -e "\n--- Instalando rtlcss ---"
sudo npm install -g rtlcss
echo -e "\n--- Instalando wkhtmltopdf ---"
#wget $WKHTMLTOX
#sudo apt install ./wkhtmltox_0.12.6-1.focal_amd64.deb
sudo apt -f install -y
echo -e "\n--- Instalando pip3 ---"
sudo apt-get -y install python3-pip
echo -e "\n--- Instalando pip3 - xlwt ---"
sudo pip3 install xlwt
echo -e "\n--- Instalando pip3 - num2words ---"
sudo pip3 install xlwt
echo -e "\n--- Instalando pip3 - pyOpenSSL ---"
sudo pip3 install pyOpenSSL
echo -e "\n--- Actualizando pip3 - reportlab ---"
sudo pip3 install reportlab --upgrade
echo -e "\n--- Actualizando pip3 - python3-testresources ---"
sudo apt-get install -y python3-testresources
echo -e "\n--- Install Odoo ---"
#wget -O - https://nightly.odoo.com/odoo.key | apt-key add -
#echo "deb http://nightly.odoo.com/${OE_VERSION}/nightly/deb/ ./" >> /etc/apt/sources.list.d/odoo.list
apt-get update && apt-get install odoo -y
if [ $IS_ENTERPRISE = "True" ]; then
  sudo pip3 install psycopg2-binary pdfminer.six
  echo -e "\n--- Create symlink for node"
  sudo ln -s /usr/bin/nodejs /usr/bin/node
  sudo su $OE_USER -c "mkdir /mnt/enterprise"

  GITHUB_RESPONSE=$(sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/odoo/enterprise "/mnt/enterprise" 2>&1)
  while [[ $GITHUB_RESPONSE == *"Authentication"* ]]; do
    echo "------------------------Atencion------------------------------"
    echo "La autenticación con github ha fallado! por favor, intenta de nuevo."
    printf "Para clonar e instalar la versión empresarial de Odoo, \n Necesita ser un socio oficial de Odoo y necesita acceso a\nhttp://github.com/odoo/enterprise.\n"
    echo "TIP: Presiona ctrl+c para deterner el script."
    echo "-------------------------------------------------------------"
    echo " "
    GITHUB_RESPONSE=$(sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/odoo/enterprise "/mnt/enterprise" 2>&1)
  done

  echo -e "\n---- Added Enterprise code under mnt/enterprise ----"
  echo -e "\n---- Installing Enterprise specific libraries ----"
  sudo -H pip3 install ofxparse dbfread ebaysdk firebase_admin
  sudo npm install -g less
  sudo npm install -g less-plugin-clean-css
fi
if [ $IS_ENTERPRISE = "True" ]; then
  sudo su root -c "printf 'addons_path=/mnt/enterprise,/usr/lib/python3/dist-packages/odoo/addons\n' >> /etc/odoo/odoo.conf"
fi
