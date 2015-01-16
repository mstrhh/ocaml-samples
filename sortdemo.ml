#!/usr/bin/env ocaml


#use "topfind";;

#thread;;
#require "graphics";;

module G = Graphics



let _ = G.open_graph ":0" ;; 
let _ = G.set_window_title "IT-Beratung Strobel";;


let xmax  = pred (G.size_x ())
and ymax =  pred (G.size_y ()) ;;

Graphics.lineto xmax ymax ;;

Thread.delay 8.0;

exit 0

