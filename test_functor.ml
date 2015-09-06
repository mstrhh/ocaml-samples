
(**
   A beginner's example and template for the use of functors.
   
   A functor is simply a module that takes one or more modules
   as parameters.
   
   The result is a new module containing the combined definitions
   and expressions. You have to give it a name to use it.
   
   In this example one type and three functions are parameterized.
   
   20150306-1850-strobel
   ocamlfind ocamlc -o test_functor -package num -linkpkg test_functor.ml 

*)
module type Intoperations = sig
  type t
  val add        : t -> t -> t
  val to_string  : t -> string
  val from_string: string -> t
end

(* The parameter definition for the module makes it a functor. *)
(* As evidence for this see: ocamlc -i test_functor.ml         *)

module Make (Into : Intoperations) =
  struct
    type elt  = Into.t
    let add         = Into.add
    let to_string   = Into.to_string
    let from_string = Into.from_string
  end
  
module Systemint : Intoperations =
  struct
    type t = int
    let add = (+)
    let to_string   = Pervasives.string_of_int
    let from_string = Pervasives.int_of_string
  end

(**
   Alternative to int: Big_int, a pure OCaml implementation, no external .so/.dll 
 *)
module Bigocam : Intoperations =
  struct                (* the B defintion is just convenience to shorten the name *)
    module B = Big_int  (* requires the num library                                *)
    type t   = B.big_int
    let add  = B.add_big_int
    let to_string   = B.string_of_big_int 
    let from_string = B.big_int_of_string
  end
  
  
module M  = Make(Systemint);;
module Bg = Make(Bigocam)  ;;

let v1 = M.from_string "22"
and v2 = M.from_string "33" in
  Printf.printf "We can add integers: %s plus %s is %s\n" (M.to_string v1) (M.to_string v2) (M.to_string (M.add v1 v2));

let b1 = Bg.from_string "12345678901234567890123"
and b2 = Bg.from_string "4" in
  Printf.printf "We can add big integers: %s plus %s is %s\n" (Bg.to_string b1) (Bg.to_string b2) (Bg.to_string (Bg.add b1 b2));