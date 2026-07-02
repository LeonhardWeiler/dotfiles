1. rewrite the Toggle Zathura funktion in autocmds.lua to open pdfs with the default browser as seen in the next function OpenBrowser instead of zathura. es soll nur eine funktion geben OpenBrowser die alle dateitypen die ein browser anzeigen kann damit geöffnet werden. sonst nichts
2. ändere in der telescope config, dass keine dateien angezeigt werden die in der .gitignoren ausgeschlossen wurden
3. bearbeite die anweisungen in der datei refactor.md
4. findest du von einer innovativen neovim person ein repo und vielleicht auch ein paar mehr zum vergleichen und schau welche pakete die verweden und wie sie neovim verwenden um vielleicht für mich was daraus mitzunehmen
5. Ich hab diese Fehlermeldung bekommen, finde heraus warum sie auftritt und behebe sie:
```
Decoration provider "start" (ns=nvim.treesitter.highlighter):
Lua: /usr/share/nvim/runtime/lua/vim/treesitter/languagetree.lua:215: /usr/sh
are/nvim/runtime/lua/vim/treesitter.lua:197: attempt to call method 'range' (
a nil value)
stack traceback:
        [C]: in function 'f'
        /usr/share/nvim/runtime/lua/vim/treesitter/languagetree.lua:215: in f
unction 'tcall'
        /usr/share/nvim/runtime/lua/vim/treesitter/languagetree.lua:596: in f
unction 'parse'
        /usr/share/nvim/runtime/lua/vim/treesitter/highlighter.lua:580: in fu
nction </usr/share/nvim/runtime/lua/vim/treesitter/highlighter.lua:557>
Press ENTER or type command to continue
```
