### Download and compile treesitter language grammars in parallel.

This script automates the process of cloning, building, and compiling
Tree-Sitter grammars for various programming languages.

[Doom Emacs will support the native tree-sitter sometime, likely before the end
of February 2024.](https://github.com/doomemacs/doomemacs/issues/7623#issuecomment-1926171890)

Requirements

```text
bash
git
GNU parallel
gcc or clang
```

#### 1. Clone this repository.

`git clone git@github.com:davidhaley/tree-sitter-grammar-dl.git`

#### 2. Create a `languages_config.txt` file in the repo directory.

The format is: `<lang>,<url>,<branch_or_commit_hash>,<repo_src_dir>`

```text
                    <lang> : The language
                     <url> : The URL of the Tree-Sitter grammar repository
   <branch_or_commit_hash> : (optional) A branch name or commit hash to check out after cloning. Defaults to the repository's default branch.
            <repo_src_dir> : (optional) The directory of the grammar source files (contains `parser.c`). Defaults to 'src', and then '.'.
```

Example `languages_config.txt`:

```text
bash,https://github.com/tree-sitter/tree-sitter-bash,,
c,https://github.com/tree-sitter/tree-sitter-c,,
cpp,https://github.com/tree-sitter/tree-sitter-cpp,,
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
ocaml,https://github.com/tree-sitter/tree-sitter-ocaml,,ocaml/src
ocaml_interface,https://github.com/tree-sitter/tree-sitter-ocaml,,interface/src
org,https://github.com/milisims/tree-sitter-org,,
python,https://github.com/tree-sitter/tree-sitter-python,,
regex,https://github.com/tree-sitter/tree-sitter-regex,,
rust,https://github.com/tree-sitter/tree-sitter-rust,,
sql,https://github.com/DerekStride/tree-sitter-sql,gh-pages,
svelte,https://github.com/Himujjal/tree-sitter-svelte,,
toml,https://github.com/tree-sitter/tree-sitter-toml,,
tsx,https://github.com/tree-sitter/tree-sitter-typescript,eb6b845dee9ee22987262699a152312604313662,tsx/src
typescript,https://github.com/tree-sitter/tree-sitter-typescript,eb6b845dee9ee22987262699a152312604313662,typescript/src
yaml,https://github.com/ikatyang/tree-sitter-yaml,,
zig,https://github.com/maxxnino/tree-sitter-zig,,
odin,https://github.com/tree-sitter-grammars/tree-sitter-odin,,
```

#### 3. Execute: `./run.sh`

Each successful job will output the compiled dynamic library file into the `./dist` folder, and remove the cloned repository directory.

```sh
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

#### 4. Emacs config

**(REQUIRED)** Tell tree-sitter where the `.so` files are:

```emacs-lisp
(setq treesit-extra-load-path (list "<path_to_so_files>"))
```

**(OPTIONAL)** Helper functions to see which files loaded successfully:

```emacs-lisp
(defun get-tree-sitter-languages-from-directory (directories)
    "List Tree-sitter language symbols based on .so files in DIRECTORIES."
    (let (languages)
        (when (and directories (listp directories))
            (dolist (directory directories)
                (when (file-directory-p directory)
                    (let ((files (directory-files directory t "libtree-sitter-.*\\.so$"))
                             (prefix "libtree-sitter-")
                             (suffix ".so"))
                        (dolist (file files)
                            (let* ((filename (file-name-nondirectory file))
                                      (lang (replace-regexp-in-string (regexp-quote suffix) ""
                                                (replace-regexp-in-string (regexp-quote prefix) "" filename))))
                                (push (intern lang) languages)))))))
        languages))

(defun check-treesitter-grammar-availability ()
    "Check availability of Tree-sitter grammars for languages in treesit-extra-load-path."
    (interactive)
    (let ((languages (get-tree-sitter-languages-from-directory treesit-extra-load-path)))
        (dolist (lang languages)
            (if (treesit-language-available-p lang)
                (message "%s: supported" lang)
                (message "%s: not supported" lang)))))

```

`M-x check-treesitter-grammar-availability`, and then check output in the `*messages*` buffer.

```text
zig: supported
yaml: supported
typescript: supported
tsx: supported
toml: supported
svelte: supported
sql: supported
rust: supported
regex: supported
python: supported
org: supported
ocaml_interface: supported
ocaml: not supported
markdown: supported
make: supported
json: supported
jsdoc: supported
javascript: supported
html: supported
go: supported
elisp: supported
css: supported
cmake: supported
c: supported
bash: supported
```

#### Possible issues

The OCaml repo is a little odd in that it contains two parsers. Tree-sitter is
telling me that `ocaml_interface` is supported, but `ocaml` is not. I haven't
tested them out yet.

### Additional resources:

1. [Doom Emacs - Tree-sitter](https://github.com/doomemacs/doomemacs/blob/master/modules/tools/tree-sitter/README.org)
2. [Emacs - Tree-sitter Starter Guide](https://git.savannah.gnu.org/cgit/emacs.git/tree/admin/notes/tree-sitter/starter-guide?h=feature/tree-sitter)
3. [Mastering Emacs - How to Get Started with Tree-sitter](https://www.masteringemacs.org/article/how-to-get-started-tree-sitter)
