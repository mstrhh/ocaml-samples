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
  let x' = max 0 (pred x)
  and y' = max 0 (pred y) in
   G.draw_rect x' y' 2 2

(*  Draw the initial set of points *)

let _ = Array.iter pointasrect apoints


(*  we need a compare function for points, that only compares y, x is equal to the array position *)

let cmpy (x, y) = Pervasives.compare y

let _ = Thread.delay 20.0

let _ = exit 0

