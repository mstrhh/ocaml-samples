
(**
 Simple little helper
 git add + git commit + git push
 script will call ssh-add if no key loaded
 Compile: ocamlopt -o gitit gitit.ml
      or  ocamlc  -o gitit gitit.ml
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

            
(** main, using pattern matching for parameter list
    
    You will often see the first line as:
    let main = function
    
    Why? Because it is shorter, no need to introduce a name for the argument.
    function always takes 1 parameter, and you can start with pattern matching
    right away, variable binding is done there.

*)            
let main1 args = match args with
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

(** call to main, with exception handling.
    Note the stumbling block in Sys.argv: on position 0 there is the executable name,
    you would normally cut this off (see also Sys.executable_name).
    And for pattern matching you need a list.
    
    The variable named _ is an anomymous variable, for throw away values.
*)
let _ = try
          main1 (List.tl (Array.to_list Sys.argv)); exit 0
        with Failure s -> prerr_endline s (* print to stderr here *)


(* or in 1 line: 

let _ = try main1  List.tl (List.tl (Array.to_list Sys.argv)); exit 0 with Failure s -> prerr_endline s

*)
