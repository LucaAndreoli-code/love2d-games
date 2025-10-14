# Love2D Base Project

Questo repository contiene una struttura di base da cui partire per sviluppare progetti utilizzando il framework [LÖVE (Love2D)](https://love2d.org/).

## Struttura del Progetto

- `main.lua` - File principale dell'applicazione. Questo è il punto di partenza per il tuo gioco/applicazione Love2D.
- `conf.lua` - File di configurazione per l'applicazione Love2D. Qui puoi impostare titolo, dimensioni della finestra, e altre configurazioni del framework.
- `build.lua` - Configurazioni per il processo di build, utilizzando [love-build](https://github.com/ellraiser/love-build) per facilitare il packaging e la distribuzione del progetto.

## Come Iniziare

1. Clona questo repository
2. Modifica i file esistenti in base alle tue esigenze
3. Esegui il tuo progetto con Love2D:
    ```bash
    love .
    ```

4. Quando sei pronto per distribuire, utilizza le configurazioni in `build.lua` per creare un pacchetto.

## Risorse Utili

- [Documentazione ufficiale Love2D](https://love2d.org/wiki/Main_Page)
- [love-build](https://github.com/ellraiser/love-build)