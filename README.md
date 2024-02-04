### Download and compile treesitter language grammars in parallel.

#### 1. Clone this repository.

`git clone git@github.com:davidhaley/tree-sitter-grammar-dl.git`

#### 2. Create a `languages_config.txt` file in the repo directory.

The format is: `<lang>,<url>,<branch>,<sourcedir>`

``` text
     <lang> : The language
      <url> : The repository URL for the source code of the language's tree-sitter grammar
   <branch> : The branch to check out before the compilation proceeds
<sourcedir> : The source directory (it should contain `parser.c`)
```

Example `languages_config.txt`:

``` text
bash,https://github.com/tree-sitter/tree-sitter-bash,,
c,https://github.com/tree-sitter/tree-sitter-c,,
cmake,https://github.com/uyha/tree-sitter-cmake,,
css,https://github.com/tree-sitter/tree-sitter-css,,
elisp,https://github.com/Wilfred/tree-sitter-elisp,,
go,https://github.com/tree-sitter/tree-sitter-go,,
html,https://github.com/tree-sitter/tree-sitter-html,,
javascript,https://github.com/tree-sitter/tree-sitter-javascript,master,src
jsdoc,https://github.com/tree-sitter/tree-sitter-jsdoc,,
json,https://github.com/tree-sitter/tree-sitter-json,,
make,https://github.com/alemuller/tree-sitter-make,,
markdown,https://github.com/ikatyang/tree-sitter-markdown,,
ocaml,https://github.com/tree-sitter/tree-sitter-ocaml,,interface/src
org,https://github.com/milisims/tree-sitter-org,,
python,https://github.com/tree-sitter/tree-sitter-python,,
regex,https://github.com/tree-sitter/tree-sitter-regex,,
rust,https://github.com/tree-sitter/tree-sitter-rust,,
sql,https://github.com/DerekStride/tree-sitter-sql,gh-pages,
svelte,https://github.com/Himujjal/tree-sitter-svelte,,
toml,https://github.com/tree-sitter/tree-sitter-toml,,
tsx,https://github.com/tree-sitter/tree-sitter-typescript,master,tsx/src
typescript,https://github.com/tree-sitter/tree-sitter-typescript,master,typescript/src
yaml,https://github.com/ikatyang/tree-sitter-yaml,,
zig,https://github.com/maxxnino/tree-sitter-zig,,
```

#### 3. Execute: `./run.sh`

Each successful job will output the compiled dynamic library file into the `./dist` folder, and remove the cloned repository directory.

``` sh
$ ls dist/
libtree-sitter-bash.so
libtree-sitter-c.so
libtree-sitter-cmake.so
libtree-sitter-css.so
libtree-sitter-elisp.so
libtree-sitter-go.so
libtree-sitter-html.so
libtree-sitter-javascript.so
libtree-sitter-jsdoc.so
libtree-sitter-json.so
libtree-sitter-make.so
libtree-sitter-markdown.so
libtree-sitter-ocaml.so
libtree-sitter-org.so
libtree-sitter-python.so
libtree-sitter-regex.so
libtree-sitter-rust.so
libtree-sitter-sql.so
libtree-sitter-svelte.so
libtree-sitter-toml.so
libtree-sitter-tsx.so
libtree-sitter-typescript.so
libtree-sitter-yaml.so
libtree-sitter-zig.so
```


### Additional resources:

1. [Doom Emacs - Tree-sitter](https://github.com/doomemacs/doomemacs/blob/master/modules/tools/tree-sitter/README.org)
2. [Emacs - Tree-sitter Starter Guide](https://git.savannah.gnu.org/cgit/emacs.git/tree/admin/notes/tree-sitter/starter-guide?h=feature/tree-sitter)
3. [Mastering Emacs - How to Get Started with Tree-sitter](https://www.masteringemacs.org/article/how-to-get-started-tree-sitter)
