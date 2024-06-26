:- use_module(library(clpfd)).
:- dynamic edge/2.

% Clear all dynamically added edges
clearEdges :- retractall(edge(_, _)).


%%%%% HELPER GRAPH AND LIST PREDICATES %%%%%

% extractVertices(+Edges, -Vertices) :- Extracts all Vertices from Edges.
% Coloring of unconnected graphs is not too interesting, so we assume connectivity.
% Therefore an representation with the edge predicate suffices.
extractVertices(Edges, Vertices) :-
    findall(Vertex,
           (member(edge(X, Y), Edges), (Vertex = X; Vertex = Y)),
           VerticesDup),

    sort(VerticesDup, Vertices).

% pairVerticesWithColors(+Vertices, +Colors, -PresentableSolution) :- Zips each vertex with its assigned color to present on the output.
pairVerticesWithColors([], [], []).
pairVerticesWithColors([V|VR], [C|CR], [V-C|Z]) :-
    pairVerticesWithColors(VR, CR, Z).


% allConnected(+V) :- Checks if all pairs of vertices in a given list of
% vertices are connected. Succeeds if they are.
allConnected([]).
allConnected([V|Vs]) :-
    vertexIsConnectedToAll(V, Vs),
    allConnected(Vs).

% vertexIsConnectedToAll(+Vertex, +Vertices) :- Checks if vertex V is
% connected to all Vertices in the list.
vertexIsConnectedToAll(_, []).
vertexIsConnectedToAll(V, [V1|Rest]) :-
    (   edge(V, V1); edge(V1, V)   ),
    vertexIsConnectedToAll(V, Rest).


% Read predicates from a file and assert them.
readPredicates(Stream) :-
    read(Stream, Term),
    (   Term == end_of_file -> true; % EOF reached.
        assert(Term),
        readPredicates(Stream) % Else continue reading.
    ).

%%%%%%%% COLORING CODE %%%%%%%%%%%%%%



% setupColorsOfVertices(+MaxColors, -ColorVars) :- Setup color variables for given maximum number of colors
%(ins is a clpfd predicate which sets domains to variables).
setupColorsOfVertices(MaxColors, ColorVars) :-
    length(ColorVars, MaxColors),
    ColorVars ins 1..MaxColors.

% apply_constraint(+ColorVars, +Vertices, +edge(E)) :- Applies the
% different-color constraint to a given edge.
applyConstraint(ColorVars, Vertices, edge(V1, V2)) :-
    nth1(Index1, Vertices, V1),
    nth1(Index2, Vertices, V2),
    element(Index1, ColorVars, Color1),
    element(Index2, ColorVars, Color2),
    Color1 #\= Color2.

% apply_constraints(+Edges, +ColorVars, +Vertices) :- Apply the constraint for every edge.
applyConstraints(Edges, ColorVars, Vertices) :-
    maplist(applyConstraint(ColorVars, Vertices), Edges).


% findColoring(+Vertices, +Edges, +MinColors, +MaxColors, -Solution) :- Attempts to color the graph with an increasing number of colors from MinColors to MaxColors.
% If it succeeds, it outputs the solution in -Solution.

findColoring(Vertices, Edges, MinColors, MaxColors, Solution) :-
    between(MinColors, MaxColors, CurrentMaxColor), % Try colors from bottom up.
    setupColorsOfVertices(CurrentMaxColor, ColorVars), % Instantiate domains
    applyConstraints(Edges, ColorVars, Vertices), % Create clpfd contraints
    (   labeling([], ColorVars) -> % labeling iterates over the possible combinations and assign colors to vertices along the constraints.
        pairVerticesWithColors(Vertices, ColorVars, Solution) ;
        false
    ).

% The predicate to color the graph.
% colorGraph(-Solution) :- Solution is the coloring of the graph
% represented by edges.
colorGraph(Solution) :-
    findall(edge(X, Y), edge(X, Y), Edges),
    extractVertices(Edges, Vertices),

    length(Vertices, MaxColors), % Gets the upper and lower bound on the chromatic number.
    maxClique(Edges,  MaxClique),
    length(MaxClique, MinColor),

    findColoring(Vertices, Edges, MinColor, MaxColors, Solution), % Tries to find colorings with increasing size.
    !.

%%%%%%%%%%%% MAIN %%%%%%%%%%%%%
%
% The driver predicate that reads the edge facts from a input file,
% colors the graph and writes out the solution
main(Filename) :-
    clearEdges,
    open(Filename, read, Stream),  % Open file in read mode, create a File Stream.
    readPredicates(Stream),  % Read and assert the edges from the file.
    close(Stream),  % Close the Stream.

    colorGraph(Solution),  % Find the coloring
    write(Solution).  % Output the solution.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%% MAX CLIQUE PREDICATES %%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Branch and bound to find the maximum clique.
%
% No other candidates were found, this is the maximal current clique
% found. If it is better than the best so far, return it in the
% ResultClique.
extendClique(CurrentClique, [], MaxClique, ResultClique) :-
    length(CurrentClique, Len),
    length(MaxClique, MaxLen),
    (   Len > MaxLen
        ->  ResultClique = CurrentClique
        ;   ResultClique = MaxClique
    ).
% Recursively call with new candidates, also call without adding it.
extendClique(CurrentClique, [Candidate|Rest], MaxClique, ResultClique) :-
    (   allConnected([Candidate|CurrentClique]) % check if adding the candidate still forms a clique
        -> extendClique([Candidate|CurrentClique], Rest, MaxClique, NewClique)
        ; NewClique = MaxClique
        ),
        extendClique(CurrentClique, Rest, NewClique, ResultClique). % continue without V

% finds_maximum_clique(+VerticesFinds):- finds the maximum clique
% starting from each vertex.
findMaxClique(Vertices, MaxClique) :-
    foldl(checkCliqueFromVertex, Vertices, [], MaxClique).

% Wrapper for Extend Clique
checkCliqueFromVertex(Vertex, CurrentMax, NewMax) :-
    findall(V, (edge(Vertex, V); edge(V, Vertex)), Neighbors),
    extendClique([Vertex], Neighbors, CurrentMax, NewMax).

% We will use the size of the Max Clique as a lower bound for graph coloring.
% maxClique(+Edges, -MaxClique) :- MaxClique is the Maximum Clique in the graph represented by Edges.
% It works by starting from every vertex and extending only by vertices
% that form a clique with the rest of the current clique.
maxClique(Edges, MaxClique) :-
    extractVertices(Edges, Vertices),
    findMaxClique(Vertices, MaxClique).

