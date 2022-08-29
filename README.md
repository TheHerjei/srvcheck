# Server Check

**Obbiettivo:**
Creare uno script che esegua una serie di controlli come:
- Controllo dello spazio disco residuo
- Controllo dell'utilizzo della CPU
- Controllo dell'utilizzo della RAM
- Controllo dell'esecuzione dei backups
- Controllo degli aggiornamenti

**Features:**
Multipiattaforma:
Lo script deve poter funzionare sui seguenti OS:
- Alpine Linux
- Debian
- Oracle Linux
- Windows (script dedicato 'wincheck')

## Stato attuale del progretto:

Con l'ultimo commit le feature disponibili sono le seguenti:
| Feature | Stato Programmazione |
| - | - |
|Controllo Orologio di sistema|OK|
|Controllo spazio disco| OK |
|Controllo spazio Volume Groups (LVM)| OK |
|Controllo utilizzo CPU e RAM| OK |
|Controllo aggiornamenti disponibili| OK |
|Controllo di sicurezza con lynis| OK |
|Sincronizzazione su server esterno (rsync o Telegram)| OK|
|Supporto Oracle Linux|Non implementato|
|Supporto fedora|Non implementato|
|Supporto Arch linux|Non implementato|
|Supporto Windows|Non implementato|