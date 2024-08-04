#!/bin/bash

#Criado por Luiz Henrique de Campos Monteiro | Sistema Alma Linux 9.4 com Openbox | 07/24

# Redireciona a saída padrão e a saída de erro padrão para um arquivo de log
exec > /var/log/post_install.log 2>&1

# Habilita o modo de depuração
set -x

#Cria as pastas necessárias para as configurações
mkdir -p /home/henrique/.config/openbox
mkdir /home/henrique/.config/tint2/
mkdir /home/henrique/.config/lxterminal
mkdir /home/henrique/.config/jgmenu
mkdir /home/henrique/.config/feh/
mkdir -p /usr/share/themes/Bear2/openbox-3/

#Copia e troca de diretório para extrair os arquivos de configuração
cp /root/confs.tar /tmp/
cd /tmp/
tar -xvf confs.tar -C /
rm confs.tar

#Redefine o tamanho dos discos lógicos
lvextend --resizefs --extents 8%VG /dev/vg00/lv_root
lvextend --resizefs --extents 12%VG /dev/vg00/lv_var
lvextend --resizefs --extents 8%VG /dev/vg00/lv_home
lvextend --resizefs --extents 40%VG /dev/vg00/lv_opt
lvextend --resizefs --extents 4%VG /dev/vg00/lv_tmp
lvextend --resizefs --extents 20%VG /dev/vg00/lv_arquivos

#Configuração do repositório EPEL
echo "[epel]
name=Extra Packages for Enterprise Linux 9 - \$basearch
baseurl=http://dl.fedoraproject.org/pub/epel/9/Everything/\$basearch
enabled=1
gpgcheck=1
gpgkey=https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-9" > /etc/yum.repos.d/epel.repo
# Importar chave do repositório EPEL
rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-9

# Instalação do repo raven
cd /tmp
rpm2cpio raven-release.el9.noarch.rpm | cpio -idmv
cp -r etc/. /etc/
rm -rf etc/
rm raven-release.el9.noarch.rpm

# Atualizar cache do DNF
dnf makecache
# Atualização do sistema
dnf update -y

#Instala programas que não estão no ks script
dnf install -y openbox
dnf install -y lightdm 
dnf install -y lxterminal 
dnf install -y obconf-qt 
dnf install -y tint2 
dnf install -y htop 
dnf install -y gnome-icon-theme 
dnf install -y thunar 
yum install -y gedit

# Garantir que rc.local esteja marcado como executável
chmod +x /etc/rc.d/rc.local

# Configurar LightDM para iniciar automaticamente
systemctl enable lightdm
systemctl set-default graphical.target

# Configura o login automático no LightDM para o usuário henrique
sed -i '/^\[Seat:\*\]/a \
autologin-user=henrique\n\
autologin-session=openbox' /etc/lightdm/lightdm.conf

# Reinicia o LightDM para aplicar as mudanças
systemctl restart lightdm

#Baixa e compila o jgmenu, que é o dropdown de janela
cd /home/henrique/.config/
git clone https://github.com/johanmalm/jgmenu.git
cd jgmenu
./configure
make
make install

cat <<EOF >> /usr/share/applications/jgmenu.desktop
[Desktop Entry]
Name=jgmenu
Exec=jgmenu_run
Icon=/usr/share/icons/gnome/256x256/devices/computer.png
Type=Application
Categories=Utility
EOF

#Instalação e compilação do Feh (programa para inserir a foto de background)
cd /tmp/
tar xvjf feh-3.10.3.tar.bz2
rm -rf feh-3.10.3.tar.bz2
cd feh-3.10.3
#Biblioteca antes de complicar o feh
dnf install -y imlib2-devel
make
make install
cd ../ && rm -rf feh-3.10.3

# Criar e configurar o script fehbg.sh
echo "feh --bg-fill /home/henrique/.config/feh/bg.jpg" > /home/henrique/.config/feh/fehbg.sh
chmod +x /home/henrique/.config/feh/fehbg.sh

# Criar e configurar o script autostart.sh
cat <<EOF > /home/henrique/.config/openbox/autostart.sh
tint2 &
/home/henrique/.config/feh/fehbg.sh &
EOF

#Copiar dos arquivos de configuração e atribuição de permissão nos diretórios
cp -r /tmp/.config /home/henrique/
chown -R henrique:henrique /home/henrique/.config

#Bash customizado do henrique
echo "PS1='\[\e[0;32m\]\u@\h:\[\e[0;36m\]\w\[\e[0m\]\$ '" >> /home/henrique/.bashrc
#Bash customizado do root
echo "PS1='\[\e[0;31m\]\u@\h:\[\e[0;36m\]\w\[\e[0m\]# '" |  tee -a /root/.bashrc > /dev/null

#Formatação e quantidade do history para troubleshooting		
cat <<EOF >> /home/henrique/.bashrc
# Definir o tamanho do histórico
HISTSIZE=1000
HISTFILESIZE=1000
# Registrar data e hora no histórico
export HISTTIMEFORMAT="%F %T "
EOF

#Permissão das configurações
chown -R henrique:henrique /home/henrique
chmod -R 775 /home/henrique

#splashtop
cd /tmp
dnf install -y Splashtop_Streamer_CentOS_x86_64.rpm 
rm Splashtop_Streamer_CentOS_x86_64.rpm

#anydesk
dnf install -y anydesk-6.3.2-1.el8.x86_64.rpm  
rm anydesk-6.3.2-1.el8.x86_64.rpm

# ----- < Configura o sshd_config > --------------------------------------------
sed -i '/^#Port 22/ s/^#Port 22/Port 2224/;
    /^#LoginGraceTime/ s/^#LoginGraceTime 2m/LoginGraceTime 30s/; 
    /^#PermitRootLogin/ s/^#PermitRootLogin prohibit-password/PermitRootLogin no/ 
    /^# Authentication\:/ iAllowUsers henrique' /etc/ssh/sshd_config
systemctl restart sshd

# Arquivo de configuração do tema
THEME_CONF="/usr/share/themes/Bear2/openbox-3/themerc"

#Fazendo as alterações usando sed
sed -i '
    s/padding.width: 3/padding.width: 8/;
    s/window.active.title.bg.color: #3465A4/window.active.title.bg.color: #303030/;
    s/window.active.title.bg.colorTo: #407CCA/window.active.title.bg.colorTo: #404040/;
    s/window.active.title.bg.border.color: #699acd/window.active.title.bg.border.color: #000000/;
    s/window.inactive.title.bg.color: #dcdcdc/window.inactive.title.bg.color: #303030/;
    s/window.inactive.title.bg.colorTo: #eeeeec/window.inactive.title.bg.colorTo: #404040/;
    s/window.inactive.title.bg.border.color: #efefef/window.inactive.title.bg.border.color: #000000/;
    s/window.handle.width: 4/window.handle.width: 0/
' "$THEME_CONF"

echo "henrique	ALL=(ALL)	ALL" >> /etc/sudoers

cat <<EOF >> /home/henrique/.bashrc
function show_exit_message() {
    # Exibe a mensagem instruindo o usuário a digitar 'exit'
    echo -e "\nCaso você tenha aberto por engano esta janela, digite \033[1;31mexit\033[0m para sair ou feche a janela manualmente.\n"
}

#Chama a função sempre que um novo terminal é aberto
show_exit_message
EOF

# Registrar execução do script para depuração
echo "Script de pós-instalação executado com sucesso em $(date)" >> /var/log/post_install.log

set +x
