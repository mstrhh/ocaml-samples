#!/usr/bin/env ocaml

(*
   This is a bubble sort demonstration with the help of the graphics module.
   We create an array with the size of max window x index, and randomize
   the values limited by max window y index.
   The random numbers are always the same if you don't use a Random init function firest.
   Then we start sorting the array, showing the changes while they are done.
   
   Possible extensions: gather statistics on true/different random values, test it on
   sorted data, and on reverse sorted data.
   
   Bubble2 sort is 'improved' by runs going up and others going down.
   Bubble3 sort is improved by limiting the run length at both ends: once you made the first
   run up, you know the biggest item has bubbled up. Same is true for "bubbling down".
   
*)


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
let apoints = let _ = Random.self_init () in Array.init xmax (fun _ -> Random.int ymax)


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

(* do one run through the array, swapping elements as needed, return bool if swapped *)

let bubble1up ar low_i hi_i =              (* array from index to index *)
  try
    if low_i = hi_i then true else         (* detect meeting limits *)
    begin
      let issorted = ref true in            (* is sorted unless proven otherwise *)
      for i = low_i to hi_i do               (* caller does index management *)
        incr cmpcntr;
        if ar.(i) >  ar.(i+1) then begin swap ar i (i+1); issorted := false end 
      done;
      !issorted
    end
  with Invalid_argument "index out of bounds" -> failwith ("Index error in bubble1up "^(string_of_int low_i)^" "^(string_of_int hi_i))
  
(* with bubbling up it takes very long for small values at the high end to travel down.
   We try to improve this by one walk up, and one walk down. This will speed up sorting
   elements initially at the wrong end. *)

let bubble1dwn ar low_i hi_i =          (* we decide do keep the low hi naming, but go from hi to low *)
  try
    if low_i = hi_i then true else      (* detect meeting limits *)
    begin
      let issorted = ref true in
       for i = hi_i downto (low_i+1) do (* caller does index management, but we access one below low_i *)
        incr cmpcntr;
        if ar.(i) <  ar.(i-1) then begin swap ar i (i-1); issorted := false end 
      done;
      !issorted
    end
  with Invalid_argument "index out of bounds" -> failwith ("Index error in bubble1dwn "^(string_of_int low_i)^" "^(string_of_int hi_i))


(* let's do this bubbling the functional way, without an imperative loop construct.
   after bubble1up the upper limit goes down, after bubble1dwn the lower limit goes up.
   Index management is a bit tricky, we can only change the limits after (bubbleup, bubbledown).
   Reason is the way these functions set the swap index. *)

let bubbleall ar =
  let rec subbubble low hi = function   (* arguments: lower index, higher index, flag *)
    | true  -> if not (bubble1up  ar low hi) then subbubble low       hi       false else () (* else done *)
    | false -> if not (bubble1dwn ar low hi) then subbubble (low + 1) (hi - 1) true  else () (* else done *)
  in
  subbubble 0 ((Array.length ar) - 2) true


(*  Draw the initial set of points *)

let _ = Array.iteri pointasrect apoints

(* give some time to watch the initial distribution *)
let _ = Thread.delay 2.0

let testar = Array.copy apoints    (* we only work on the copy *)


(* do bubble sort *)
let _ = bubbleall testar
let _ = Printf.printf "Number of compares: %i, number of data swaps: %i\n%!" !cmpcntr !swapcntr

let sorted_orig = Array.copy apoints
let _ = Array.sort Pervasives.compare sorted_orig
let _ = if testar <> sorted_orig then prerr_endline "Alarm! Array comparision gives FALSE." else print_endline "Result check: ok."

let _ = print_endline "press any key to stop the program..."

let _ = try Thread.delay 30.0
        with Unix.Unix_error (Unix.EINTR, "select", _) -> prerr_endline ("Program " ^ Sys.argv.(0) ^ " stopped.\n"); exit 0

let _ = exit 0

