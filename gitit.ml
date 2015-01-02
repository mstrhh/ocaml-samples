
(**
 Simple little helper
 git add + git commit + git push
 script will call ssh-add if no key loaded
 Compile: ocamlopt -o gitit gitit.ml
*)

(** Print usage to stdout *)
let scriptinfo () = 
  Printf.printf "\tgit-Helper: git add + git commit + git push for 1 File\n";
  Printf.printf "\tCall with: 1. filename 2. commit message, quoted as must be for command line use.\n"

(** check if some private key loaded, easy: ssh-add uses return codes consistently *)
let check_sshkey () = 
  let listcmd = "ssh-add -l 1>/dev/null 2>&1" in
    match Sys.command listcmd with
    | 0 -> true
    | 1 -> (Sys.command "ssh-add") = 0
    | 2 -> failwith "gitit: ssh-agent not running, no public-key session available. "
    | _ -> failwith "gitit: unknown error when running ssh-add. "

            
(** main, using pattern matching for parameter list  *)            
let main1 args = match List.tl (Array.to_list args) with
  | fn :: cmsg :: [] ->
	let fn = Filename.quote fn
	and cmsg = Filename.quote cmsg 
	and spacer = " " in
          if check_sshkey () then
            if (Sys.command ("git add " ^ fn)) = 0 then
              if (Sys.command ("git commit -m " ^ cmsg ^ spacer ^ fn) ) = 0 then
                exit (Sys.command "git push") (* exit with return code from Sys.command *)
               else failwith "Error in git commit"
            else failwith "Error in git add"
  | _ -> scriptinfo ()

let _ = try
          main1 Sys.argv; exit 0
        with Failure s -> prerr_endline s (* print to stderr here *)

(* or in 1 line: 

let _ = try main1 Sys.argv; exit 0 with Failure s -> prerr_endline s

*)
