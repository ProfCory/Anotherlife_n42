# aln-atm (ALN3)

ATM interactions (cash <-> bank) with an ATM card gate.

## v0 notes
- Card ownership is server-memory until aln-inventory exists.
- Uses aln-ui-focus for clean open/close behavior.

## Controls
- Stand near ATM point and press E.
- Close via ESC/Backspace or the Close button.

## Location data
Requires atm locations tagged with `atm` in aln-locations.
Use `/aln_atm_reload` after adding locations.
