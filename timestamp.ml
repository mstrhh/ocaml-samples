
(* we just want to print the current time in a hh:mm:ss format
   extended: print date and time suitable to append to file names.
   
   We need: module Unix
   
   # U.gettimeofday ();;
   - : float = 1421171746.20044
   
   # U.localtime (U.gettimeofday());;
   - : U.tm =
   {U.tm_sec = 14; tm_min = 53; tm_hour = 18; tm_mday = 13; tm_mon = 0;
    tm_year = 115; tm_wday = 2; tm_yday = 12; tm_isdst = false}

   Then just pick the values from the record of type Unix.tm - yes, it's a bit tedious.
   We need printf for the leading zero.
   
   compile with: ocamlfind ocamlc -o timestamp -package unix -linkpkg timestamp.ml
*)

module U = Unix


let gettimestamp () =
  let r = U.localtime (U.gettimeofday()) in
   Printf.sprintf "%02i:%02i:%02i" r.U.tm_hour r.U.tm_min r.U.tm_sec

let getdatestamp () =
  let r = U.localtime (U.gettimeofday()) in
   Printf.sprintf "%04i%02i%02i-%02i%02i%02i"
     (r.U.tm_year + 1900) (succ r.U.tm_mon) r.U.tm_mday r.U.tm_hour r.U.tm_min r.U.tm_sec

let _ = if not !Sys.interactive then print_endline (getdatestamp())