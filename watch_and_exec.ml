
(*
   Watch a file, execute a command if it has changed. This is handy for compiling, generation of html etc.
   This helper was originally coded in Tcl, but when the inotify tcl extension
   changed the API I decided to write it in OCaml, with check intervals. 
   20150111-1038-strobel
 
   ocamlfind ocamlc -w A -o watch-and-exec -thread -package threads,unix -linkpkg watch_and_exec.ml
   
   Example:    watch-and-exec watch_and_exec.ml "make watch_and_exec"
   The executable is written with hyphens, you can change that if you want to.
*)
module U = Unix

(* encapsulate the loop parameters in an object *)
let controller = object
  val flag = ref true
  val delay = 1.0
  method continue = !flag
  method setstop = flag := false
  method getdelay = delay
end 
 
let handler _ = controller#setstop

let gettimestamp () =
  let r = U.localtime (U.gettimeofday()) in
   Printf.sprintf "%02i:%02i:%02i" r.U.tm_hour r.U.tm_min r.U.tm_sec
   
let looper fn cmd =
   let _ = Printf.printf "watching file:     \t%s\nexecuting on change:\t%s\n%!" fn cmd  (* printf "%!" causes a flush *)
   and oldmtime = ref (Unix.time ()) in     (* if we start with current time, we will execute only on next change *)
      while controller#continue do
        let stt = Unix.stat fn in                                               
        if stt.Unix.st_mtime > !oldmtime       
          then
            begin
              oldmtime := stt.Unix.st_mtime;
              print_endline ("---------- " ^ (gettimestamp ()) ^ " ----------");
              try ignore (Sys.command cmd) with _ -> ()    (* ignore return code, ignore all execution errors*)
            end
          else
            try
              Thread.delay controller#getdelay
            with Unix.Unix_error(Unix.EINTR, "select", _) -> Printf.printf "\n-----  %s stopped. -----\n" Sys.executable_name ; exit 0
      done                                   
(*
   I tried to install a Ctrl-C handler to set a flag and smoothly shut the loop down,
   but the signal is received normally in Thread.delay, which is evidently implemented
   as as Unix select call, causing a Unix.EINTR exception.
   
   You find the type of exceptions when testing your code, so you could start without try-catch,
   see what exceptions are thrown, and catch them with precision.
   
   The controller object is largely obsolete, unless someone manages to hit the key at the
   microsecond when the loop is active. The code is left here for your edification.
*)

(* install ctrl-C handler, for demonstration, and start looping *)

let main fn cmd = Sys.set_signal Sys.sigint (Sys.Signal_handle handler); looper fn cmd



(* match on command line parameters and print errors. As you can see we match on an array. *)
(* the first pattern is: ignore executable name, pick filename and command                 *)

let () = match Sys.argv with

  | [|_; fn; cmd|] -> if not (Sys.file_exists fn)
                      then begin Printf.eprintf "File %s not found.\n" fn; exit 1 end
                      else main fn cmd
                      
  | _ -> Printf.eprintf
  "This is the OCaml binary. Call with arguments:\n\t1. file to watch for change\n\t2. command to execute, quoted\n"; exit 1

