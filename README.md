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
* Fuso Horário: timezone --utc America/Sao_Paulo define o fuso horário para São Paulo, sincronizado com o UTC.

  # País e idioma
    lang pt_BR.UTF-8  # Define o idioma para português do Brasil com UTF-8
    keyboard br-abnt2  # Define o layout do teclado para ABNT2 (Brasil)
    timezone --utc America/Sao_Paulo  # Define o fuso horário para São Paulo
