# Alma Linux automatizado com Openbox
Instalação automatizada de um Alma Linux com Openbox para hardwares simples.

Este sistema possui três arquivos responsáveis pela sua instalação automatizada:

 1. Isolinux: Inicia a instalação a partir do boot EFI.
 2. Kickstart (ks script): Automatiza a configuração básica do sistema.
 3. Shell script: Executado com chroot para customizações adicionais.

Vamos começar explanando o Kickstart script e suas funcionalidades.

No topo do script, definimos o idioma, o layout do teclado e o servidor NTP para sincronização de data e hora.

* Idioma: lang pt_BR.UTF-8 define o idioma para português do Brasil com codificação UTF-8.

* Teclado: keyboard br-abnt2 configura o teclado para o padrão ABNT2 (Brasil).

*  Fuso Horário: timezone --utc America/Sao_Paulo define o fuso horário para São Paulo, sincronizado com o UTC.

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

#Particionamento

O particionamento pode ser ajustado conforme a necessidade do disco primário. Se a máquina tiver mais de um disco ou um SSD NVMe, ajuste o valor de sda conforme o disco necessário. Recomenda-se realizar a formatação com apenas um disco inserido para evitar problemas na automação. Caso o disco seja NVMe, substitua sda pelo identificador correspondente.

ignoredisk --only-use=sda: Ignora todos os discos exceto sda.

clearpart --all --initlabel: Remove todas as partições existentes e cria uma nova tabela de partições.

zerombr: Zera o Master Boot Record (MBR) para eliminar dados antigos de inicialização.

part /boot/efi --fstype=vfat --label=EFI --size=500: Cria uma partição EFI de 500 MB com o sistema de arquivos vfat.

part /boot --fstype=ext4 --label=BOOT --size=1000 --fsoptions="nodev,nosuid,noexec": Cria uma partição /boot de 1000 MB com o sistema de arquivos ext4 e opções de segurança.

part pv.01 --ondrive=sda --grow --size=1 --asprimary: Cria uma partição física para LVM no disco sda, com tamanho ajustável.

#Grupo de Volumes e Volumes Lógicos

    volgroup vg00 pv.01: Cria um grupo de volumes chamado vg00 usando a partição pv.01.
    logvol swap --fstype=swap --vgname=vg00 --size=2048 --name=lv_swap: Cria um volume lógico de swap de 2048 MB.
    logvol / --fstype=xfs --vgname=vg00 --size=4096 --name=lv_root --grow: Cria um volume lógico para a raiz (/) com tamanho inicial de 4096 MB, ajustável.
    logvol /var --fstype=xfs --vgname=vg00 --size=4096 --grow --name=lv_var --fsoptions="nodev,nosuid": Cria um volume lógico para /var com sistema de arquivos xfs e opções de segurança.
    logvol /opt --fstype=xfs --vgname=vg00 --size=4096 --grow --name=lv_opt --fsoptions="nodev,nosuid": Cria um volume lógico para /opt com sistema de arquivos xfs e opções de segurança.
    logvol /home --fstype=xfs --vgname=vg00 --size=4096 --grow --name=lv_home --fsoptions="nodev,nosuid": Cria um volume lógico para /home com sistema de arquivos xfs e opções de segurança.
    logvol /tmp --fstype=xfs --vgname=vg00 --size=4096 --grow --name=lv_tmp --fsoptions="nodev,nosuid": Cria um volume lógico para /tmp com sistema de arquivos xfs e opções de segurança.
    logvol /opt/arquivos --fstype=xfs --vgname=vg00 --grow --size=4096 --name=lv_arquivos --fsoptions="nodev,nosuid": Cria um volume lógico para /opt/arquivos com sistema de arquivos xfs e opções de segurança.

    
    
