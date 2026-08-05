# Neovim — A Practical Guide to *Your* Setup

A from-scratch guide to driving Neovim, tailored to the exact config installed on this
machine (everforest theme, lazy.nvim, Telescope, LSP for React/TS + Java/Spring Boot,
oxlint + oxfmt formatting). Read it top to bottom the first time; after that, use the
**Quick Reference** at the end as a cheat sheet.

> The screen captures below are **text snapshots of your real config** running. In your
> terminal these are fully coloured (everforest). Icons (, , 󰂺) come from your Nerd Font.

---

## Plugins installed

Everything here is managed by **lazy.nvim** (run `:Lazy` or `Space l` to see it).

| Plugin | Purpose | Used via |
|---|---|---|
| `folke/lazy.nvim` | Plugin manager (bootstraps everything else) | `:Lazy`, `Space l` |
| `neanias/everforest-nvim` | The everforest colour scheme | always on |
| `nvim-treesitter/nvim-treesitter` | Syntax highlighting, indentation, code-aware selection | automatic |
| `nvim-telescope/telescope.nvim` | Fuzzy finder for files / text / buffers | `Space f …` |
| `telescope-fzf-native.nvim` | Fast native sorter for Telescope | automatic |
| `nvim-lua/plenary.nvim` | Shared Lua library (Telescope/neo-tree depend on it) | automatic |
| `nvim-neo-tree/neo-tree.nvim` | File-tree sidebar | `Space f e`, `Space o` |
| `MunifTanjim/nui.nvim` | UI components (neo-tree depends on it) | automatic |
| `nvim-lualine/lualine.nvim` | The statusline at the bottom | always on |
| `nvim-tree/nvim-web-devicons` | File-type icons | automatic |
| `neovim/nvim-lspconfig` | Wires up the language servers (code intelligence) | `gd`, `K`, … |
| `williamboman/mason.nvim` | Installs language servers & tools | `:Mason` |
| `mason-lspconfig.nvim` | Bridges Mason ↔ lspconfig | automatic |
| `mason-tool-installer.nvim` | Auto-installs the formatters (oxfmt, prettier) | automatic |
| `saghen/blink.cmp` | Autocompletion engine (Rust-fast) | as you type |
| `rafamadriz/friendly-snippets` | Snippet collection for completion | automatic |
| `stevearc/conform.nvim` | Formatting (oxfmt / prettier, format-on-save) | `Space c f` |
| `lewis6991/gitsigns.nvim` | Git change markers & hunk actions | `Space h …`, `]h` |
| `folke/which-key.nvim` | Popup that shows available keybindings | press `Space` |
| `lukas-reineke/indent-blankline.nvim` | Indentation guide lines | always on |

**Installed *through* Mason** (not plugins, but the tools the LSP/formatting rely on):
`vtsls` (TS/JS/React) · `oxlint` (JS/TS lint) · `tailwindcss-language-server` ·
`html-lsp` · `css-lsp` · `jdtls` (Java) · `lua-language-server` · `oxfmt` (JS/TS format) ·
`prettier` (web format).

---

## 1. The one thing to know first: how to not get stuck

Neovim is **modal** — keys do different things depending on the mode you're in. If you
ever feel trapped, this sequence almost always rescues you:

| You want to… | Press |
|---|---|
| Get back to a safe state (Normal mode) | `Esc` |
| Quit the current window | `:q` then `Enter` |
| Quit **without saving** | `:q!` then `Enter` |
| Save | `:w` then `Enter` (or `Space w`) |
| Save **and** quit | `:wq` or `:x` then `Enter` |
| Quit everything, no saving | `:qa!` then `Enter` |

Commands starting with `:` are typed at the bottom of the screen and run with `Enter`.

---

## 2. Modes

| Mode | Enter it with | What it's for | Indicator (bottom-left) |
|---|---|---|---|
| **Normal** | `Esc` | Moving & running commands. The home base. | ` NORMAL ` |
| **Insert** | `i`, `a`, `o` … | Typing text, like a normal editor. | ` INSERT ` |
| **Visual** | `v`, `V`, `Ctrl-v` | Selecting text. | ` VISUAL ` |
| **Command** | `:` | Running `:commands`. | `:` prompt |

The golden rule: **you spend most of your time in Normal mode**, dipping into Insert only
to type. This feels backwards for a day, then becomes muscle memory.

Ways into Insert mode (each starts typing in a different spot):

| Key | Starts inserting… |
|---|---|
| `i` | before the cursor |
| `a` | after the cursor |
| `I` | at the first non-blank of the line |
| `A` | at the end of the line |
| `o` | on a new line below |
| `O` | on a new line above |

---

## 3. What your editor looks like

Opening a file (`nvim src/App.tsx`):

```
  1   export function App() {
    1 ▎ const greeting = "hello";
E   2 ▎ return <div className="app">{greeting}</div>;   ■■■ JSX element implicitly has type 'any'
    3 }
~
~
 NORMAL  󰅚 3  App.tsx                          utf-8 |  typescriptreact  Top   1:1
```

| Thing you see | What it is |
|---|---|
| `1` (bright) vs `1 2 3` | **Current line** shows its real number; others show *relative* distance — so `3k` jumps up 3 lines, `2j` down 2. |
| `▎` | The sign column (git changes & diagnostics live here). |
| `E` + `■■■ JSX element…` | A live diagnostic from the language server, shown inline. |
| `~` | Lines past the end of the file (empty). |
| ` NORMAL … App.tsx … typescriptreact … 1:1` | The **lualine** statusline: mode, file, filetype, and cursor `line:col`. |

---

## 4. Moving around (Normal mode)

You move *without arrow keys* (though arrows work). The hand stays on the home row.

| Key | Move |
|---|---|
| `h` `j` `k` `l` | left, down, up, right |
| `w` / `b` | forward / back one **word** |
| `e` | to end of word |
| `0` / `$` | start / end of line |
| `^` | first non-blank character of line |
| `gg` / `G` | top / bottom of file |
| `{` / `}` | previous / next paragraph (blank-line block) |
| `Ctrl-d` / `Ctrl-u` | half-page down / up (stays centred) |
| `%` | jump to matching bracket `()[]{}` |
| `*` | jump to next occurrence of the word under the cursor |
| `f<char>` / `t<char>` | jump **to** / **till** the next `<char>` on the line |
| `{number}G` | go to line number (e.g. `42G`) |

**Combine number + motion**: `5j` = down 5 lines, `3w` = forward 3 words.

---

## 5. Editing — the "verb + motion" grammar

This is the superpower. An **operator** (verb) + a **motion/text-object** (noun) = an edit.

| Operator | Means |
|---|---|
| `d` | delete (cut) |
| `c` | change (delete + enter Insert) |
| `y` | yank (copy) |
| `>` / `<` | indent / dedent |
| `gc` | toggle comment (built-in) |

| Text object | Means |
|---|---|
| `iw` / `aw` | inner word / a word (with surrounding space) |
| `i"` / `a"` | inside quotes / quotes + content |
| `i(` `i[` `i{` | inside the brackets |
| `ip` / `ap` | inner / a paragraph |
| `it` / `at` | inside / around an HTML/JSX tag |

**Read them as sentences:**

| Type | Result |
|---|---|
| `diw` | **d**elete **i**nner **w**ord |
| `ci"` | **c**hange **i**nside `"quotes"` |
| `ca(` | **c**hange **a**round `(...)` incl. the parens |
| `yi{` | **y**ank everything **i**nside `{ }` |
| `dat` | **d**elete **a** JSX/HTML **t**ag and its contents |
| `>ip` | indent the current paragraph |

Common standalone edits:

| Key | Does |
|---|---|
| `x` | delete character under cursor |
| `dd` / `yy` / `cc` | delete / yank / change the whole line |
| `p` / `P` | paste after / before cursor |
| `u` / `Ctrl-r` | undo / redo |
| `r<char>` | replace one character |
| `.` | **repeat the last change** (hugely useful) |
| `~` | toggle case of the character |

---

## 6. Visual mode (selecting)

| Key | Selects |
|---|---|
| `v` | character-wise — extend with motions (`vw`, `v$`) |
| `V` | whole lines |
| `Ctrl-v` | a rectangular **block** (great for columns) |

Once something is selected, apply an operator: `d` delete, `y` copy, `c` change, `>` indent.

Your config adds these in Visual mode:

| Key | Does |
|---|---|
| `J` / `K` | move the selected lines **down / up** |
| `<` / `>` | dedent / indent and **keep the selection** |

---

## 7. Search & replace

| Action | Keys |
|---|---|
| Search forward / backward | `/text` `Enter`  /  `?text` `Enter` |
| Next / previous match | `n` / `N` (cursor stays centred) |
| Clear the highlight | `Esc` (mapped for you) |
| Replace in whole file | `:%s/old/new/g` |
| Replace with confirmation | `:%s/old/new/gc` |
| Replace on current line only | `:s/old/new/g` |

Search is case-insensitive unless you type a capital (e.g. `/App` is case-sensitive).

---

## 8. The leader key & which-key

Your **leader** key is **`Space`**. Most custom shortcuts start with it: `Space f f`,
`Space c f`, etc. You don't need to memorise them — press `Space` and pause, and the
**which-key** popup lists everything, grouped:

```
 e ➜ 󱖫 Line diagnostics      w ➜   Save                 f ➜  +find/file
 l ➜   Lazy                  󱁐 ➜  Find files           s ➜   +split
 o ➜ 󰈔 Focus file explorer   b ➜ 󰈔 +buffer              t ➜ 󰓩 +tab
 q ➜  Quit window           c ➜  +code
```

Entries marked `+something` are **groups** — press that letter to drill in (e.g. `Space f`
shows all the find/file commands). This makes the whole config self-documenting.

---

## 9. Finding files & text — Telescope

Telescope is the fuzzy finder. Start typing and the list narrows live; `Enter` opens,
`Esc` cancels, `Ctrl-j` / `Ctrl-k` move down / up the results.

```
  ╭───────────────────────────── Find Files ─────────────────────────────╮
  │>                                                              4 / 4│
  ╰────────────────────────────────────────────────────────────────────╯
  ╭────────────────────────────── Results ───────────────────────────────╮
  │> 󰂺 README.md                                                         │
  │   package.json                                                      │
  │   src/App.tsx                                                       │
  │   src/util.ts                                                       │
  ╰────────────────────────────────────────────────────────────────────╯
```

| Shortcut | Finds |
|---|---|
| `Space f f` (or `Space Space`) | **files** by name |
| `Space f g` | **text** across the project (live grep — needs ripgrep ✓) |
| `Space f w` | the **word under the cursor**, across the project |
| `Space f b` | open **buffers** |
| `Space f r` | **recently** opened files |
| `Space f h` | Neovim **help** tags |
| `Space f d` | project **diagnostics** (all errors/warnings) |

---

## 10. The file tree — neo-tree

```
  /tmp/demo                  │  export function App() {
    src                     │    const greeting = "hello";
   │  App.tsx              │    return <div className="app">…
   └  util.ts              │  }
   󰂺 README.md              │
    package.json           │
 NORMAL  neo-tree filesystem
```

| Shortcut | Does |
|---|---|
| `Space f e` | toggle the tree open/closed |
| `Space o` | jump focus into the tree |

Inside the tree (when focused):

| Key | Does |
|---|---|
| `Enter` | open file / expand folder |
| `a` | add a new file (end with `/` to make a folder) |
| `d` / `r` | delete / rename |
| `c` / `x` / `p` | copy / cut / paste |
| `H` | toggle hidden (dotfiles) |
| `?` | show all tree keybindings |
| `q` | close the tree |

---

## 11. Windows (splits), buffers & tabs

**Mental model:** a **buffer** is an open file. A **window** is a viewport onto a buffer.
A **tab** is a whole layout of windows.

Splits:

| Shortcut | Does |
|---|---|
| `Space s v` / `Space s h` | split **v**ertical / **h**orizontal |
| `Ctrl-h/j/k/l` | move between splits |
| `Ctrl-←/→/↑/↓` | resize the current split |
| `Space s e` | equalise split sizes |
| `Space s c` | close the current split |

```
  export function App() {              │  export const add = (a, b) => a + b;
    const greeting = "hello";          │  export const mul = (a, b) => a * b;
    return <div …>{greeting}</div>;    │
  }                                    │
 NORMAL  App.tsx          │ util.ts
```

Buffers & tabs:

| Shortcut | Does |
|---|---|
| `Shift-h` / `Shift-l` | previous / next buffer |
| `Space b d` | close (delete) the current buffer |
| `Space t n` / `Space t c` | new / close tab |
| `Space t l` / `Space t h` | next / previous tab |

---

## 12. Code intelligence (LSP) — works in TS, React, Java, Lua

When you open a file, the matching language server attaches automatically
(check with `:LspInfo`). These work the same in every language:

| Shortcut | Does |
|---|---|
| `gd` | **go to definition** |
| `gD` | go to declaration |
| `gr` | find **references** |
| `gI` | go to implementation |
| `K` | **hover** docs / type info |
| `Space r n` | **rename** the symbol everywhere |
| `Space c a` | **code action** (quick-fixes, imports, refactors) |
| `Space e` | show the diagnostic on this line |
| `[d` / `]d` | jump to previous / next diagnostic |
| `Space f d` | list all diagnostics in Telescope |

After `gd`, jump **back** with `Ctrl-o` (and forward again with `Ctrl-i`).

**Completion** (blink.cmp) pops up as you type:

| Key | Does |
|---|---|
| `Ctrl-Space` | force-open the menu |
| `Ctrl-n` / `Ctrl-p` | next / previous item |
| `Ctrl-y` | accept the selected item |
| `Ctrl-e` | dismiss the menu |

---

## 13. Formatting & linting — matched to your VSCode

Formatting runs **automatically on save**, exactly like your VSCode `formatOnSave`:

| Files | Formatter | = your VSCode |
|---|---|---|
| JS / TS / JSX / TSX | **oxfmt** | `oxc.oxc-vscode` |
| HTML / CSS / JSON / YAML / Markdown | **prettier** | `esbenp.prettier-vscode` |
| Java | **jdtls** | Red Hat Java |
| Lua | **lua_ls** | — |

On save, JS/TS files also get **oxlint `fixAll`** applied first (your `source.fixAll.oxc`).
Manual triggers:

| Shortcut | Does |
|---|---|
| `Space c f` | format the buffer now |
| `Space c l` | run oxlint fix-all now |

Inspect formatter status anytime with `:ConformInfo`.

---

## 14. Git — gitsigns

Changes show in the sign column; these work inside any file in a git repo:

| Shortcut | Does |
|---|---|
| `]h` / `[h` | next / previous changed **hunk** |
| `Space h p` | **preview** the hunk's diff |
| `Space h s` / `Space h r` | **stage** / **reset** the hunk |
| `Space h b` | **blame** the current line |

---

## 15. Stack-specific workflows

**React / TypeScript**

1. `Space f f` → open a component.
2. Hover a prop or hook with `K` to see its type.
3. `gd` to jump into a component's definition, `Ctrl-o` to come back.
4. Add an import: start typing the symbol, accept the completion (`Ctrl-y`) — or use
   `Space c a` → "Add import".
5. Rename a component everywhere with `Space r n`.
6. Save (`Space w`) → oxlint auto-fixes + oxfmt formats.
7. Edit JSX fast with tag text-objects: `cit` change inside a tag, `dat` delete a whole tag.

**Java / Spring Boot**

1. Open the project so jdtls finds `pom.xml` / `build.gradle`. **The first open takes
   ~30–60s** while jdtls indexes — the statusline shows progress; let it finish.
2. `gd` / `gr` to navigate beans, controllers, services.
3. `Space c a` for source actions: *Organize imports*, *Generate getters/setters*,
   *Override methods*.
4. `K` for Javadoc, `Space r n` to rename across the project.

---

## 16. Managing the config itself

| Command | Does |
|---|---|
| `Space l` (or `:Lazy`) | plugin manager — `U` updates, `S` syncs, `x` cleans |
| `:Mason` | install/upgrade language servers & tools |
| `:LspInfo` | which servers are attached to this buffer |
| `:ConformInfo` | formatter status for this buffer |
| `:checkhealth` | diagnose problems (run if something misbehaves) |
| `:Tutor` | **the built-in 30-minute interactive tutor — do this!** |

Config files live in `~/.config/nvim/` — `lua/config/` for core settings & keymaps,
`lua/plugins/` for one file per plugin group.

---

## 17. A 7-day learning path

| Day | Focus |
|---|---|
| 1 | Run `:Tutor`. Practise `h j k l`, `i`/`a`/`Esc`, `:w` / `:q`. |
| 2 | Word motions (`w b e`), line motions (`0 $ ^`), `dd` `yy` `p` `u`. |
| 3 | The verb+noun grammar: `diw` `ci"` `ca(` `dat`. Use `.` to repeat. |
| 4 | Telescope: `Space f f`, `Space f g`. Stop browsing folders by hand. |
| 5 | LSP: `gd`, `K`, `Space c a`, `Space r n`. Navigate a real component. |
| 6 | Splits & buffers: `Space s v`, `Ctrl-hjkl`, `Shift-h/l`. |
| 7 | Git hunks, visual block `Ctrl-v`, and search-replace `:%s/…/…/g`. |

Don't try to learn it all at once. Pick 3–4 keys a day, force yourself to use them, and
let which-key (`Space`, then wait) remind you of the rest.

---

## Quick Reference (print this)

**Survival** `Esc` normal · `:w` save · `:q` quit · `:q!` quit no-save · `u` undo · `.` repeat

**Move** `w/b` word · `0/$` line ends · `gg/G` top/bottom · `Ctrl-d/u` half-page · `%` match · `*` word search

**Edit** `d`elete `c`hange `y`ank + `iw a" i( ip it` · `x` `dd` `yy` `p` `r` `~`

**Find** `Space ff` files · `Space fg` grep · `Space fb` buffers · `Space fe` tree

**Code** `gd` def · `gr` refs · `K` hover · `Space ca` action · `Space rn` rename · `[d/]d` diagnostics

**Format** `Space cf` format · `Space cl` oxlint-fix · (auto on save)

**Windows** `Space sv/sh` split · `Ctrl-hjkl` move · `Shift-h/l` buffers

**Git** `]h/[h` hunks · `Space hp` preview · `Space hs` stage · `Space hb` blame

**Help** `Space` (which-key) · `:Tutor` · `:checkhealth` · `:LspInfo`
