# Lolo Remake

Recriação acadêmica de *Adventures of Lolo* (NES, 1989) desenvolvida em
Godot. O projeto preserva o modo 2D existente e inclui um protótipo 3D dos
mapas, personagens e objetos principais.

## Alunos

- André Bartzen
- José Augusto
- Jackson Matiazzi

## Requisitos

- Godot 4.7 ou compatível.

## Como executar

1. Abra `project.godot` no Godot.
2. Pressione F5.
3. No menu principal, escolha o modo 2D ou 3D.

## Controles

| Ação | Tecla |
|---|---|
| Mover | Setas do teclado |
| Confirmar | Enter ou Espaço |
| Disparar no 3D | Enter ou Espaço, se tiver tiros |
| Voltar ao menu no modo 3D | Esc |
| Alternar câmera do Lolo 3D | R |
| Morte de teste no 3D | Shift |

## Estrutura

```text
assets/          sprites, áudio, vídeos, fontes e modelos GLB finais
3d/              cenas, scripts e texturas do protótipo 3D
scenes/           cenas do jogo 2D
scripts/          lógica compartilhada e scripts do jogo 2D
```

## Parte 3D

As fases estão em `3d/scenes/levels/mapa_1_1.tscn` e `mapa_1_2.tscn`.
As duas usam `mapa_base.tscn`, que já tem o Lolo, a câmera, o mapa e o HUD.

O personagem fica em `3d/scenes/objects/lolo.tscn`; o movimento e os
controles ficam em `3d/scripts/lolo.gd`. Ele anda uma célula de 2 unidades
por vez, sem diagonal. Parede e água bloqueiam o passo; objetos com colisão
podem bloquear ou ser empurrados.

O Snakey da fase 1-1 fica parado e olha para o Lolo. O primeiro tiro o vira
em ovo por 7 segundos; nesse tempo ele pode ser empurrado. O segundo tiro
remove o ovo. A cena está em `3d/scenes/objects/snakey.tscn`.

Para passar o 3D a outra pessoa, envie o projeto Godot inteiro. As fases
também precisam de `assets/models/`, `3d/scenes/blocks/blocos.tres`,
`scenes/ui/` e dos scripts compartilhados em `scripts/`. Só os arquivos
das fases não abrem tudo corretamente.

Os arquivos `.glb`, `.import` e `.uid` usados pelo Godot fazem parte do
projeto. Arquivos de trabalho do Blender, caches, executáveis exportados e
cópias temporárias não devem ser versionados.

## Créditos

*Adventures of Lolo* e seus elementos originais pertencem aos respectivos
detentores de direitos, incluindo HAL Laboratory e Nintendo. Este remake é um
trabalho acadêmico, sem finalidade comercial.
