#!/bin/sh

hy ../stardust.hy level-to-pddl "$1" >level.pddl && \
python ../downward/src/fast-downward.py \
    ../domain.pddl level.pddl \
    --heuristic "hff=ff()" \
    --search "lazy_greedy(hff, preferred=hff)" && \
hy ../stardust.hy print-plan "$1" sas_plan >plan.txt

# hy ../stardust.hy level-to-pddl "$1" >level.pddl && \
# python ../downward/src/fast-downward.py \
#     ../domain.pddl level.pddl \
#     --heuristic "hcea=cea()" \
#     --search "lazy_greedy(hcea, preferred=hcea)" && \
# hy ../stardust.hy print-plan "$1" sas_plan >plan.txt

# hy ../stardust.hy level-to-pddl "$1" >level.pddl && \
# python ../downward/src/fast-downward.py \
#     ../domain.pddl level.pddl \
#     --heuristic "hff=ff()" --heuristic "hcea=cea()" \
#     --search "lazy_greedy([hff, hcea], preferred=[hff, hcea])" && \
# hy ../stardust.hy print-plan "$1" sas_plan >plan.txt

# hy ../stardust.hy level-to-pddl "$1" >level.pddl && \
# python ../downward/src/fast-downward.py \
#     ../domain.pddl level.pddl --search 'astar(ipdb())' && \
# hy ../stardust.hy print-plan "$1" sas_plan >plan.txt
