# Prolog Graph Coloring
## User Documentation
##### František Szczepanik, MFF UK, Non-procedural programming


### Overview
This is a Prolog program that calculates the minimal vertex coloring of a given undirected graph. It reads a graph from a file, processes it to find a coloring with size equal to the chromatic number of that graph, and writes the coloring on the output.

The minimal coloring is found by iteratively trying colorings from a lower to an upper bound. The upper bound is trivial and equals the number of vertices of the graph (but because we are iterating from the bottom, we will never reach it). The lower bound is calculated by finding a Max Clique of the given graph (see the [wiki coloring page](https://en.wikipedia.org/wiki/Graph_coloring#Chromatic_number) for more details on why that works).

### Running the program
The ``main`` predicate is the entry point of the program. Run it with with the filename containing the graph and the minimal coloring will be presented on the output. ``main('peterson.txt')`` calculates and outputs the coloring of a Peterson Graph.

### Graph Format
The graphs are represented by a list of edges. We assume the graph is connected - disconnected graphs are not too interesting from the point of view of coloring. For example, to represent a triangle, we would describe putting the following facts in an input file: ``edge(a, b). edge(a, c). edge(b, c).``


### Testing data
There are several files containing some testing graphs. To run the program, run the command main('filename.txt').
Testing graphs:

- ``bipartite.txt``: contains a bipartite graph with partite sizes 10 and 12. Remember that the chromatic number of every bipartite graph is 2.
- ``k15.txt``: contains a complete graph on 15 vertices. Its chromatic number is 15.
- ``random100_500``: contains an Erdős–Rényi G(100, 500) random graph on 100 vertices and 500 edges.
- ``peterson.txt``: contains the Peterson graph with chromatic number 3.


### Visualizing the output with Python
To visualize the coloring and make sure it is correct, you can run the Python utility ``paint.py`` that plots the colored graph. It uses the libraries ``networkx`` and ``matplotlib`` and is run via the command line. The file with edges is its first argument, the coloring from prolog its second argument.

Examplary usage: ``./paint.py peterson.txt [v0-1,v1-2,v2-1,v3-2,v4-3,v5-2,v6-1,v7-3,v8-3,v9-2]``


![A Colored Peterson Graph](https://github.com/szczepaf/Prolog-Graph-Coloring/assets/83585883/338af225-5025-46f1-bb21-05553b0d00f8)
