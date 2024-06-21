(local love (require "love"))
(local py (require :lib.aphysics))

(fn do-forces [dt input-tbl]
  (collect [k v (pairs input-tbl)] ;; Updates Velocity from Acceleration
    (if (= k :v)
      (values k (py.v2->v2 v 
                        #(+ $1 (* dt (/ input-tbl.a.x (math.pow (/ input-tbl.radius 50) 3))))
                        #(+ $1 (* dt (/ input-tbl.a.y (math.pow (/ input-tbl.radius 50) 3))))))
    (if (= k :a)
      (values k (py.v2->v2 v #(+ 0) #(+ 0)))
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
        (values k (py.v2->v2 v #(+ $1 (* dt input-tbl.v.x)) #(+ $1 (* dt input-tbl.v.y))))
        (values k v))))

(fn do-border-collision [w h tbl]
  (let [ntbl (collect [k v (pairs tbl)] (values k v))]
      (when (>= (+ ntbl.p.x ntbl.radius) w) (let [] (set ntbl.v.x (* .8 (- (math.abs ntbl.v.x)))) (set ntbl.p.x (- w ntbl.radius))))
      (when (<= (- ntbl.p.x ntbl.radius) 0) (let [] (set ntbl.v.x (* .8 (math.abs ntbl.v.x))) (set ntbl.p.x ntbl.radius)))
      (when (>= (+ ntbl.p.y ntbl.radius) h) (let [] (set ntbl.v.y (* .8 (- (math.abs ntbl.v.y)))) (set ntbl.p.y (- h ntbl.radius))))
      (when (<= (- ntbl.p.y ntbl.radius) 0) (let [] (set ntbl.v.y (* .8 (math.abs ntbl.v.y))) (set ntbl.p.y ntbl.radius)))
    ntbl))

(var current-keys {})

(var circles [(require :assets.circle)])


{:keypressed (fn keypressed [key]
               (tset current-keys key true))
 :keyreleased (fn keyreleased [key]
                (tset current-keys key nil))
 :mousepressed (fn mousepressed [x y b]
                 (tset current-keys :MOUSE {: x : y : b}))
 :mousereleased (fn mousereleased [x y b]
                  (tset current-keys :MOUSE nil))
 :update (fn update [dt]
           (when current-keys.MOUSE
             (let [(x y) (love.mouse.getPosition)]
               (set current-keys.MOUSE.x x)
               (set current-keys.MOUSE.y y)))
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

