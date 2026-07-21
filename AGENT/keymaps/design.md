# Keybinding design

Why the bindings are where they are. The evaluation model is `evaluation.md`
(key weights + bigram penalties, from the Colemak layout comparison); this file
applies it to *chords* instead of prose and records the resulting allocation.
`keybinds.md` is the flat snapshot of the outcome, the config files are the
authority.

## Constraints (fixed, not up for optimisation)

1. **`MOD+hjkl` is navigation, everywhere.** Neovim's default `hjkl` stays
   untouched so that a vim over SSH — where none of the personal mappings
   exist — feels the same. dwl and mpv follow the same axes.
2. **Angle-mod, ANSI**: the left bottom row is played one position to the left,
   so `x c d v` sit under pinky/ring/middle/index and only the rare `z` is left
   on the index-stretch key (QWERTY `B`).
3. **Tags stay on the number row**, 9 of them, `MOD+1…9` / `MOD+Shift+1…9`.
4. **Media stays on the F-row** (`MOD+F1/F2/F3/F5/F6`) — matches the laptop's
   printed legend and consumes no letter slot.
5. Frequent actions belong on the `MOD` layer; `MOD+Shift` is for the rare and
   the dangerous.

## Cost model

```
cost(chord) = weight(key) + penalty(modifiers)
```

**`weight(key)`** is the position weight from `weights.png`, read at the
*physical* position the Colemak-DH letter occupies:

| | pinky | ring | middle | index | index-stretch |
|---|---|---|---|---|---|
| **left top**    | `q` 3.6 | `w` 2.4 | `f` 1.8 | `p` 2.2 | `b` 3.5 |
| **left home**   | `a` 1.6 | `r` 1.2 | `s` 1.0 | `t` 1.0 | `g` 3.0 |
| **left bottom** | `x` 3.4 | `c` 2.6 | `d` 2.2 | `v` 1.8 | `z` 4.0 |
| **right top**   | `;` 3.6 | `y` 2.4 | `u` 1.8 | `l` 2.2 | `j` 3.5 |
| **right home**  | `o` 1.6 | `i` 1.2 | `e` 1.0 | `n` 1.0 | `m` 3.0 |
| **right bottom**| `/` 3.4 | `.` 2.6 | `,` 2.2 | `h` 1.8 | `k` 4.0 |

Plus two keys not in the letter grid: **`Space` 0.5** (thumb, zero travel — the
cheapest key on the board) and **`Return` 4.0** (right pinky, outward reach).

**`penalty(modifiers)`** extends the bigram idea to chords. `MOD` is **Alt**
(left thumb) and `Shift` is the **left pinky**, so both live on the left hand —
a right-hand key is therefore a clean hand alternation, a left-hand key is a
same-hand contortion:

| chord | penalty | rationale |
|---|---|---|
| `MOD` + right-hand key | 0.0 | thumb + other hand, full alternation |
| `MOD` + left-hand key | +1.0 (+1.5 pinky column) | same hand as the thumb |
| `MOD+Shift` + right-hand key | +1.5 | two modifiers, still alternating |
| `MOD+Shift` + left-hand key | +3.5 | three fingers on one hand |

For key *sequences* (Neovim's leader maps) there is no modifier penalty; the
bigram penalties from `evaluation.md` apply instead — same finger is expensive,
an inward roll is a bonus. `<leader>` is `Space` (thumb), so it never collides
with the key after it.

**Frequency classes** used for the weighted totals: ★★★ ≈ 50 uses/day, ★★ ≈ 20,
★ ≈ 5, quit ≈ 1.

## Two tie-break rules

- **Position beats mnemonic.** A mnemonic only decides between options of equal
  cost — with one bounded exception:
- **Mnemonic tolerance for rare actions.** For ★ actions a mnemonic may cost up
  to +2.0. At 5 uses/day that is ~10 cost units/day, far less than the price of
  a binding that has to be looked up. For ★★ and above, position wins outright.

## Collision rules

- No destructive action next to the navigation cluster. `killclient` sits on the
  right **pinky** (`o`), three columns from `hjkl` — a navigation slip cannot
  reach it.
- **A `MOD+Shift` binding whose base key is frequent is a trap**: a stray Shift
  then fires the wrong action. Screen lock therefore sits on `MOD+Shift+u`,
  whose base key `MOD+u` is deliberately left unbound. Where a stray Shift *is*
  harmless and instantly reversible (`incnmaster` under `setmfact`), sharing the
  key is fine and buys a better mnemonic.
- dwl owns `Alt`; foot, rofi and Neovim use `Ctrl`/`Ctrl+Shift` and the leader,
  so no cross-program chord collides.
- The one thing `Alt` grabs *through* to the terminal are readline's Meta
  bindings. The new map swallows `Alt+n` (non-incremental history search) on top
  of the `Alt+l` (downcase-word) that was already gone; the frequent ones —
  `Alt+b`, `Alt+f`, `Alt+d`, `Alt+.`, `Alt+Backspace` — are all still free.

## dwl — allocation

The five cheapest free chords go to the five most frequent non-navigation
actions. The right-hand home row is where the hand already rests for `hjkl`,
so window operations live there; launching lives on the thumb and the left hand.

| Chord | cost | action | freq | was | was cost |
|---|---|---|---|---|---|
| `MOD+Space` | 0.5 | terminal | ★★ | `MOD+Shift+Return` | 5.5 |
| `MOD+n` | 1.0 | zoom (swap into master) | ★★ | `MOD+Return` | 4.0 |
| `MOD+e` | 1.0 | fullscreen | ★★ | `MOD+m` | 3.0 |
| `MOD+i` | 1.2 | app launcher | ★★ | `MOD+Shift+p` | 5.7 |
| `MOD+o` | 1.6 | close window | ★★ | `MOD+Shift+c` | 6.1 |
| `MOD+h` / `MOD+l` | 1.8 / 2.2 | master area −/+ | ★★ | `MOD+Shift+h/l` | 3.3 / 3.7 |
| `MOD+j` / `MOD+k` | 3.5 / 4.0 | focus next/previous | ★★★ | unchanged | — |
| `MOD+v` | 2.8 | toggle floating | ★ | unchanged | — |
| `MOD+w` | 3.4 | browser (*w*eb) | ★ | `MOD+Shift+n` | 2.5 |
| `MOD+Shift+h` / `+l` | 3.3 / 3.7 | master count −/+ | ★ | `MOD+Shift+o/i` | 3.1 / 2.7 |
| `MOD+Shift+u` | 3.3 | lock screen | ★ | `MOD+l` | 2.2 |
| `MOD+Shift+q` | 7.1 | quit dwl (confirmed) | — | unchanged | — |

Three bindings got *more* expensive on purpose:

- **browser `MOD+w`** — mnemonic tolerance; `w` is free, memorable and the
  action is rare.
- **master count `MOD+Shift+h/l`** — same axis as `MOD+h/l`, "size" vs "count".
  Costs 1.2 units/day more than the old `i`/`o` and removes two arbitrary
  letters from the map.
- **lock `MOD+Shift+u`** — `MOD+l` was a 2.2 chord spent on a 5×/day action
  while blocking `l` for the navigation axis; and lock must not be reachable by
  a stray Shift.

Weighted total, navigation excluded (it is fixed by constraint 1):
**699.6 → 275.6, −61 %**. Including navigation: 1074.6 → 650.6, **−39 %**.

## Neovim — allocation

Defaults (`hjkl`, `gd`, `gr`, `K`, `[d`/`]d`, `<C-d>`/`<C-u>`/`<C-f>`/`<C-b>`,
`n`/`N`, `J`/`K` in visual) are untouched. Only the personal leader maps move,
and only where the model shows a real defect:

| Map | cost | action | was | was cost | why |
|---|---|---|---|---|---|
| `<leader>f` | 2.3 | find files | `<leader>sf` | 6.8 | `s`→`f` is the **same finger, one row up** (+3.5). The most-used picker had the worst bigram in the map. |
| `<leader>e` | 1.5 | Oil / file explorer | `<leader>pv` | 9.0 | `p`→`v` is the same finger across **two rows** (+4.5). |
| `<leader>d` | 2.7 | diagnostic float | `<leader>e` | 1.5 | displaced by Oil; `d` is mnemonic and cheap. |
| `<leader>r` | 1.7 | rename symbol | `<leader>rn` | 2.7 | one key shorter, same mnemonic. |
| `<leader>c` | 3.1 | code action | `<leader>ca` | 6.2 | `c`→`a` is ring→pinky, one row up (+1.5). |
| `<leader>p` | 2.7 | paste over selection (x) | `<leader>r` | 1.7 | frees `r` for rename; "paste" is the better mnemonic anyway. |
| `<leader>o` | 2.1 | open link in browser | `<leader>ob` | 5.6 | one key shorter, "open". |

`<leader>sg` (live grep) **stays a two-key sequence on purpose**: `s`→`g` is
middle→index on the home row, an inward roll worth **−1.5**, which makes the
three-key `<leader>sg` (3.0) cheaper than a hypothetical single `<leader>g`
(3.5). The rest of the rare `s`-family (`sh sc sq sl sk st sd`) is left alone —
all of them alternate hands or roll inward, and not relearning them is worth
more than the fractions on offer.

## mpv, rofi, foot

Consistency layer, low priority:

- **mpv** gets `h`/`l` = seek ∓5 s, `H`/`L` = seek ∓1 s, `j`/`k` = volume ∓5 —
  the same axes as dwl and vim. The arrow keys stay bound as before. The
  defaults this displaces move one modifier out of the way: `Ctrl+j`/`Ctrl+J`
  cycle the subtitle track, `Ctrl+l` sets the A-B loop, `Ctrl+L` toggles
  loop-file.
- **rofi** gets `Ctrl+j`/`Ctrl+k` as row down/up next to the existing
  `Ctrl+n`/`Ctrl+p`. This requires releasing `Ctrl+j` from `kb-accept-entry` and
  `Ctrl+k` from `kb-remove-to-eol`, which rofi would otherwise reject as a
  conflict.
- **foot** is left untouched: its bindings are `Ctrl+Shift+…`, they collide with
  nothing here, and copy/paste muscle memory is shared with every other terminal.
