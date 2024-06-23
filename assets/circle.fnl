
(local py (require :lib.aphysics))

{:v {:x 0 :y 0}
 :a {:x 0 :y 0}
 :p {:x 0 :y 0}
 :fc 1
 :radius 60
 :color "white"
 :keys {:right #(tset (. $1 :a) :x 400)
        :left  #(tset (. $1 :a) :x -400)
        :down  #(tset (. $1 :a) :y 400)
        :up    #(tset (. $1 :a) :y -400)
        :MOUSE  (fn [tbl mouse] (tset tbl :a (py.v2cw (py.pa->pb tbl.p mouse) #(* $1 500) #(* $1 500))))
        :g     #(tset $1 :radius (+ 3 (math.abs (+ (. $1 :radius ) 7))))
        :h     #(tset $1 :radius (+ 3 (math.abs (- (. $1 :radius ) 7))))}}

