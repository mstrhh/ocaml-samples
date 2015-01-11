
(*
   Watch a file, execute a command if it has changed. This is handy for compiling, generation of html etc.
   This helper was originally coded in Tcl, but when the inotify tcl extension
   changed the API I decided to write it in OCaml, with check intervals. 
   20150111-1038-strobel
 
   ocamlfind ocamlc -w A -o watch-and-exec -thread -package threads,unix -linkpkg watch_and_exec.ml
   
   Example:    watch-and-exec watch_and_exec.ml "make watch_and_exec"
   The executable is written with hyphens, you can change that if you want to.
*)

let controller = object
  val flag = ref true
  val delay = 1.0
  method continue = !flag
  method setstop = flag := false
  method getdelay = delay
end 
 
  
let handler _ = controller#setstop

let looper fn cmd =
   let _ = Printf.printf "watching file:     \t%s\nexecuting on change:\t%s\n%!" fn cmd
   and oldmtime = ref (Unix.time ()) in     (* if we start with current time, we will execute only on next change *)
      try
      while controller#continue do
      let stt = Unix.stat fn in                                               
        if stt.Unix.st_mtime > !oldmtime       (* get modification time, ignore all execution errors*)
          then
            begin
              oldmtime := stt.Unix.st_mtime;
              try ignore (Sys.command cmd) with _ -> ()
            end
          else
            try
              Thread.delay controller#getdelay
            with Unix.Unix_error(Unix.EINTR, _, _) -> Printf.printf "\n-----  %s stopped. -----\n" Sys.executable_name ; exit 0
      done; ()
      with  Unix.Unix_error(Unix.EINTR, _, _) -> Printf.printf "\n-----  %s stopped. -----\n" Sys.executable_name ; exit 0
(*
   I tried to install a Ctrl-C handler to smoothly shut the loop down,
   but the signal is received normally in Thread.delay,
   which is evidently implemented as as Unix select call, causing a Unix.EINTR exception.
   So the controller object is largely obsolete, unless someone manages to hit the key at the
   microsecond when the loop is active. The code is left here for your edification.
*)

(* install ctrl-C handler, for demonstration, and start looping *)

let main fn cmd = Sys.set_signal Sys.sigint (Sys.Signal_handle handler); looper fn cmd

 (* match on command line parameters and print errors. As you can see we match on an array. *)

let _ = match Sys.argv with             
  | [|_; fn; cmd|] -> if not (Sys.file_exists fn) then begin Printf.eprintf "File %s not found.\n" fn; exit 1 end else main fn cmd
  
  | _ -> Printf.eprintf "Call with arguments:\n\t1. file to watch for change\n\t2. command to execute, quoted\n"; exit 1

