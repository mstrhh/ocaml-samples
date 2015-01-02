
(*
   Example: print all arguments from the command line, with numbering
   Level: entry
   Test with data from current directory: ex_arguments *
*)

(* we need a function that receives an int and a string and does the printing *)
let printfunction i e = Printf.printf "Argument no. %i: %s\n" i e
  in
  (* interate over array, with index *)
  Array.iteri printfunction Sys.argv
  