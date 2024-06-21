(fn v2->v2 [v2 tx ty]
  {:x (tx v2.x) :y (ty v2.y)})

(fn mag [{: x : y} v]
  (math.pow (+ (math.pow x 2) (math.pow y 2)) .5))

(fn norm [v0]
  (let [m (if (= 0 (mag v0)) 1 (mag v0))]
  (collect [k v (pairs v0)]
    (values k (/ v m)))))

(fn pa->pb [pa pb]
  (norm (v2->v2 pa #(- pb.x $1) #(- pb.y $1))))

{: v2->v2 
 : mag
 : norm
 : pa->pb}
