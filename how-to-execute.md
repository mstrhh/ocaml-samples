
# How to execute OCaml code

You can execute ocaml code in several ways. We will use here the [example command line reader](./ex_arguments.ml) for demonstration.

## Variations

### The _true_ scripting style

The file is written as a shell script, and compiled on the fly. This is the way PERL, Tcl, PHP-cli or others do work.

```
#!/usr/bin/env ocaml
let printfunction i e = Printf.printf "Argument no. %i: %s\n" i e
  in
  Array.iteri printfunction Sys.argv
```

Put this into a file, make the file executable, and execute it:

```
str@s131:~/github-samples> vi temp.ml
str@s131:~/github-samples> chmod +x temp.ml
str@s131:~/github-samples> ./temp.ml "my arguments:" *.ml
Argument no. 0: ./temp.ml
Argument no. 1: my arguments:
Argument no. 2: ex_arguments.ml
Argument no. 3: gitit.ml
Argument no. 4: temp.ml
```
This works well for scripts you change often, or when you have to look at the code to see what it does...


### Compile to byte code

This is a edit - compile - run workflow. We use the file

```
let printfunction i e = Printf.printf "Argument no. %i: %s\n" i e
  in
  Array.iteri printfunction Sys.argv
```

and put it in file temp.ml, like so:

```
str@s131:~/github-samples> vi temp.ml
str@s131:~/github-samples> ocamlc -o temp temp.ml
str@s131:~/github-samples> ./temp *.ml
Argument no. 0: ./temp
Argument no. 1: ex_arguments.ml
Argument no. 2: gitit.ml
Argument no. 3: temp.ml
```

This created the file *temp* with size 124903 bytes. It is a binary file that is run by the ocamlrun program (included in your ocaml distribution).

### Compile to machine code (also called native code)

Take the same _sample.ml_ file and do:

```
str@s131:~/github-samples> ocamlopt -o temp temp.ml
str@s131:~/github-samples> ./temp  *.ml
Argument no. 0: ./temp
Argument no. 1: ex_arguments.ml
Argument no. 2: gitit.ml
Argument no. 3: temp.ml
```

Now you have a file *temp* in your directory, which is an ELF executable with size 534618 bytes.

### Use a package called ocamlscript

This package with name _ocamlscript_ does what Python does: upon startup, check to see if you have a bytecode file corresponding to your script file. If not create it - which means compile it, then execute the bytecode file.

If you have it installed (get it [here](http://opam.ocaml.org/packages/)), create a file like this:

```
#!/usr/bin/env ocamlscript
Ocaml.use_ocamlc := false ; (* true for Bytecode *)
Ocaml.packs := [] ;
Ocaml.sources := [] ;;
--
let printfunction i e = Printf.printf "Argument no. %i: %s\n" i e
  in
  Array.iteri printfunction Sys.argv
```

Make the script executable and run it. You now have a file in your directory with name *temp.ml.exe* and size 534846 bytes, in this case a native code file.

## How to choose your method

True scripting with ocaml:
- easy to read, easy to change
- on execute: needs compiler and libraries installed
- compile time: not noticeable
- run time efficient: acceptable

Compile to byte code:
- binary is decoupled from source, find your code first to have a look
- edit - compile - run cycle, slow
- small executable
- on execute: needs ocamlrun installed
- compile time: quite short
- run time efficient: good

Compile to native code:
- binary is decoupled from source
- edit - compile - run cycle, slow
- big executable
- on execute: does not need ocaml components
- compile time: noticeable
- run time efficient: very good, roughly 1/3 of bytecode runtime.

Using ocamlscript:
- easy to read, easy to change
- on execute: needs compiler and libraries installed
- compile time: depends on using ocamlc or ocamlopt
- run time efficient: depends on using ocamlc or ocamlopt
- watch out: upon compile (first execution) wants to write to source directory

So now you can choose your method. As to compile and run timings, this should be qualified with numbers. We'll do that, sooner or later.
