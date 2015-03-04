In this little project, I attempted to write a solver for James Burton's puzzle game Stardust_. I made some progress framing it as a problem in classical planning and using `Fast Downward`_. I eventually concluded that the game is too hard to solve with a general-purpose planner, or with a simple purpose-written algorithm like A* in state space using the Manhattan distance from the exit as the A* heuristic. A more sophisticated and specialized approach seems necessary, like the techniques for Sokoban described in

    Virkkala, T. (2011). *Solving Sokoban* (master's thesis). University of Helsinki. Retrieved from http://weetu.net/Timo-Virkkala-Solving-Sokoban-Masters-Thesis.pdf

and that goes beyond my interest in this problem, so I'm stopping here for now.

As it stands, the solver can solve levels 1 through 6 within a few seconds each, but can't do level 7 nor ``t-07-simple`` given hours, although it can do ``t-07-simpler`` in 12 seconds.

To run the parsing and formatting program ``stardust.hy``, you'll need Hy_, enum34, ansicolor, and Kodhy_.

To solve the levels, you'll need `Fast Downward`_, which you should put a symlink to in the root of this repository.

License
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

``level-format-guide.txt`` and the levels ``01`` through ``50`` in the ``levels`` directory are copyright 1995 James Burton, if such things can be copyrighted (I am not a lawyer and am unsure on this point). They're stripped from the resource fork of the original game, Stardust, which is proprietary freeware.

To the rest of the files in this repository, the following license applies:

This program is copyright 2015 Kodi Arfer.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the `GNU General Public License`_ for more details.

.. _`GNU General Public License`: http://www.gnu.org/licenses/
.. _Stardust: http://macintoshgarden.org/games/stardust
.. _`Fast Downward`: http://www.fast-downward.org
.. _Hy: http://hylang.org
.. _Kodhy: https://github.com/Kodiologist/Kodhy
