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
*)
let apoints = Array.init xmax (fun i -> (i, R.int ymax))


(*  A single point is visually too small, so draw a rectangle around each point *)

let pointasrect (x, y) =
  let x' = max 0 (pred x)     (* limit lower bound, TODO upper bound, visual only, not working data *)
  and y' = max 0 (pred y) in
   G.draw_rect x' y' 2 2

(*  Draw the initial set of points *)

let _ = Array.iter pointasrect apoints


(*  we need a compare function for points, that only compares y, x is equal to the array position *)

let cmpy (x, y) = Pervasives.compare y

let swapcntr = ref 0  (* count number of swaps *)
let cmpcntr  = ref 0  (* count compares *)

let swap a i1 i2 =
  let temp = a.(i1) and _ = incr swapcntr in
    a.(i1) <- a.(i2); a.(i2) <- temp 

(* do one run through the array, swapping elements as needed, return bool if swapped *)

let bubble1 ar =
  let notsorted = ref false in           (* on entry this is false *)
  for i = 0 to (Array.length ar - 2) do  (* upper limit -1 for zero based index. -1 for swap partner *)
    incr cmpcntr;
    if (snd ar.(i)) >  (snd ar.(i+1)) then swap ar i (i+1); notsorted := true
  done;
  !notsorted
  
let bubbleall ar =
  let continue = ref true in
  while !continue do
    continue := bubble1 ar;
    (* display *)
    (* delay   *)
  done


let _ = Thread.delay 20.0

let _ = exit 0

