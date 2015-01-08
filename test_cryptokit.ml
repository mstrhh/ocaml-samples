
(*
   Speed test for Cryptokit hash functions.
   On the way we will show how to use the Hash module functions.
   Compile with: make testcrypto  -- see Makefile
*)

module C = Cryptokit         (* shortening module names, you can still see where a function resides *)
module P = Printf
module U = Unix
module F = Filename

let statso =                 (* statistics object, to keep data and code together *)
  object (self)
    val mytime = ref (U.gettimeofday ())  (* will be set upon startup *)
    method getlapse () =     (* this gives you the net time in seconds between calls *)
      begin let old = !mytime in mytime := (U.gettimeofday ()); !mytime -. old end
    method printlapse msg = P.printf "Timing %s  %2.5f sec\n%!" msg (self#getlapse ());
  end                                      (* you better always put a semikolon after printf! *)

let hashh () =                (* create list of hash functions from module Hash, *)
  ((C.Hash.md5 ()), "MD5") ::   (* with description (in pairs, note the comma) *)
  ((C.Hash.sha1 ()), "plain SHA1") ::             (* the parens around the pair is necessary here.        *)
  ((C.Hash.ripemd160 ()), "RipeMD160") ::         (* watch out: the functions can only be used once!      *)
  ((C.Hash.sha2 224), "SHAv2 224 bits") ::        (* so this can only be used in an inner loop/iter/map   *)
  ((C.Hash.sha2 256), "SHAv2 256 bits") ::        (* because the call to hashh creates the functions anew *)
  ((C.Hash.sha2 384), "SHAv2 384 bits") ::
  ((C.Hash.sha2 512), "SHAv2 512 bits") ::
  ((C.Hash.sha3 224), "SHAv3 224 bits") ::
  ((C.Hash.sha3 256), "SHAv3 256 bits") ::
  ((C.Hash.sha3 384), "SHAv3 384 bits") ::
  ((C.Hash.sha3 512), "SHAv3 512 bits") ::
  []
  

let calc_hash h file =                        (* do the calculation, h is the hash type, see cryptokit.mli *)
  let ic = Pervasives.open_in_bin file in
  let htemp = C.hash_channel h ic in
    Pervasives.close_in ic;
    htemp

let printone fn (h,msg) =                     (* (h,msg) is from list of hashes *)
  let _ = calc_hash h fn in
    statso#printlapse msg

let printall fn =
  let _ = Sys.command (P.sprintf "cp %s /dev/null" (F.quote fn)) in (* copy file to load it into OS buffers *)
    statso#printlapse (P.sprintf "File %s copied to zero device:" fn);
    List.iter (printone fn) (hashh ())        (* filename is curried, (h,msg) is from iteration *)

let hashtoploop li =
  statso#printlapse "Program startup:";
  List.iter printall li   (* todo: sum up by algorythm *)

(*
   We get a list, supposedly of file names.
   Check if they are file names.
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
  

let _ = try main () with Failure s -> P.eprintf "Message:\n%s\n" s;

(* sample run with big file: first with byte code, then with machine code

Timing Program startup:  0.00001 sec
Timing File /srv/VirtualBox/ubuntu144.vdi copied to zero device:  2.68471 sec
Timing MD5  8.65138 sec
Timing plain SHA1  17.44251 sec
Timing RipeMD160  18.10484 sec
Timing SHAv2 224 bits  26.45130 sec
Timing SHAv2 256 bits  26.38856 sec
Timing SHAv2 384 bits  16.68286 sec
Timing SHAv2 512 bits  16.61406 sec
Timing SHAv3 224 bits  23.97883 sec
Timing SHAv3 256 bits  25.15498 sec                                                                                                       
Timing SHAv3 384 bits  31.59372 sec                                                                                                       
Timing SHAv3 512 bits  47.54531 sec                                                                                                       

Timing Program startup:  0.00002 sec                                                                                                      
Timing File /srv/VirtualBox/ubuntu144.vdi copied to zero device:  0.53251 sec                                          
Timing MD5  6.96079 sec
Timing plain SHA1  15.78836 sec
Timing RipeMD160  16.40706 sec
Timing SHAv2 224 bits  23.86009 sec
Timing SHAv2 256 bits  23.94764 sec
Timing SHAv2 384 bits  14.78549 sec
Timing SHAv2 512 bits  16.48772 sec
Timing SHAv3 224 bits  22.22666 sec
Timing SHAv3 256 bits  23.30236 sec
Timing SHAv3 384 bits  29.59063 sec
Timing SHAv3 512 bits  49.46551 sec
*)