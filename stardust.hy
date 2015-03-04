; -*- Hy -*-

(require kodhy.macros)
(import
  [hy [HySymbol HyKeyword]]
  sys re
  [copy [deepcopy]]
  [enum [Enum]]
  ansicolor
  [kodhy.util [show-expr keyword->str]])

(setv B (Enum "B" [
  (, "void" "0")
  (, "blue_magic" "1")
    ; We represent blue magic and multicolored star walls
    ; identically, since they behave the same.
  (, "gray" "2")
  (, "start" "3")
  (, "exit" "4")
  (, "teleporter" "5")
  (, "heat" "6")
  (, "star" "7")
  (, "platform" "8")
  (, "green_magic" "G")]))

(setv block-symbol {
  B.void " "
  B.blue-magic (kwc ansicolor.blue " " :+reverse)
  B.green-magic (kwc ansicolor.green " " :+reverse)
  B.gray (kwc ansicolor.black " " :+reverse)
  B.start "^"
  B.exit ">"
  B.teleporter "?"
  B.heat "~"
  B.star "*"
  B.platform "^"})
(setv player-symbol (kwc ansicolor.yellow "@" :+reverse))

(defn read-level [path]
  (amap (amap (B it) it)
    (.split (with [[o (open path)]] (o.read)) "\n")))

(defn read-plan [path]
  (amap (HyKeyword (+ ":" it))
  (re.findall "(?<=\()[-a-z]+"
  (re.sub ";.*" ""
  (with [[o (open path)]] (o.read))))))

(defn print-level [level &optional player-x player-y]
  (for [[y row] (enumerate level)]
    (print (.join "" (lc [[x b] (enumerate row)]
      (if (and (not (none? player-x)) (not (none? player-y))
          (= x player-x) (= y player-y))
        player-symbol
        (get block-symbol b)))))))

(defn print-plan [level plan]
  (setv start-xy (first
    (lc [[y row] (enumerate level) [x b] (enumerate row)]
      (= b B.start)
      [x y])))
  (setv [px py] start-xy)
  (setv level (deepcopy level))
  (defn setp [x y b]
    (setv (get level y x) b))
  (for [[action-i action] (enumerate plan)]
    (cond

      [(= action :fall-normal)
        (+= py 1)]
      [(= action :walk-left)
        (-= px 1)]
      [(= action :walk-right)
        (+= px 1)]

      [(in action [:fall-oob :fall-into-teleporter])
        (setv [px py] start-xy)]

      [(= action :magic-blue-left)
        (setp (dec px) py B.blue-magic)]
      [(= action :dispel-left)
        (setp (dec px) py B.void)]
      [(= action :magic-blue-lowerleft)
        (setp (dec px) (inc py) B.blue-magic)]
      [(= action :dispel-lowerleft)
        (setp (dec px) (inc py) B.void)]

      [(= action :magic-blue-right)
        (setp (inc px) py B.blue-magic)]
      [(= action :dispel-right)
        (setp (inc px) py B.void)]
      [(= action :magic-blue-lowerright)
        (setp (inc px) (inc py) B.blue-magic)]
      [(= action :dispel-lowerright)
        (setp (inc px) (inc py) B.void)]

      [(= action :dispel-up-green)
        (setp px (dec py) B.void)]
      [(= action :dispel-down-green)
        (setp px (inc py) B.void)]

      [(= action :magic-levitate) (do
        (setp px py B.green-magic)
        (-= py 1))]

      [(= action :use-exit)
        None]
      [True
        (raise (ValueError action))])
    (print (.format "Action {}: {}" action-i (keyword->str action)))
    (print-level level px py)
    (print (* "-" 50))))

(defn pos [x y]
  (HySymbol (.format "pos-{}-{}" x y)))

(defn underscores-to-hyphens [x] (cond
  [(instance? HySymbol x)
    (HySymbol (.replace (str x) "_" "-"))]
  [(instance? tuple x)
    (tuple (map underscores-to-hyphens x))]
  [(coll? x) (do
    (for [i (range (len x))]
      (setv (get x i) (underscores-to-hyphens (get x i))))
    x)]
  [True
    x]))

(defn level-to-pddl [level]
  (defmacro level-loop [&optional [condition 'True] [expr '(pos x y)]]
    `(lc
      [[y row] (enumerate level) [x b] (enumerate row)]
      ~condition
      ~expr))
  (underscores-to-hyphens `(define (problem stardust-level)

    (:domain stardust)

    (:objects

      ~@(level-loop) - position)

    (:init

      ~@(level-loop
        (< x (dec (len row)))
        `(leftright ~(pos x y) ~(pos (inc x) y)))
      ~@(level-loop
        (< y (dec (len level)))
        `(abovebelow ~(pos x y) ~(pos x (inc y))))
      ~@(level-loop
        (= y (dec (len level)))
        `(bottom-row ~(pos x y)))

      (player-at ~@(level-loop (= b B.start)))
      (start-at ~@(level-loop (= b B.start)))

      ~@(level-loop
        (= b B.exit)
        `(exit-at ~(pos x y)))
      ~@(level-loop
        (= b B.void)
        `(void-at ~(pos x y)))
      ~@(level-loop
        (= b B.blue-magic)
        `(blue-magic-at ~(pos x y)))
      ~@(level-loop
        (= b B.teleporter)
        `(teleporter-at ~(pos x y)))
      ~@(level-loop
        (in b [B.void B.start B.exit B.star])
        `(passable ~(pos x y)))
      ~@(level-loop
        (in b [B.blue-magic B.gray B.platform])
        `(solid ~(pos x y))))

   (:goal (won)))))

(when (= __name__ "__main__")
  (setv mode (second sys.argv))
  (cond
    [(= mode "print-level") (do
      (setv path (get sys.argv 2))
      (print-level (read-level path)))]
    [(= mode "level-to-pddl") (do
      (setv path (get sys.argv 2))
      (print (show-expr (level-to-pddl (read-level path)))))]
    [(= mode "print-plan") (do
      (setv [_ _ level-path plan-path] sys.argv)
      (print-plan (read-level level-path) (read-plan plan-path)))]
    [True
      (raise ValueError)]))
