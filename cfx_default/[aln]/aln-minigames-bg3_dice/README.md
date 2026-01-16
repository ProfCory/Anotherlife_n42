# aln-minigame-bg3dice

Optional client-only visual bridge for a paid BG3-style dice resource.

- Listens for `aln:minigame:result`
- Plays dice/anims using the external resource if present
- Never changes the result (server authoritative)

Setup:
1) Install the paid dice resource in `resources/[standalone]/<folder>`
2) Set `Config.BG3Dice.ResourceName` to the folder name
3) ensure `aln-minigame-bg3dice`
