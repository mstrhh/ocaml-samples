#!/usr/bin/env ocaml
(*
    A List exercise:
    In /etc/ssl/certs/ you will find many files: some are certificates,
    others are links to certificates.
    Reason: every certificate must have a link with the name of it's hash pointing to it.
    To take care of hash collisions, the links have .0 appended, or .1 for the first collision.
    
    Check if every certificate is linked, and every link has it's certificate.
    
    First approach: get all files, split the list into links and datafiles,
    and filter pathological cases. 
*)
#use "topfind";;
#require "unix";;

                                  (* set certpath in the environment for testing *)
let certpath = try Sys.getenv "certpath" with Not_found -> "/etc/ssl/certs" 

let () = Sys.chdir certpath

type linkdesc = {lname: string; fname: string}  (* record, so we don't get confused which is what *)

let ls1 = Array.to_list (Sys.readdir ".");;
                                  (* so let's add the path in a save way *)
                                  (* maybe we will use Unix.lstat later *)
let (links, files) =              (* partition list into 2 lists: one with linkdesc records,
                                                                  one with data filenames only *)
  let f (ls, fs) s =              (* inside fold: take a pair of lists and the current string  *)
    try let fname = Unix.readlink s in ({lname=s; fname}::ls, fs)  (* append to lists as appropriate *)
    with  Unix.Unix_error (Unix.EINVAL, _,_) -> ( ls, s :: fs)
  in
  List.fold_left f ([], []) ls1   (* this is a combination of partition, map, filter *)


let files_not_linked =
  let findinlinks s = not (List.exists (fun r -> r.fname = s) links)
  in
  List.filter findinlinks files

let () = print_endline ("Checking files and links in " ^ certpath ^ ":")

let () = print_endline "Files without link: ";
         List.iter (fun s -> print_endline ("\t" ^ s)) files_not_linked

let () = print_endline "Links without file: ";
         List.iter (fun r -> if not (Sys.file_exists r.fname) then print_endline ("\t" ^ r.lname ^ ": no file " ^ r.fname)) links

