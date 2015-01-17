#!/usr/bin/env ocaml
#use "topfind";;
#thread;;
#require "graphics";;

module G = Graphics
module R = Random

(*
    get your X11 display name. Error and exit if not found.
*)
let display =
  try  Sys.getenv "DISPLAY"
  with Not_found -> prerr_endline "X11 display not found, DISPLAY not set - can't display."; exit 1

(*
   draw window with default size
*)
let _ = G.open_graph display ;;   
let _ = G.set_window_title "IT-Beratung Strobel";;

(*
    these functions give the logical size. The maximum index is one less.
*)
let xmax  = G.size_x ()
and ymax =  G.size_y () ;;

(*
    create an array of (int, int) point values, ready to plot with G.plots
    Array.length is xmax, the y value is random, we will sort it.
    Remember: arrays are mutable by nature.
*)
let apoints = Array.init xmax (fun _ -> Random.int ymax)


(*  A single point is visually too small, so draw a rectangle around each point *)

let pointasrect x y =
  let x' = max 0 (pred x)     (* limit lower bound, TODO upper bound, visual only, not working data *)
  and y' = max 0 (pred y) in
   G.draw_rect x' y' 2 2

let pointasrect_clear x y =   (* background is white, foreground is black*)
  G.set_color G.white;
  pointasrect x y;
  G.set_color G.black

let swapcntr = ref 0  (* count number of swaps *)
let cmpcntr  = ref 0  (* count compares *)

let swap a i1 i2 =    (* we get the index, clear the old dots, swap the values, write the new dots *)
  let _ = pointasrect_clear i1 a.(i1)
  and _ = pointasrect_clear i2 a.(i2)
  and temp = a.(i1) in
    a.(i1) <- a.(i2);
    a.(i2) <- temp;
    incr swapcntr;
    pointasrect i1 a.(i1);
    pointasrect i2 a.(i2)
    (*Thread.delay 0.0005*)

(* do one run through the array, swapping elements as needed, return bool if swapped *)

let bubble1 ar =
  let issorted = ref true in             (* is sorted unless proven otherwise *)
  for i = 0 to (Array.length ar - 2) do  (* upper limit -1 for zero based index. -1 for swap partner *)
    incr cmpcntr;
    if ar.(i) >  ar.(i+1) then begin swap ar i (i+1); issorted := false end 
  done;
  !issorted
  
let bubbleall ar =
  let continue = ref true in             (* we must enter the loop at least once *)
  while !continue do
    continue := not (bubble1 ar);        (* continue while not is sorted *)    
    (* display *)
    (* delay   *)
    try Thread.delay 0.05 with _ -> ()   (* ignore interrupts here *)
  done

(*  Draw the initial set of points *)

let _ = Array.iteri pointasrect apoints

(* give some time to watch the initial distribution *)
let _ = Thread.delay 2.0

(* do bubble sort *)
let _ = bubbleall apoints
let _ = Printf.printf "Anzahl Vergleiche: %i, Anzahl Datenverschiebungen: %i\n%!" !cmpcntr !swapcntr
let _ = print_endline "press any key to stop the program..."

let _ = try Thread.delay 30.0
        with Unix.Unix_error (Unix.EINTR, "select", _) -> prerr_endline ("Program " ^ Sys.argv.(0) ^ " stopped.\n"); exit 0

let _ = exit 0

