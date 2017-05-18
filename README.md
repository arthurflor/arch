## Arch Install
Baseado: https://github.com/helmuthdu/aui

### Pré-requisitos
- Permissão de root
- Conexão com Internet

### Como baixar (Arch)
- Mudando layout de teclado: loadkeys br-abnt2
- Conectando ao wi-fi (caso necessário): wifi-menu -o
- Baixando scripts: `wget https://github.com/arthurflor/arch/tarball/master -O - | tar xz`

### Como usar (Arch)
- FIFO [base do sistema]: `cd <dir> && ./fifo`
    #### Pós-requisitos
    - Copiar scripts baixados para a pasta /root: `cd.. && mv <dir> /mnt/root`

- Arch + KDE [instalação e configuração do sistema KDE]: `./archKDE`

### Como usar: pós-instalação (Manjaro)
- Manjaro KDE [instalação e configuração do sistema KDE]: `./manjaroKDE`
