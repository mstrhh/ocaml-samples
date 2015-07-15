
(*
    tmtoiso - from Unix.tm type to ISO date string
    ---------------------------------------------
    Example: Dateutil.tmtoiso ~dform:Dateutil.Dcompact (Unix.localtime (Unix.time ()))
    needs Module Unix
*)

type dformtype = Dfull            (* YYYY-MM-DD hh:mm:ss -- acceptable in Postgresql and others *)
               | Dcompact         (* YYYYMMDD-hhmmss     -- good to make file names unique *)
               | Dymd             (* YYYYMMDD*)

let tmtoiso ?(dform=Dfull) t =    (* the call syntax for optional argument is ~dform:Dcompact *)
  let year  = t.Unix.tm_year + 1900 (* some values in the Unix.tm structure need adjustion *)
  and month = succ t.Unix.tm_mon
  and day   = t.Unix.tm_mday
  and h     = t.Unix.tm_hour
  and m     = t.Unix.tm_min
  and s     = t.Unix.tm_sec in
    match dform with
    | Dfull    ->  Printf.sprintf "%04i-%02i-%02i %02i:%02i:%02i" year month day h m s
    | Dcompact ->  Printf.sprintf "%04i%02i%02i-%02i%02i%02i"     year month day h m s
    | Dymd     ->  Printf.sprintf "%04i%02i%02i"                  year month day 

(*
    this helps 
    --------------------------------------------------------------------------
*)    
let getnowstring ?(dform=Dcompact) () = tmtoiso ~dform (Unix.localtime (Unix.time ()))
