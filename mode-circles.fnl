(local love (require "love"))
(local py (require :lib.aphysics))
(local fennel (require :fennel))

(fn do-forces [dt input-tbl]
  (collect [k v (pairs input-tbl)] ;; Updates Velocity from Acceleration
    (if (= k :v)
      (values k (py.v2cw v 
                         #(+ $1 (* dt (/ input-tbl.a.x (math.pow (/ input-tbl.radius 50) 3))))
                         #(+ $1 (* dt (/ input-tbl.a.y (math.pow (/ input-tbl.radius 50) 3))))))
    (if (= k :a)
      (values k {:x 0 :y 0})
      (values k v)))))

(fn handle_keys [current-keys tbl]
  (let []
    (var ntbl (collect [k v (pairs tbl)] (values k v)))
    (each [k v (pairs ntbl.keys)]
      (if (. current-keys k) (v ntbl (. current-keys k))))
    ntbl))

(fn do-position [dt input-tbl]
    (collect [k v (pairs input-tbl)] ; updates position by velocity
      (if (= k :p)
        (values k (py.v2cw v #(+ $1 (* dt input-tbl.v.x)) #(+ $1 (* dt input-tbl.v.y))))
        (values k v))))

(fn do-border-collision [w h tbl]
      (when (>= (+ tbl.p.x tbl.radius) w) (let [] (set tbl.v.x (* .8 (- (math.abs tbl.v.x)))) (set tbl.p.x (- w tbl.radius))))
      (when (<= (- tbl.p.x tbl.radius) 0) (let [] (set tbl.v.x (* .8 (math.abs tbl.v.x))) (set tbl.p.x tbl.radius)))
      (when (>= (+ tbl.p.y tbl.radius) h) (let [] (set tbl.v.y (* .8 (- (math.abs tbl.v.y)))) (set tbl.p.y (- h tbl.radius))))
      (when (<= (- tbl.p.y tbl.radius) 0) (let [] (set tbl.v.y (* .8 (math.abs tbl.v.y))) (set tbl.p.y tbl.radius)))
    tbl)

(fn colliding? [circ1 circ2]
  (< (+ (math.pow (- circ1.p.x circ2.p.x) 2) 
        (math.pow (- circ1.p.y circ2.p.y) 2))
     (math.pow (+ circ1.radius circ2.radius) 2)))


(fn collisions? [cirs]
  (table.sort cirs #(< $1.p.x $2.p.x))
  (for [i 1 (length cirs)] 
    (for [j (+ i 1) (length cirs)]
      (local circ1 (. cirs i))
      (local circ2 (. cirs j))
      (when (colliding? circ1 circ2)
        (let []
          ; Corrects Positions
          (var d (py.v2- circ2.p circ1.p))
          (var d_m (py.mag d))
          (var c
            (py.v2-> d (/ (- d_m (+ circ2.radius circ1.radius))
                            d_m 2)))
          (set circ1.p (py.v2+ circ1.p c))
          (set circ2.p (py.v2- circ2.p c))
          ; Calculates and Applies Force of collision
          (set d (py.v2- circ2.p circ1.p))
          (var v_rel (py.v2- circ2.v circ1.v))
          (var n (py.norm d))
          (var v_rel_n (py.v2-> n (py.v2#dot v_rel n)))
          (var j (py.norm (py.v2-> (py.v2* n (py.v2-> v_rel_n 1.95)) -1)))
          (set circ1.v (py.v2+ circ1.v v_rel_n))
          (set circ2.v (py.v2- circ2.v v_rel_n))
          (print (fennel.view circ1.v)
                 (fennel.view circ2.v))
          ))))
  cirs)


(var current-keys {})

(var circles [(require :assets.circle)])
(tset (. circles 1) :keys

{:right #(tset (. $1 :a) :x 400)
        :left  #(tset (. $1 :a) :x -400)
        :down  #(tset (. $1 :a) :y 400)
        :up    #(tset (. $1 :a) :y -400)
        :MOUSE  (fn [tbl mouse] (tset tbl :a (py.v2cw (py.pa->pb tbl.p mouse) #(* $1 500) #(* $1 500))))
        :g     #(tset $1 :radius (+ 3 (math.abs (+ (. $1 :radius ) 7))))
        :h     #(tset $1 :radius (+ 3 (math.abs (- (. $1 :radius ) 7))))})


{:keypressed (fn keypressed [key]
               (when (= key "space") (table.insert circles (+ 1 (length circles)) (require :assets.circle)))
               (tset current-keys key true))
 :keyreleased (fn keyreleased [key]
                (tset current-keys key nil))
 :mousepressed (fn mousepressed [x y b]
                 (var c (require :assets.circle))
                 (set c.p.x x)
                 (set c.p.y y)
                 (table.insert circles (+ 1 (length circles)) c)
                 (tset current-keys :MOUSE {: x : y : b}))
 :mousereleased (fn mousereleased [x y b]
                  (tset current-keys :MOUSE nil))
 :update (fn update [dt]
           (when current-keys.MOUSE
             (let [(x y) (love.mouse.getPosition)]
               (set current-keys.MOUSE.x x)
               (set current-keys.MOUSE.y y)))
           (collisions? circles)
           (set circles
                (let [tbl []] 
                  (let [(w h _) (love.window.getMode)]
                    (each [_ circle (ipairs circles)]
                      (tset tbl (+ (length tbl) 1)
                            (->> circle 
                                 (handle_keys current-keys)
                                 (do-forces dt)
                                 (do-position dt)
                                 (do-border-collision w h))))
                    tbl))))
 :draw (fn draw []
         (each [_ circle (pairs circles)] 
           (love.graphics.circle "line" circle.p.x circle.p.y circle.radius)))}

