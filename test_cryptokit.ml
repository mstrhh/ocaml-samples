
(*
   Speed test for Cryptokit hash functions.
   On the way we will show how to use the Hash module functions.
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
    method printlapse msg = P.printf "Timing %s  %2.5f sec\n%!" msg (self#getlapse ());
  end                                      (* you better always put a semikolon after printf! *)

let hashh () =                (* create list of hash functions from module Hash, *)
  ((C.Hash.md5 ()), "MD5") ::   (* with description (in pairs, note the comma) *)
  ((C.Hash.sha1 ()), "plain SHA1") ::
  ((C.Hash.ripemd160 ()), "RipeMD160") ::
  ((C.Hash.sha2 224), "SHA2 224 bits") ::
  ((C.Hash.sha2 256), "SHA2 256 bits") ::
  ((C.Hash.sha2 384), "SHA2 384 bits") ::
  ((C.Hash.sha2 512), "SHA2 512 bits") ::
  ((C.Hash.sha3 224), "SHA3 224 bits") ::
  ((C.Hash.sha3 256), "SHA3 256 bits") ::
  ((C.Hash.sha3 384), "SHA3 384 bits") ::
  ((C.Hash.sha3 512), "SHA3 512 bits") ::
  []
  

let calc_hash h file =
  let ic = Pervasives.open_in_bin file in
  let htemp = C.hash_channel h ic in
    Pervasives.close_in ic;
    htemp

let printone fn (h,msg) =
  let _ = calc_hash h fn in
    statso#printlapse msg
    

let hashtoploop l =
  statso#printlapse "Program startup:";
  List.iter (printone (List.hd l)) (hashh ())

(*
   We get a list, supposedly of file names.
   Check if thery are file names.
   Then call the hash machine.
*)
let handle_list l = 
  let cleanlist = List.filter (fun n -> (Sys.file_exists n) && not (Sys.is_directory n) ) l in
    if (List.length cleanlist) = 0
      then failwith "No filenames found. Please enter some file names on the command line"
      else hashtoploop cleanlist
  
(*
   We expect one ore more filenames on the commandline,
   they will all be hashed.
*)

let main () = match Array.to_list Sys.argv with
  | exe :: []      -> failwith "Please enter one or more file names on the command line for use as hash input data."
  | exe :: params  -> handle_list params
  | _              -> failwith "Internal error reading command line arguments."
  

let _ = try main () with Failure s -> P.eprintf "Message:\n%s\n!" s;