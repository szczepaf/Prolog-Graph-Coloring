#!/usr/bin/env python

import matplotlib.pyplot as plt
import networkx as nx
import sys

def parse_coloring_argument(arg):
    cleared = arg.replace("[","").replace("]","")
    pairs = cleared.split(',')
    coloring = []
    for pair in pairs:
        vertex, color = pair.split('-')
        coloring.append((vertex, int(color)))
    return coloring

def read_graph_from_file(filename):
    """
    File format expected: edge(vX, vY). per line
    """
    G = nx.Graph()
    with open(filename, 'r') as file:
        for line in file:
            if line.startswith('edge'):
                line = line.strip().strip('.').replace('edge(', '').replace(')', '')
                u, v = line.split(', ')
                G.add_edge(u.strip(), v.strip())
    return G

def apply_coloring(G, coloring):
    for vertex, color in coloring:
        if vertex in G.nodes():
            G.nodes[vertex]['color'] = color

def draw_graph(G):
    colors = [G.nodes[node]['color'] if 'color' in G.nodes[node] else 1 for node in G]  # Default color if not found
    pos = nx.spring_layout(G)  # positions for all nodes
    nx.draw(G, pos, node_color=colors, with_labels=True, cmap=plt.cm.viridis, node_size=500)
    plt.show()

def main():
    if len(sys.argv) != 3:
        print("Usage: python plot_graph.py 'v0-1,v1-2,...' edges.txt")
        return
    coloring = parse_coloring_argument(sys.argv[2])
    G = read_graph_from_file(sys.argv[1])
    apply_coloring(G, coloring)
    
    draw_graph(G)

if __name__ == '__main__':
    main()
