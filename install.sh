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
#Si activas el proxy define un dominio o subdominio, tambien asignale la cantidad de los workers, esto dependera de la
#capacidad de su servidor.
WITH_PROXY="True"
WORKERS="3"
IS_ENTERPRISE="True"
DOMAIN="indumed.pragmatic.com.pe"
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
echo -e "\n--- Instalando nodejs npm ---"
sudo apt-get install nodejs npm -y
echo -e "\n--- Instalando rtlcss ---"
sudo npm install -g rtlcss
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
echo -e "\n--- Instalando pip3 - pyOpenSSL ---"
sudo pip3 install pyOpenSSL
echo -e "\n--- Actualizando pip3 - reportlab ---"
sudo pip3 install reportlab --upgrade
echo -e "\n--- Actualizando pip3 - python3-testresources ---"
sudo apt-get install -y python3-testresources
#--------------------------------------------------
# Modificar odoo.conf
#--------------------------------------------------
sudo touch /etc/odoo/odoo.conf
if [ $IS_ENTERPRISE = "True" ]; then
  echo -e "\n--- Agregando ruta enterprise ---"
  sudo su root -c "printf '[options]\n' >> /etc/odoo/odoo.conf"
  sudo su root -c "printf 'addons_path=/usr/lib/python3/dist-packages/odoo/addons,/mnt/enterprise\n' >> /etc/odoo/odoo.conf"
  sudo su root -c "printf 'db_host=False\n' >> /etc/odoo/odoo.conf"
  sudo su root -c "printf 'db_port=False\n' >> /etc/odoo/odoo.conf"
  sudo su root -c "printf 'db_user=odoo\n' >> /etc/odoo/odoo.conf"
  sudo su root -c "printf 'db_password=False\n' >> /etc/odoo/odoo.conf"
fi
#--------------------------------------------------
# Instalar Odoo
#--------------------------------------------------
echo -e "\n--- Install Odoo ---"
wget -O - https://nightly.odoo.com/odoo.key | apt-key add -
echo "deb http://nightly.odoo.com/${OE_VERSION}/nightly/deb/ ./" >>/etc/apt/sources.list.d/odoo.list
apt-get update && apt-get install odoo -y
if [ $IS_ENTERPRISE = "True" ]; then
  sudo pip3 install psycopg2-binary pdfminer.six
  echo -e "\n--- Create symlink for node"
  sudo ln -s /usr/bin/nodejs /usr/bin/node
  sudo -c "mkdir /mnt/enterprise"
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
#--------------------------------------------------
# Instalar SSL para el dominio.
#--------------------------------------------------
if [ $WITH_PROXY = "True" ]; then
  echo -e "\n--- Instalando Nginx ---"
  sudo apt-get install nginx -y
  echo -e "\n--- Instalando Cerbot ---"
  sudo snap install core
  sudo snap refresh core
  sudo snap install --classic certbot
  sudo ln -s /snap/bin/certbot /usr/bin/certbot
  echo -e "\n--- Modificando odoo.conf para el funcionamiento con Nginx y Cerbot ---"
  sudo su root -c "printf 'proxy_mode=True\n' >> /etc/odoo/odoo.conf"
  sudo su root -c "printf 'workers=${WORKERS}\n' >> /etc/odoo/odoo.conf"
  sudo su root -c "printf 'xmlrpc_interface=127.0.0.1\n' >> /etc/odoo/odoo.conf"
  sudo su root -c "printf 'netrpc_interface=127.0.0.1\n' >> /etc/odoo/odoo.conf"
  echo -e "\n--- Configurando archivo nginx ---"
  rm /etc/nginx/sites-available/default
  rm /etc/nginx/sites-enabled/default
  rm /etc/nginx/sites-available/${DOMAIN}
  rm /etc/nginx/sites-enabled/${DOMAIN}
  sudo touch /etc/nginx/sites-available/${DOMAIN}
  NAMES=(${DOMAIN//./ })
  SPECIAL_CHARTER="$"
  NGINX_TEMPLATE=$(
    cat <<-END
upstream ${NAMES[0]} {
  server 127.0.0.1:8069;
}
upstream ${NAMES[0]}-im {
  server 127.0.0.1:8072;
}
server {
  server_name ${DOMAIN};
  access_log /var/log/nginx/${NAMES[0]}.access.log;
  error_log /var/log/nginx/${NAMES[0]}.error.log;
  client_max_body_size 1024M;
  proxy_read_timeout 720s;
  proxy_connect_timeout 720s;
  proxy_send_timeout 720s;
  proxy_set_header X-Forwarded-Host ${SPECIAL_CHARTER}host;
  proxy_set_header X-Forwarded-For ${SPECIAL_CHARTER}proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto ${SPECIAL_CHARTER}scheme;
  proxy_set_header X-Real-IP ${SPECIAL_CHARTER}remote_addr;
  location / {
    proxy_redirect off;
    proxy_pass http://${NAMES[0]};
  }
  location /longpolling {
    proxy_pass http://${NAMES[0]}-im;
  }
  location ~* /web/static/ {
    proxy_cache_valid 200 90m;
    proxy_buffering on;
    expires 864000;
    proxy_pass http://${NAMES[0]};
  }
  gzip_types text/css text/less text/plain text/xml application/xml application/json application/javascript;
  gzip on;
}
END
  )
  sudo su root -c "printf '${NGINX_TEMPLATE}' >> /etc/nginx/sites-available/${DOMAIN}"
  ln /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/${DOMAIN}
  echo -e "\n--- Verificando si la configuracion es correcta ---"
  nginx -t
  service nginx restart
  sudo certbot --nginx -d ${DOMAIN}
fi
echo -e "\n--- Instalacion correcta ---"
if [ $WITH_PROXY = "True" ]; then
  echo -e "\n--- Accede a su instancia de odoo ${OE_VERSION} a travez ${DOMAIN} ---"
else
  echo -e "\n--- Accede a su instancia de odoo ${OE_VERSION} a travez $(hostname  -I | cut -f1 -d' '):8069 ---"
fi
