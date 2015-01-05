
(*
   Speed test for Cryptokit hash functions.
   On the way we will show how to use the module functions.
   Compile with: make testcrypto  -- see Makefile
*)

module C = Cryptokit         (* shortening module names, you can still see where a function resides *)
module P = Printf
module U = Unix

let statso =                 (* statistics object, to keep data and code together *)
  object (self)
    val mytime = ref (U.gettimeofday ())  (* will be set upon startup *)
    method getlapse () =     (* this gives you the net time in seconds between calls *)
      begin let old = !mytime in mytime := (U.gettimeofday ()); !mytime -. old end
    method printlapse msg = P.printf "Timing %s  %2.5f sec\n" msg (self#getlapse ());
  end                                      (* you better always put a semikolon after printf! *)

let hashthem l = statso#printlapse "Program startup:"

(*
   We get a list, supposedly of file names.
   Check if thery are file names.
   Then call the hash machine.
*)
let handle_list l = 
  let cleanlist = List.filter Sys.file_exists l in
    if (List.length cleanlist) = 0
      then failwith "No filenames found. Please enter some file names on the command line"
      else hashthem cleanlist
  
(*
   We expect one ore more filenames on the commandline,
   they will all be hashed.
*)

let main () = match Array.to_list Sys.argv with
  | exe :: []      -> failwith "Please enter one or more file names on the command line for use as hash input data."
  | exe :: params  -> handle_list params
  | _              -> failwith "Internal error reading command line arguments."
  

let _ = try main () with Failure s -> P.eprintf "Message:\n%s\n!" s;