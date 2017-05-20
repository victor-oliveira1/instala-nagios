# instala-nagios
Script de instalação automática do Nagios + plugins para o Fedora (qualquer versão).

##Descrição:
**instala_nagios** é um bash script que instala os pacotes necessários para o programa nagios, compila, configura firewall e acessos automaticamente. Também é criado o script "nagios_check", que verifica as configurações e, caso esteja ok, reinicia o serviço. **Este script sempre irá compilar a versão mais atual do Nagios e seus plugins.**

##Utilização:
**1**- Primeiramente faça o download do script para o computador:
> *wget 'https://raw.githubusercontent.com/victor-oliveira1/instala-nagios/master/instala_nagios.sh'*

**2**- Dê permissões de execução:
> *chmod +x ./instala-nagios.sh*
