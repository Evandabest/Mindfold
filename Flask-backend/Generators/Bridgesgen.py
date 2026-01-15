from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple, Set
import random

# ============================
# Bridges (Hashiwokakero) generator
# ============================
# This game is the classic "Bridges" / Hashiwokakero:
# - Nodes (dots) sit on grid intersections and have a required degree (number).
# - You can connect two nodes that share a row/col with no other node between them.
# - Each connection can be single or double (0,1,2).
# - Bridges cannot cross.
# - Final graph must be connected.
#
# This file generates a VALID puzzle instance by:
# 1) Randomly placing nodes on a rows x cols lattice of points
# 2) Building a connected, non-crossing solution network (single/double edges)
# 3) Setting each node number = sum of incident edge multiplicities
#
# Output:
# - puzzle nodes with their required degrees
# - solution edges (for validation/debug; you can omit in production)


Coord = Tuple[int, int]          # (r, c) on lattice points
Edge = Tuple[int, int]           # (u, v) node indices (u < v)


@dataclass(frozen=True)
class AtomNode:
    r: int
    c: int
    degree: int                  # number shown in the circle


@dataclass(frozen=True)
class AtomEdge:
    u: int
    v: int
    count: int                   # 1 or 2


@dataclass(frozen=True)
class BridgesPuzzle:
    rows: int                    # number of lattice rows (points)
    cols: int                    # number of lattice cols (points)
    nodes: List[AtomNode]        # node positions + degrees
    solution_edges: List[AtomEdge]


# ----------------------------
# Union-Find for connectivity construction
# ----------------------------
class DSU:
    def __init__(self, n: int):
        self.p = list(range(n))
        self.r = [0] * n
        self.count = n

    def find(self, x: int) -> int:
        while self.p[x] != x:
            self.p[x] = self.p[self.p[x]]
            x = self.p[x]
        return x

    def union(self, a: int, b: int) -> bool:
        ra, rb = self.find(a), self.find(b)
        if ra == rb:
            return False
        if self.r[ra] < self.r[rb]:
            ra, rb = rb, ra
        self.p[rb] = ra
        if self.r[ra] == self.r[rb]:
            self.r[ra] += 1
        self.count -= 1
        return True


# ----------------------------
# Geometry helpers: crossing detection
# ----------------------------
def _cells_for_edge(a: Coord, b: Coord) -> Tuple[str, List[Tuple[int, int]]]:
    """
    Represent an edge as a list of occupied "unit cells" to detect crossings.

    If a and b are on same row r:
      occupies horizontal cells (r, k) for k in [min_c, max_c-1]
    If on same col c:
      occupies vertical cells (k, c) for k in [min_r, max_r-1]
    """
    (r1, c1), (r2, c2) = a, b
    if r1 == r2:
        r = r1
        lo, hi = sorted((c1, c2))
        return ("H", [(r, k) for k in range(lo, hi)])
    if c1 == c2:
        c = c1
        lo, hi = sorted((r1, r2))
        return ("V", [(k, c) for k in range(lo, hi)])
    raise ValueError("edge must be axis-aligned")


def _would_cross(
    a: Coord,
    b: Coord,
    occupied_h: Set[Tuple[int, int]],
    occupied_v: Set[Tuple[int, int]],
) -> bool:
    """
    Crossing happens if any horizontal unit cell overlaps any vertical unit cell
    at the same (r, c) coordinate.
    """
    orient, cells = _cells_for_edge(a, b)
    if orient == "H":
        return any(cell in occupied_v for cell in cells)
    else:
        return any(cell in occupied_h for cell in cells)


def _mark_edge_cells(
    a: Coord,
    b: Coord,
    occupied_h: Set[Tuple[int, int]],
    occupied_v: Set[Tuple[int, int]],
) -> None:
    orient, cells = _cells_for_edge(a, b)
    if orient == "H":
        occupied_h.update(cells)
    else:
        occupied_v.update(cells)


# ----------------------------
# Visibility: candidate connections
# ----------------------------
def _build_visibility_edges(points: List[Coord]) -> List[Tuple[int, int]]:
    """
    Returns all pairs (u,v) that can be connected:
    - share a row or col
    - no other node between them on that line
    """
    n = len(points)
    by_row: Dict[int, List[Tuple[int, int]]] = {}
    by_col: Dict[int, List[Tuple[int, int]]] = {}

    for i, (r, c) in enumerate(points):
        by_row.setdefault(r, []).append((c, i))
        by_col.setdefault(c, []).append((r, i))

    edges: List[Tuple[int, int]] = []

    # adjacent along sorted row list
    for r, lst in by_row.items():
        lst.sort()
        for k in range(len(lst) - 1):
            _, u = lst[k]
            _, v = lst[k + 1]
            edges.append((min(u, v), max(u, v)))

    # adjacent along sorted col list
    for c, lst in by_col.items():
        lst.sort()
        for k in range(len(lst) - 1):
            _, u = lst[k]
            _, v = lst[k + 1]
            edges.append((min(u, v), max(u, v)))

    # dedupe
    return sorted(set(edges))


# ----------------------------
# Main generator
# ----------------------------
def generate_atoms(
    rows: int,
    cols: int,
    *,
    num_nodes: int = 14,
    extra_edge_factor: float = 0.35,   # how many extra edges beyond a tree
    double_edge_chance: float = 0.30,  # chance to make a chosen edge a double bridge
    seed: Optional[int] = None,
    max_tries: int = 500,
) -> BridgesPuzzle:
    """
    Generate a valid Bridges/Hashiwokakero puzzle.

    Params:
      rows, cols: lattice size (points). e.g., 9x9
      num_nodes: number of dots placed
      extra_edge_factor:
          after building a spanning tree (n-1 edges),
          try adding about extra_edge_factor*(n-1) more edges.
      double_edge_chance:
          when adding an edge, chance to set multiplicity 2 (otherwise 1),
          subject to max multiplicity 2.
    """
    if rows < 2 or cols < 2:
        raise ValueError("rows and cols must be >= 2 (lattice points).")
    if num_nodes < 2 or num_nodes > rows * cols:
        raise ValueError("num_nodes must be between 2 and rows*cols.")
    if not (0.0 <= extra_edge_factor <= 2.0):
        raise ValueError("extra_edge_factor out of range.")
    if not (0.0 <= double_edge_chance <= 1.0):
        raise ValueError("double_edge_chance out of range.")

    rng = random.Random(seed)

    def try_once() -> Optional[BridgesPuzzle]:
        # 1) Place nodes
        all_points = [(r, c) for r in range(rows) for c in range(cols)]
        rng.shuffle(all_points)
        points = all_points[:num_nodes]

        # (Optional) spread out a bit by rejecting too-clustered layouts
        # (kept simple; you can remove if you want)
        points_set = set(points)

        # 2) Build visibility graph
        vis_edges = _build_visibility_edges(points)
        if len(vis_edges) < num_nodes - 1:
            return None

        # 3) Build a non-crossing connected solution:
        #    First: spanning tree (connect everything) with no crossings
        dsu = DSU(num_nodes)
        edge_mult: Dict[Edge, int] = {}

        occupied_h: Set[Tuple[int, int]] = set()
        occupied_v: Set[Tuple[int, int]] = set()

        shuffled = vis_edges[:]
        rng.shuffle(shuffled)

        for (u, v) in shuffled:
            if dsu.count == 1:
                break
            if dsu.find(u) == dsu.find(v):
                continue
            a, b = points[u], points[v]
            if _would_cross(a, b, occupied_h, occupied_v):
                continue

            # add edge multiplicity 1 in tree phase
            edge_mult[(u, v)] = 1
            _mark_edge_cells(a, b, occupied_h, occupied_v)
            dsu.union(u, v)

        if dsu.count != 1:
            return None

        # 4) Add extra edges (still no crossings), and sometimes make them double
        target_extra = int(round(extra_edge_factor * (num_nodes - 1)))
        candidates = vis_edges[:]
        rng.shuffle(candidates)

        def current_mult(u: int, v: int) -> int:
            key = (u, v) if u < v else (v, u)
            return edge_mult.get(key, 0)

        added = 0
        for (u, v) in candidates:
            if added >= target_extra:
                break
            a, b = points[u], points[v]

            m = current_mult(u, v)
            if m >= 2:
                continue

            # if edge doesn't exist yet, must not cross
            if m == 0 and _would_cross(a, b, occupied_h, occupied_v):
                continue

            # choose to add 1 or 2, but cap at 2 total
            inc = 2 if (rng.random() < double_edge_chance) else 1
            inc = min(inc, 2 - m)
            if inc <= 0:
                continue

            key = (u, v) if u < v else (v, u)
            edge_mult[key] = m + inc

            # mark occupancy only the first time edge is introduced
            if m == 0:
                _mark_edge_cells(a, b, occupied_h, occupied_v)

            added += 1

        # 5) Compute degrees (numbers on nodes)
        degrees = [0] * num_nodes
        sol_edges: List[AtomEdge] = []
        for (u, v), cnt in edge_mult.items():
            degrees[u] += cnt
            degrees[v] += cnt
            sol_edges.append(AtomEdge(u=u, v=v, count=cnt))

        # sanity: no isolated nodes, degrees within typical puzzle range
        if any(d == 0 for d in degrees):
            return None
        if any(d > 8 for d in degrees):  # you can relax this if you want bigger degrees
            return None

        nodes = [AtomNode(r=points[i][0], c=points[i][1], degree=degrees[i]) for i in range(num_nodes)]
        sol_edges.sort(key=lambda e: (e.u, e.v))

        return BridgesPuzzle(rows=rows, cols=cols, nodes=nodes, solution_edges=sol_edges)

    for _ in range(max_tries):
        p = try_once()
        if p is not None:
            return p

    raise RuntimeError("Failed to generate Bridges puzzle; try different seed/params.")


# ----------------------------
# Example usage / debug printing
# ----------------------------
def print_bridges(p: BridgesPuzzle) -> None:
    """
    Prints a simple textual view:
    - '.' empty intersection
    - numbers where nodes are
    """
    grid = [["." for _ in range(p.cols)] for _ in range(p.rows)]
    for n in p.nodes:
        grid[n.r][n.c] = str(n.degree)

    for r in range(p.rows):
        print(" ".join(x.rjust(2) for x in grid[r]))

    print("\nSolution edges (u,v,count):")
    for e in p.solution_edges:
        print(e.u, e.v, e.count)


if __name__ == "__main__":
    puzzle = generate_atoms(
        rows=9, cols=9,
        num_nodes=16,
        extra_edge_factor=0.40,
        double_edge_chance=0.35,
        seed=15,
    )
    print_bridges(puzzle)
