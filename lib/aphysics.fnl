(fn v2cw [v2 tx ty]
  {:x (tx v2.x) :y (ty v2.y)})

(fn v2* [v1 v2]
  (v2cw v1 #(* $1 v2.x) #(* $1 v2.y)))

(fn v2+ [v1 v2]
  {:x (+ v1.x v2.x) :y (+ v1.y v2.y)})

(fn v2-> [v2 s]
  {:x  (* s v2.x) 
   :y (* s v2.y)})

(fn v2- [v1 v2]
  {:x (- v1.x v2.x) :y (- v1.y v2.y)})

(fn mag [{: x : y} v]
  (math.pow (+ (math.pow x 2) (math.pow y 2)) .5))

(fn norm [v0]
  (let [m (if (= 0 (mag v0)) 1 (mag v0))]
  (collect [k v (pairs v0)]
    (values k (/ v m)))))

(fn pa->pb [pa pb]
  (norm (v2- pa pb)))

(fn v2#dot [v1 v2]
  (+ (* v1.x v2.x) (* v1.y v2.y)))

{: v2->
 : v2-
 : v2+
 : v2*
 : v2#dot
 : v2cw
 : mag
 : norm
 : pa->pb}
