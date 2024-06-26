# Prolog graph coloring
## Technical Documentation
##### František Szczepanik, MFF UK, Non-procedural programming


### Overview
This is a Prolog program that calculates the minial vertex coloring of a given undirected graph. It reads a graph from a file, processes it to find any one coloring with size equal to the chromatic number of that graph, and writes the coloring on the output.

The minimal coloring is found by iteratively trying colorings from a lower to an upper bound. The upper bound is trivial and equals the number of vertices of the graph (but because we are iterating from the bottom, we will never reach it). The lower bound is calculated by finding a Max Clique of the given graph (see the [wiki coloring page](https://en.wikipedia.org/wiki/Graph_coloring#Chromatic_number) for more details on why that works).

### Dependencies
The [clpfd](https://www.swi-prolog.org/man/clpfd.html) Constraint Logic Programming library is utilized for creating contstraints on the colors of vertices and iterating over the solution space to find a coloring satisfying the constraints.

### Description of important predicates
In this section, the important predicates are briefly described. For more details, refer to the comments in code.

- ``main(Filename)``: This is entry point of the program, that recieves the name of the file with the graph, reads the facts describing the graph, calculates the coloring, and writes it on the standard output.
- ``colorGraph``: Find the Maximum Clique in the graph, then tries to find colorings of size (MaxCliqueSize, N), where N is the number of Vertices of the Graph. Once it succeeds, it presents the coloring in a readable format.
- ``maxClique``: Finds the Maximum Clique in a given Graph. It works by trying to find a Max Clique starting from every Vertex and only extending the Clique when the newly added candidate still forms a Clique with the rest of the current Clique, i.e. it is connected to the rest of the current Clique. This solution was considerably faster than a naive solution that tried all subsets of a list, filtered them to find all Cliques and outputted the longest one.

### Graph Format
The graps are represented by a list of edges. We assume the graph is connected - unconnected graphs are not too interesting from the point of view of coloring. E.g., to represent a triangle, we would describe it the following way: ``edge(a, b). edge(a, c). edge(b, c).``

#### Output Format
The solution is presented in an list, where each vertex is associated with its color. Colors are denoted as numbers, going from 1 up. A solution describing a 3-coloring of a [Peterson Graph](https://en.wikipedia.org/wiki/Petersen_graph) with vertices ``v0`` to ``v9`` looks like this: ``[v0-1,v1-2,v2-1,v3-2,v4-3,v5-2,v6-1,v7-3,v8-3,v9-2]``.

### Testing data
There are several files containing some testing graphs. To run the program, run the command main('filename.txt').
Testing graphs:

- ``bipartite.txt``: contains a bipartite graph with partite sizes 10 and 12. Remember that the chromatic number of every bipartite graph is 2.
- ``k15.txt``: contains a complete graph on 15 vertices. Its chromatic number is 15.
- ``random100_500``: contains an Erdős–Rényi G(100, 500) random graph on 100 vertices and 500 edges.
- ``peterson.txt``: contains the Peterson graph with chromatic number 3.



### Presenting the output with Python
To visualize the coloring and make sure it is correct, you can run the Python utility ``paint.py`` that plots the colored graph. It uses the libraries ``networkx`` and ``matplotlib`` and is run via the command line. The file with edges is its first argument, the coloring from prolog its second argument.

Examplary usage: ``./paint.py peterson.txt [v0-1,v1-2,v2-1,v3-2,v4-3,v5-2,v6-1,v7-3,v8-3,v9-2]``


![A Colored Peterson Graph](https://github.com/szczepaf/Prolog-Graph-Coloring/assets/83585883/338af225-5025-46f1-bb21-05553b0d00f8)

###### Contact address: szczjr@gmail.com
