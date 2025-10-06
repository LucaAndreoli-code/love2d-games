# Pong

Un semplice clone del classico gioco Pong, implementato utilizzando il framework LÖVE (Love2D) e il linguaggio di programmazione Lua.

## Descrizione del progetto

Questo progetto ricrea il famoso gioco Pong, uno dei primi videogiochi arcade mai creati. Due giocatori controllano delle paddle ai lati opposti dello schermo e devono colpire una palla rimbalzante, cercando di non farla passare oltre la propria paddle.

## Requisiti

Per eseguire questo gioco è necessario avere installato LÖVE (Love2D) sul proprio computer:
- [Scarica Love2D](https://love2d.org/)

## Come avviare il gioco

Una volta installato Love2D, è possibile avviare il gioco in due modi:

1. Dalla directory principale del progetto:
    ```
    love .
    ```

2. Specificando il percorso del gioco:
    ```
    love /path/to/game
    ```

## Controlli

- **Giocatore 1**: W (su), S (giù)
- **Giocatore 2**: CPU

## Struttura del progetto

```
Pong/
├── main.lua      # Punto di ingresso del gioco
├── conf.lua      # Configurazione di LÖVE
└── README.md     # Questo file
```