; -*- Lisp -*-

(define (domain stardust)

(:requirements :typing)

(:types
  position - object)

(:predicates

  (player-at ?l - position)

  (abovebelow ?upper ?lower - position)
  (leftright ?left ?right - position)
  (bottom-row ?pos - position)

  (void-at ?l - position)
  (blue-magic-at ?l - position)
  (start-at ?l - position)
  (exit-at ?l - position)
  (teleporter-at ?l - position)
  (green-magic-at ?l - position)

  (passable ?l - position)
  (solid ?l - position)

  (won))

(:action fall-normal
  ; Fall one square downwards.
  :parameters (
    ?from ?to - position)
  :precondition (and
    (player-at ?from)
    (passable ?to)
    (abovebelow ?from ?to))
  :effect (and
    (not (player-at ?from))
    (player-at ?to)))

(:action fall-oob
  ; Fall out of bounds, teleporting back to the start.
  :parameters (
    ?ppos ?spos - position)
  :precondition (and
    (bottom-row ?ppos)
    (player-at ?ppos)
    (start-at ?spos))
  :effect (and
    (not (player-at ?ppos))
    (player-at ?spos)))

(:action fall-into-teleporter
  :parameters (
    ?from ?to ?spos - position)
  :precondition (and
    (player-at ?from)
    (teleporter-at ?to)
    (abovebelow ?from ?to)
    (start-at ?spos))
  :effect (and
    (not (player-at ?ppos))
    (player-at ?spos)))

(:action walk-left
  :parameters (
    ?from ?to ?floor - position)
  :precondition (and
    (player-at ?from)
    (passable ?to)
    (leftright ?to ?from)
    (abovebelow ?from ?floor)
    (solid ?floor))
  :effect (and
    (not (player-at ?from))
    (player-at ?to)))

(:action walk-right
  :parameters (
    ?from ?to ?floor - position)
  :precondition (and
    (player-at ?from)
    (passable ?to)
    (leftright ?from ?to)
    (abovebelow ?from ?floor)
    (solid ?floor))
  :effect (and
    (not (player-at ?from))
    (player-at ?to)))

(:action use-exit
  :parameters (
    ?epos ?floor - position)
  :precondition (and
    (exit-at ?epos)
    (player-at ?epos)
    (abovebelow ?epos ?floor)
    (solid ?floor))
  :effect
    (won))

(:action magic-blue-left
  :parameters (
    ?ppos ?target ?floor - position)
  :precondition (and
    (player-at ?ppos)
    (void-at ?target)
    (leftright ?target ?ppos)
    (abovebelow ?ppos ?floor)
    (solid ?floor))
  :effect (and
    (blue-magic-at ?target)
    (not (void-at ?target))
    (not (passable ?target))
    (solid ?target)))

(:action magic-blue-right
  :parameters (
    ?ppos ?target ?floor - position)
  :precondition (and
    (player-at ?ppos)
    (void-at ?target)
    (leftright ?ppos ?target)
    (abovebelow ?ppos ?floor)
    (solid ?floor))
  :effect (and
    (blue-magic-at ?target)
    (not (void-at ?target))
    (not (passable ?target))
    (solid ?target)))

(:action magic-blue-lowerleft
  :parameters (
    ?ppos ?target ?intermediate ?floor - position)
  :precondition (and
    (player-at ?ppos)
    (void-at ?target)
    (leftright ?intermediate ?ppos)
    (abovebelow ?intermediate ?target)
    (abovebelow ?ppos ?floor)
    (solid ?floor)
    (not (green-magic-at ?floor)))
  :effect (and
    (blue-magic-at ?target)
    (not (void-at ?target))
    (not (passable ?target))
    (solid ?target)))

(:action magic-blue-lowerright
  :parameters (
    ?ppos ?target ?intermediate ?floor - position)
  :precondition (and
    (player-at ?ppos)
    (void-at ?target)
    (leftright ?ppos ?intermediate)
    (abovebelow ?intermediate ?target)
    (abovebelow ?ppos ?floor)
    (solid ?floor)
    (not (green-magic-at ?floor)))
  :effect (and
    (blue-magic-at ?target)
    (not (void-at ?target))
    (not (passable ?target))
    (solid ?target)))

(:action magic-levitate
  ; Create green magic at the current position, pushing the
  ; player upwards.
  :parameters (
    ?from ?to ?floor - position)
  :precondition (and
    (player-at ?from)
    (void-at ?from)
    (void-at ?to)
      ; The requirement for the *destination* to be void is not
      ; obvious, but it's clear when you try to levitate into the
      ; entrance or exit.
      ;
      ; BUG: You can also levitate into a star.
    (abovebelow ?to ?from)
    (abovebelow ?from ?floor)
    (solid ?floor)
    (not (green-magic-at ?floor)))
  :effect (and
    (not (player-at ?from))
    (not (void-at ?from))
    (green-magic-at ?from)
    (solid ?from)
    (not (passable ?from))
    (not (void-at ?from))
    (player-at ?to)))

(:action dispel-left
  :parameters (
    ?ppos ?target ?floor - position)
  :precondition (and
    (player-at ?ppos)
    (or (blue-magic-at ?target) (green-magic-at ?target) (teleporter-at ?target))
    (leftright ?target ?ppos)
    (abovebelow ?ppos ?floor)
    (solid ?floor))
  :effect (and
    (not (blue-magic-at ?target))
    (not (green-magic-at ?target))
    (not (teleporter-at ?target))
    (void-at ?target)
    (passable ?target)
    (not (solid ?target))))

(:action dispel-right
  :parameters (
    ?ppos ?target ?floor - position)
  :precondition (and
    (player-at ?ppos)
    (or (blue-magic-at ?target) (green-magic-at ?target) (teleporter-at ?target))
    (leftright ?ppos ?target)
    (abovebelow ?ppos ?floor)
    (solid ?floor))
  :effect (and
    (not (blue-magic-at ?target))
    (not (green-magic-at ?target))
    (not (teleporter-at ?target))
    (void-at ?target)
    (passable ?target)
    (not (solid ?target))))

(:action dispel-lowerleft
  :parameters (
    ?ppos ?target ?intermediate ?floor - position)
  :precondition (and
    (player-at ?ppos)
    (or (blue-magic-at ?target) (green-magic-at ?target))
    (leftright ?intermediate ?ppos)
    (abovebelow ?intermediate ?target)
    (abovebelow ?ppos ?floor)
    (solid ?floor)
    (not (green-magic-at ?floor)))
      ; While standing on green magic, downwards dispelling
      ; removes that, not magic to the lower left or lower right.
  :effect (and
    (not (blue-magic-at ?target))
    (not (green-magic-at ?target))
    (void-at ?target)
    (passable ?target)
    (not (solid ?target))))

(:action dispel-lowerright
  :parameters (
    ?ppos ?target ?intermediate ?floor - position)
  :precondition (and
    (player-at ?ppos)
    (or (blue-magic-at ?target) (green-magic-at ?target))
    (leftright ?ppos ?intermediate)
    (abovebelow ?intermediate ?target)
    (abovebelow ?ppos ?floor)
    (solid ?floor)
    (not (green-magic-at ?floor)))
      ; While standing on green magic, downwards dispelling
      ; removes that, not magic to the lower left or lower right.
  :effect (and
    (not (blue-magic-at ?target))
    (not (green-magic-at ?target))
    (void-at ?target)
    (passable ?target)
    (not (solid ?target))))

(:action dispel-down-green
  :parameters (
    ?ppos ?target - position)
  :precondition (and
    (player-at ?ppos)
    (green-magic-at ?target)
    (abovebelow ?ppos ?target))
  :effect (and
    (not (green-magic-at ?target))
    (void-at ?target)
    (passable ?target)
    (not (solid ?target))))

(:action dispel-up-green
  :parameters (
    ?ppos ?target ?floor - position)
  :precondition (and
    (player-at ?ppos)
    (green-magic-at ?target)
    (abovebelow ?target ?ppos)
    (abovebelow ?ppos ?floor)
    (solid ?floor))
  :effect (and
    (not (green-magic-at ?target))
    (void-at ?target)
    (passable ?target)
    (not (solid ?target))))

)
