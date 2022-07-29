(import freja/event/subscribe :as e)
(import freja/state :as :s)

(def root-state @{:freja/label "Editor"
                  :code @[]
                  :selected 0
                  :put (fn [self k v]
                         (e/put! s/editor-state :force-refresh true)
                         (put self k v))
                  :update (fn [self k f & args]
                            (e/put! s/editor-state :force-refresh true)
                            (update self k f ;args))})

(def ops ["inc" "dec" "jz" "reg"])

(defn border
  [{:width w
    :bg bg
    :color c} & children]
  (default w 1)
  (default bg :blank)
  (def [t r b l] (if (number? w) [w w w w] w))
  [:background {:color c}
   [:padding {:top t :right r :bottom b :left l}
    [:background {:color bg}
     ;children]]])

(defn box
  [{:border/color border/color
    :border/width border/width
    :bg bg
    :padding p
    :padding/top pt
    :padding/right pr
    :padding/bottom pb
    :padding/left pl
    :margin m
    :margin/top mt
    :margin/right mr
    :margin/bottom mb
    :margin/left ml}
   & children]

  (default bg :blank)
  (default border/width 0)
  (default border/color (if (zero? border/width)
                          :blank
                          :black))
  (default p [0 0 0 0])
  (default m [0 0 0 0])

  (def p (if (number? p) [p p p p] p))
  (def m (if (number? m) [m m m m] m))

  (default pt (in p 0))
  (default pr (in p 1))
  (default pb (in p 2))
  (default pl (in p 3))

  (default mt (in m 0))
  (default mr (in m 1))
  (default mb (in m 2))
  (default ml (in m 3))

  [:padding {:top mt :right mr :bottom mb :left ml}
   [border {:width border/width
            :color border/color
            :bg bg}
    [:padding {:top pt :right pr :bottom pb :left pl}
     ;children]]])


(defn label
  [text]
  [:text {:text text
          :color :white
          :size 32}])

(defn insert
  [state op]
  (case op
    "reg"
    (:update state :show-reg not)

    # else
    (do
      (:put state :selected (length (state :code)))
      (:update state :code array/push op))))

(defn button
  [props]
  [:padding {:right 6}
   [:clickable props
    (label (props :label))]])

(defn btn
  [state op]
  [:padding {:right 6}
   [:clickable {:on-click (fn [_] (insert state op))}
    (label op)]])

(defn select
  [state i]
  (:put state :selected i))

(defn code-block
  [state code i]
  [:padding {:right 6}
   [:clickable {:on-click (fn [_] (select state i))}
    (label code)]])

(defn dec-or-0
  [v]
  (if (pos? v)
    (dec v)
    0))

(defn delete-selected
  [state]
  (:update state :code array/remove (state :selected))
  (:update state :selected dec-or-0))

(defn component
  [state]
  [:column {}
   [:row {}
    ;(map (partial btn state) ops)]
   (when (state :show-reg)
     [:column {}
      [:row {}
       ;(seq [r :range [0 10]]
          [button
           {:on-click (fn [_] (insert state (string "r" r)))
            :label (string/format "r%02d" r)}])]
      [:row {}
       ;(seq [r :range [10 20]]
          [button
           {:on-click (fn [_] (insert state (string "r" r)))
            :label (string "r" r)}])]
      [:row {}
       ;(seq [r :range [20 30]]
          [button
           {:on-click (fn [_] (insert state (string "r" r)))
            :label (string "r" r)}])]
      [:row {}
       ;(seq [r :range [30 32]]
          [button
           {:on-click (fn [_] (insert state (string "r" r)))
            :label (string "r" r)}])]])
   [:row {}
    ;(seq [i :range [0 (length (state :code))]
           :let [c (in (state :code) i)]]

       [border {:bg :black
                :color (if (= i (state :selected))
                         :red
                         :blank)}
        (code-block state c i)])]
   [:row {}
    [button
     {:on-click (fn [_] (delete-selected state))
      :label "DEL"}]]])

(defn init
  []
  (e/put! s/editor-state :other [component root-state]))

(when (dyn :freja/loading-file)
  (init))
