

clean:
	rm -v *.cmi *.cmo *.cmx *.o
	
#
# This is an absolutely basic Makefile, and it is meant to be.
#
testcrypto: test_cryptokit.ml
	ocamlfind ocamlc   -o testcrypto.byte -package cryptokit,unix -linkpkg test_cryptokit.ml
	ocamlfind ocamlopt -o testcrypto.opt  -package cryptokit,unix -linkpkg test_cryptokit.ml