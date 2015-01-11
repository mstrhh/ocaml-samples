

clean:
	rm -v *.cmi *.cmo *.cmx *.o
	
#
# This is an absolutely basic Makefile, and it is meant to be.
#
testcrypto: test_cryptokit.ml
	ocamlfind ocamlc   -o testcrypto.byte -package cryptokit,unix -linkpkg test_cryptokit.ml
	ocamlfind ocamlopt -o testcrypto.opt  -package cryptokit,unix -linkpkg test_cryptokit.ml
	
#
# please not that the executable is written with hyphens, while the .ml file can not be (automatically a module name)
#
watch_and_exec: watch_and_exec.ml
	ocamlfind ocamlc -w A -o watch-and-exec -thread -package threads,unix -linkpkg watch_and_exec.ml