# Alma Linux automatizado com Openbox
Instalação automatizada de um Alma Linux com Openbox para hardwares simples.

Este sistema possui três arquivos responsáveis pela sua instalação automatizada:

 1. Isolinux: Inicia a instalação a partir do boot EFI.
 2. Kickstart (ks script): Automatiza a configuração básica do sistema.
 3. Shell script: Executado com chroot para customizações adicionais.

Vamos começar explanando o Kickstart script e suas funcionalidades.

No topo do script, definimos o idioma, o layout do teclado e o servidor NTP para sincronização de data e hora.

Idioma: lang pt_BR.UTF-8 define o idioma para português do Brasil com codificação UTF-8.

Teclado: keyboard br-abnt2 configura o teclado para o padrão ABNT2 (Brasil).

Fuso Horário: timezone --utc America/Sao_Paulo define o fuso horário para São Paulo, sincronizado com o UTC.

# País e idioma
      lang pt_BR.UTF-8 
      keyboard br-abnt2  
      timezone --utc America/Sao_Paulo  
<h1>Configuração de Rede</h1>

Na seção de rede:

network --bootproto=dhcp --device=eth0 --noipv6 --activate: Configura a rede para usar DHCP, desativa IPv6 e ativa a interface eth0. A interface pode ser alterada conforme o hardware do cliente (por exemplo, eth, enp0s, em). Verifique a interface disponível no sistema, usando um Live CD ou a BIOS, para garantir que a configuração esteja correta.

network --hostname=Servidor: Define o nome do host como "Servidor".

firewall --service=ssh --port=2224:tcp: Configura o firewall para permitir conexões SSH na porta 2224.

    network --bootproto=dhcp --device=eth0 --noipv6 --activate 
    network --hostname=Servidor 
    firewall --service=ssh --port=2224:tcp

# Senhas

Definimos as senhas para root e o usuário henrique:

Um comando para gerar uma senha criptografada é fornecido como comentário:

    python3 -c 'import crypt; print(crypt.crypt(P4SSW0RD, crypt.mksalt(crypt.METHOD_SHA512)))'

Substitua "P4SSW0RD" pela senha desejada para gerar a senha criptografada em SHA-512.

A senha de root foi definida como P4SSW0RD.

authselect --enableshadow --passalgo=sha512: Habilita a criptografia de senhas em SHA-512.

selinux --disabled: Desativa o SELinux para evitar problemas durante a instalação.

user --name=henrique --shell=/bin/bash --uid=1000 --password=... --iscrypted: Cria o usuário henrique com shell bash, UID 1000 e senha criptografada.

    rootpw --iscrypted $6$2ArCAWSG8u.Sa30r$y3xNCQ2oApwFogpYGfcLJziLAIRvKVkhKM.eNxnE9BgZpjg948kAmyT8k4rRexriuKIJIBb/Sq11IPH5izg2l/
    authselect --enableshadow --passalgo=sha512
    selinux --disabled
    user --name=henrique --shell=/bin/bash --uid=1000 --password=$6$2ArCAWSG8u.Sa30r$y3xNCQ2oApwFogpYGfcLJziLAIRvKVkhKM.eNxnE9BgZpjg948kAmyT8k4rRexriuKIJIBb/Sq11IPH5izg2l/ --iscrypted

# Particionamento

O particionamento pode ser ajustado conforme a necessidade do disco primário. Se a máquina tiver mais de um disco ou um SSD NVMe, ajuste o valor de sda conforme o disco necessário. Recomenda-se realizar a formatação com apenas um disco inserido para evitar problemas na automação. Caso o disco seja NVMe, substitua sda pelo identificador correspondente.

ignoredisk --only-use=sda: Ignora todos os discos exceto sda.

clearpart --all --initlabel: Remove todas as partições existentes e cria uma nova tabela de partições.

zerombr: Zera o Master Boot Record (MBR) para eliminar dados antigos de inicialização.

part /boot/efi --fstype=vfat --label=EFI --size=500: Cria uma partição EFI de 500 MB com o sistema de arquivos vfat.

part /boot --fstype=ext4 --label=BOOT --size=1000 --fsoptions="nodev,nosuid,noexec": Cria uma partição /boot de 1000 MB com o sistema de arquivos ext4 e opções de segurança.

part pv.01 --ondrive=sda --grow --size=1 --asprimary: Cria uma partição física para LVM no disco sda, com tamanho ajustável.

# Grupo de Volumes e Volumes Lógicos

volgroup vg00 pv.01: Cria um grupo de volumes chamado vg00 usando a partição pv.01.

logvol swap --fstype=swap --vgname=vg00 --size=2048 --name=lv_swap: Cria um volume lógico de swap de 2048 MB.

logvol / --fstype=xfs --vgname=vg00 --size=4096 --name=lv_root --grow: Cria um volume lógico para a raiz (/) com tamanho inicial de 4096 MB, ajustável.

logvol /var --fstype=xfs --vgname=vg00 --size=4096 --grow --name=lv_var --fsoptions="nodev,nosuid": Cria um volume lógico para /var com sistema de arquivos xfs e opções de segurança.

logvol /opt --fstype=xfs --vgname=vg00 --size=4096 --grow --name=lv_opt --fsoptions="nodev,nosuid": Cria um volume lógico para /opt com sistema de arquivos xfs e opções de segurança.

logvol /home --fstype=xfs --vgname=vg00 --size=4096 --grow --name=lv_home --fsoptions="nodev,nosuid": Cria um volume lógico para /home com sistema de arquivos xfs e opções de segurança.

logvol /tmp --fstype=xfs --vgname=vg00 --size=4096 --grow --name=lv_tmp --fsoptions="nodev,nosuid": Cria um volume lógico para /tmp com sistema de arquivos xfs e opções de segurança.

logvol /opt/arquivos --fstype=xfs --vgname=vg00 --grow --size=4096 --name=lv_arquivos --fsoptions="nodev,nosuid": Cria um volume lógico para /opt/arquivos com sistema de arquivos xfs e opções de segurança.
    
    ignoredisk --only-use=sda # Ignora todos os discos exceto o sda
    
    clearpart --all --initlabel # Remove todas as partições existentes no disco e inicializa uma nova tabela de partições
    zerombr 
    
    part /boot/efi --fstype=vfat --label=EFI --size=500  
    part /boot --fstype=ext4 --label=BOOT --size=1000 --fsoptions="nodev,nosuid,noexec"  
    part pv.01 --ondrive=sda --grow --size=1 --asprimary 
    
    volgroup vg00 pv.01  
    
    logvol swap --fstype=swap --vgname=vg00 --size=2048 --name=lv_swap 
    logvol / --fstype=xfs --vgname=vg00 --size=4096 --name=lv_root --grow l
    logvol /var --fstype=xfs --vgname=vg00 --size=4096 --grow --name=lv_var --fsoptions="nodev,nosuid" --grow 
    logvol /opt --fstype=xfs --vgname=vg00 --size=4096 --grow --name=lv_opt --fsoptions="nodev,nosuid" 
    logvol /home --fstype=xfs --vgname=vg00 --size=4096 --grow --name=lv_home --fsoptions="nodev,nosuid"  
    logvol /tmp --fstype=xfs --vgname=vg00 --size=4096 --grow --name=lv_tmp --fsoptions="nodev,nosuid"  
    logvol /opt/arquivos --fstype=xfs --vgname=vg00 --grow --size=4096 --name=lv_arquivos --fsoptions="nodev,nosuid"  

# Repositórios

A instalação requer uma conexão com a internet para buscar pacotes e bibliotecas.

Configuramos os repositórios de onde o sistema buscará pacotes durante e após a instalação:  

    url --url="https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/kickstart/"
    url --url="https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/"
    repo --name="almalinux9-baseos" --baseurl="https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/" --mirrorlist=""
    repo --name="almalinux9-appstream" --baseurl="https://repo.almalinux.org/almalinux/9/AppStream/x86_64/os/" --mirrorlist=""
    repo --name="almalinux9-baseos-aarch64" --baseurl="https://repo.almalinux.org/almalinux/9/BaseOS/aarch64/os/" --mirrorlist=""

#Pacotes

Definimos os pacotes a serem instalados:

Pacotes principais:
        
        %packages
        @core
        xorg-x11-server-Xorg
        tar
        bzip2
        git
        vim
        firefox

Bibliotecas para jgmenu:
        
        cmake
        gcc
        gcc-c++
        make
        libxml2-devel
        gtk3-devel
        cairo-devel
        pango-devel
        gdk-pixbuf2-devel
        libX11-devel
        libXft-devel
        libXrender-devel
        libXrandr-devel
        librsvg2-devel
        libcurl-devel
        libXt-devel
        %end

#Pós-instalação

A última etapa inclui as configurações finais e a execução do shell script:

Fora do chroot:
Iniciamos um script de pós-instalação com bash para registrar o log da instalação do Kickstart:

    %post --interpreter=/bin/bash --nochroot --logfile=/mnt/sysimage/root/logs/ks-post-nochroot.log
    
Copiamos o script de pós-instalação (pos_install.sh) para o sistema instalado e tornamos-o executável. Também copiamos um arquivo .tar com configurações adicionais:

    cp /run/install/repo/custom/pos_install.sh /mnt/sysimage/root/ && chmod a+x /mnt/sysimage/root/pos_install.sh
    cp /run/install/repo/custom/confs.tar /mnt/sysimage/root

Encerramos a seção de pós-instalação fora do chroot.

Dentro do chroot:
Registramos os logs da pós-instalação no arquivo ks-post.log:

    %post --logfile /root/logs/ks-post.log
    
 Executamos o script de pós-instalação (pos_install.sh) para realizar a instalação de componentes que não podem ser configurados pelo Kickstart: 

    /root/pos_install.sh

#Executando o shell script de pós instalação

Primeiro, vamos habilitar o modo de depuração, onde cada instrução executada será registrada em um arquivo de log. Esse log poderá ser consultado após a instalação para verificar eventuais erros.

    # Redireciona a saída padrão e a saída de erro padrão para um arquivo de log
    exec > /var/log/post_install.log 2>&1

    # Habilita o modo de depuração
    set -x

Agora, criaremos os diretórios onde os arquivos de configuração da interface serão inseridos automaticamente.

    #Cria as pastas necessárias para as configurações
    mkdir -p /home/henrique/.config/openbox
    mkdir /home/henrique/.config/tint2/
    mkdir /home/henrique/.config/lxterminal
    mkdir /home/henrique/.config/jgmenu
    mkdir /home/henrique/.config/feh/
    mkdir -p /usr/share/themes/Bear2/openbox-3/

Vamos copiar o arquivo tar que foi trazido pelo kickstart e que atualmente está localizado em /root para o diretório /tmp.

Em seguida, extrairemos esse arquivo para o diretório /. Com isso, todas as pastas e arquivos contidos no tar serão colocados nos diretórios apropriados. O tar contém pastas como usr e tmp, que incluem vários arquivos de configuração em texto, direcionados para os diretórios criados anteriormente, além de outros que já existem e serão utilizados em configurações futuras. Após a extração, o arquivo tar será removido.

    #Copia e troca de diretório para extrair os arquivos de configuração
    cp /root/confs.tar /tmp/
    cd /tmp/
    tar -xvf confs.tar -C /
    rm confs.tar

Agora, vamos estender os volumes lógicos criados pelo script kickstart, ajustando o tamanho em porcentagem conforme a necessidade.

    #Redefine o tamanho dos discos lógicos
    lvextend --resizefs --extents 8%VG /dev/vg00/lv_root
    lvextend --resizefs --extents 12%VG /dev/vg00/lv_var
    lvextend --resizefs --extents 8%VG /dev/vg00/lv_home
    lvextend --resizefs --extents 40%VG /dev/vg00/lv_opt
    lvextend --resizefs --extents 4%VG /dev/vg00/lv_tmp
    lvextend --resizefs --extents 20%VG /dev/vg00/lv_arquivos

Aqui, configuraremos repositórios extras e não oficiais para que possamos baixar os pacotes necessários para compor a interface gráfica e outras funcionalidades.

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

Atualizaremos o cache dos repositórios e faremos a atualização do sistema.

    # Atualizar cache do DNF
    dnf makecache
    # Atualização do sistema
    dnf update -y

Agora, vamos detalhar alguns dos programas que serão instalados:

* Openbox é o nosso gerenciador de janelas, sendo o núcleo da interface gráfica que estamos utilizando.
* LightDM é responsável pela tela de login, se estiver habilitado por padrão. Também é utilizado para trocar para o graphical.target; sem ele, teríamos apenas o terminal aberto.
* LXTerminal é o nosso terminal personalizável.
* Obconf-qt permite customizar as bordas das janelas, ajustando-as conforme desejado.
* Tint2 é o painel que ficará na parte inferior da interface, onde fixaremos o jgmenu para ter um menu suspenso, além de mostrar a data, a hora e as aplicações em segundo plano.
* Htop é um programa para monitorar o consumo de recursos do sistema.
* Gnome-icon-theme são ícones do tema GNOME usados no dropdown.
* Thunar é o nosso explorador de arquivos, proporcionando uma interface para navegação entre diretórios.
* Gedit é o nosso editor de texto leve e simples. 

-

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

Deixaremos o arquivo rc.local executável para garantir o funcionamento adequado de alguns serviços.

    # Garantir que rc.local esteja marcado como executável
    chmod +x /etc/rc.d/rc.local

Agora, vamos configurar o LightDM.

Aqui, ativamos o LightDM e trocamos o alvo de inicialização para a interface gráfica. Também alteramos o arquivo lightdm.conf para desativar a tela de login para o usuário henrique, permitindo que o sistema inicie diretamente na interface do Openbox. Reiniciamos o serviço para aplicar as mudanças.

    # Configurar LightDM para iniciar automaticamente
    systemctl enable lightdm
    systemctl set-default graphical.target
    
    # Configura o login automático no LightDM para o usuário henrique
    sed -i '/^\[Seat:\*\]/a \
    autologin-user=henrique\n\
    autologin-session=openbox' /etc/lightdm/lightdm.conf
    
    # Reinicia o LightDM para aplicar as mudanças
    systemctl restart lightdm

Agora, vamos configurar o jgmenu, que é o nosso menu de dropdown.

Os arquivos de configuração do jgmenu serão colocados na pasta .config. Lá, faremos um clone do repositório do Git e executaremos alguns comandos para compilar o programa, pois ele não é nativo do AlmaLinux 9. Após a instalação com make install, criaremos um arquivo que servirá como inicializador e atalho para o jgmenu, identificado pelo ícone de computador na área de trabalho.

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

Instalaremos também o Feh, que é o programa responsável por definir a imagem de fundo do sistema. Ele segue a mesma lógica do jgmenu e precisa ser compilado.

Faremos a extração do tar, entraremos na pasta do Feh e instalaremos a biblioteca imlib2-devel. Depois, compilaremos o Feh.

Vamos criar um script do feh que vai evocar a imagem que esta contida no tar para ser o nosso plano de fundo. Tornamos o script executavel.

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

Após isso passaremos este script mais a execução do tint2 que é o nosso painel para o background que sera executado toda vez ao iniciar o sistema openbox partindo do script autostart.sh

    # Criar e configurar o script autostart.sh
    cat <<EOF > /home/henrique/.config/openbox/autostart.sh
    tint2 &
    /home/henrique/.config/feh/fehbg.sh &
    EOF 

Aqui, copiaremos todos os arquivos da pasta .config, que contêm as configurações de funcionalidades e visuais da nossa área de trabalho. São arquivos de configuração dos próprios programas e alguns xmls customizados que vão compor a nossa interface gráfica.

Também atribuiremos o usuário e grupo corretos para o diretório .config.

    #Copiar dos arquivos de configuração e atribuição de permissão nos diretórios
    cp -r /tmp/.config /home/henrique/
    chown -R henrique:henrique /home/henrique/.config
 
Modificaremos a cor do prompt do Bash tanto para o root quanto para o usuário, para torná-lo mais atraente e ilustrativo. A configuração do prompt pode ser feita de várias maneiras; aqui, é apenas uma preferência pessoal baseada no debian.

    #Bash customizado do henrique
    echo "PS1='\[\e[0;32m\]\u@\h:\[\e[0;36m\]\w\[\e[0m\]\$ '" >> /home/henrique/.bashrc
    #Bash customizado do root
    echo "PS1='\[\e[0;31m\]\u@\h:\[\e[0;36m\]\w\[\e[0m\]# '" |  tee -a /root/.bashrc > /dev/null 

Nesta etapa, configuramos o .bashrc com o formato e limite de tamanho do histórico de comandos para consulta de comandos antigos.

    #Formatação e quantidade do history para troubleshooting		
    cat <<EOF >> /home/henrique/.bashrc
    # Definir o tamanho do histórico
    HISTSIZE=1000
    HISTFILESIZE=1000
    # Registrar data e hora no histórico
    export HISTTIMEFORMAT="%F %T "
    EOF

Aplicamos as permissões para a home do usuário henrique e todos os arquivos copiados pelo chroot para o usuário henrique.

    #Permissão das configurações
    chown -R henrique:henrique /home/henrique
    chmod -R 775 /home/henrique

Faremos a instalação das duas ferramentas de acesso remoto que não estão incluídas nos repositórios.

Executaremos os dois pacotes RPM e instalaremos suas dependências usando o dnf.

    #splashtop
    cd /tmp
    dnf install -y Splashtop_Streamer_CentOS_x86_64.rpm 
    rm Splashtop_Streamer_CentOS_x86_64.rpm
    
    #anydesk
    dnf install -y anydesk-6.3.2-1.el8.x86_64.rpm  
    rm anydesk-6.3.2-1.el8.x86_64.rpm

Alteramos algumas configurações do serviço SSH, impedindo o login de root, definindo um tempo de graça de 30 segundos e permitindo apenas que o usuário henrique faça login via SSH.

    # ----- < Configura o sshd_config > --------------------------------------------
    sed -i '/^#Port 22/ s/^#Port 22/Port 2224/;
        /^#LoginGraceTime/ s/^#LoginGraceTime 2m/LoginGraceTime 30s/; 
        /^#PermitRootLogin/ s/^#PermitRootLogin prohibit-password/PermitRootLogin no/ 
        /^# Authentication\:/ iAllowUsers henrique' /etc/ssh/sshd_config
    systemctl restart sshd

Esta parte do script configura as bordas das janelas no obconf-qt. Usamos o sed para modificar algumas linhas e ajustar as configurações conforme determinado.

Criamos uma variável que aponta para o caminho completo do tema de janela e, em seguida, usamos o sed para substituir os campos apropriados dentro dessa variável.

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

Aqui deixo o usuário henrique ter todas as permissões de root apenas para facilitar os troubleshooting, alterar posteriormente a sua necessidade.

    echo "henrique	ALL=(ALL)	ALL" >> /etc/sudoers

Para um cliente final, também inserimos no .bashrc uma mensagem instrutiva para o usuário fechar o terminal caso o abra por engano.

É um heredoc simples que adiciona cor ao texto e exibe a mensagem sempre que o LXTerminal é aberto.

Nota: Se precisar usar o scp, comente as linhas dessa função, pois ela pode impedir a transferência de arquivos.

    cat <<EOF >> /home/henrique/.bashrc
    function show_exit_message() {
        # Exibe a mensagem instruindo o usuário a digitar 'exit'
        echo -e "\nCaso você tenha aberto por engano esta janela, digite \033[1;31mexit\033[0m para sair ou feche a janela manualmente.\n"
    }
    
    #Chama a função sempre que um novo terminal é aberto
    show_exit_message
    EOF

Por último, desativamos o modo de depuração e registramos uma mensagem de sucesso com a data e hora ao final do arquivo de log.

    # Registrar execução do script para depuração
    echo "Script de pós-instalação executado com sucesso em $(date)" >> /var/log/post_install.log
    
    set +x
    
