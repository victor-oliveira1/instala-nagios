#!/bin/bash
# Instalação automática do Nagios no Fedora
# victor.oliveira@gmx.com

clear
echo "Instalação automática - Nagios 4.3.2"
echo "A senha de root será solicitada para instalar alguns pacotes."
read -ep "Prosseguir com a instalação? (enter ou n): " teste

case $teste in
	[Nn])
	echo "Instalação cancelada. Saindo."
	exit
esac

clear
echo "Verificando conexão com a internet"
sleep 2

curl www.google.com &> /dev/null
if [ "$?" != "0" ]; then
	echo "Verifique sua conexão com a internet"
	echo "Saindo."
	exit
else
	echo "Conexão OK! Continuando..."
fi

sleep 2

echo "Baixando pacotes necessários para compilar o programa"
sudo dnf -y install autoconf automake gcc gcc-c++ gd-devel httpd php

echo "Criando usuário nagios"
sudo useradd -m nagios

echo "Configurando permissões do apache"
sudo usermod -aG nagios apache

echo "Criando pastas necessárias"
cd ~/
rm -rf nagios-install
mkdir nagios-install
cd nagios-install

echo "Baixando Nagios e plugins"
wget 'https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.3.2.tar.gz'

wget 'https://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz'

echo "Extraindo arquivos"
tar xvf nagios-4.3.2.tar.gz
tar xvf nagios-plugins-2.2.1.tar.gz

echo "Compilando"
cd nagios-4.3.2/
./configure
make all
sudo make install
sudo make install-init
sudo make install-commandmode
sudo make install-config
sudo make install-webconf
sudo make install-exfoliation

cd ../nagios-plugins-2.2.1/
./configure
make all
sudo make install

echo "Criando link simbólico"
cd ~/
ln -s /usr/local/nagios/

clear
echo "Digite a senha do usuário WEB nagiosadmin"
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

clear
echo "Digite a senha do usuário nagios"
sudo passwd nagios

echo "Configurando Selinux"
sudo setenforce 0
sudo sed -i s/SELINUX=enforcing/SELINUX=permissive/ /etc/selinux/config

echo "Instalando script de checagem de serviço"
cd ~/
echo '#!/bin/bash
#
# Checa/reinicia Nagios
#

sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

if [ "$?" = "0" ]; then
	echo
	read -ep "Configuração OK! Reiniciar serviços? (n ou s): " questao
		case "$questao" in
			[Nn])
			exit
			;;
			[Ss])
			sudo systemctl restart nagios
			;;
			*)
			echo "Opção inválida."
		esac
else
	echo "Verifique a configuração do Nagios."
fi' > nagios_check
sudo mv ~/nagios_check /usr/bin/
sudo chmod +x /usr/bin/nagios_check

echo "Configurando firewall"
sudo firewall-cmd --add-service=http
sudo firewall-cmd --add-service=http --permanent

echo "Configurando inicialização automática dos serviços"
sudo systemctl enable nagios httpd

echo "Iniciando serviços"
sudo systemctl start httpd nagios

clear
echo "Nagios 4.3.2 instalado!"
echo "Acesse o monitoramento através de um dos links:"
for ip in $(for name in $(ifconfig|grep UP|cut -d ':' -f1); do ifconfig $name|grep netmask|cut -d ' ' -f10; done); do
echo "http://$ip/nagios"
done
echo "Possíveis endereços IP:"
echo
echo "Usuário: nagiosadmin e a senha configurada anteriormente"
