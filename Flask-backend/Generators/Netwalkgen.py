from __future__ import annotations

from dataclasses import dataclass
from typing import List, Tuple, Optional, Set
import random
from collections import deque

# ============================
# Netwalk / Network generator
# with explicit Tile metadata
# ============================

# Direction bitmask constants (NESW)
N, E, S, W = 1, 2, 4, 8

# For building edges / traversal
DIRS = [
    (-1, 0, N, S),  # dr, dc, out_bit, in_bit
    (0, 1, E, W),
    (1, 0, S, N),
    (0, -1, W, E),
]

BIT_TO_NAME = {N: "N", E: "E", S: "S", W: "W"}
NAME_TO_BIT = {"N": N, "E": E, "S": S, "W": W}
OPPOSITE_NAME = {"N": "S", "E": "W", "S": "N", "W": "E"}


# ----------------------------
# Core Tile metadata model
# ----------------------------
@dataclass
class Tile:
    row: int
    col: int

    # current state (what the player sees / manipulates)
    mask: int              # NESW bitmask in current orientation
    rotation: int          # 0..3 number of CW rotations applied from solution

    # derived metadata from mask (cached for UI/logic)
    openings: Set[str]     # {"N","E","S","W"} subset
    degree: int            # len(openings)
    kind: str              # "end", "straight", "elbow", "tee", "cross"

    # gameplay / UI
    is_source: bool = False
    is_powered: bool = False


# ----------------------------
# Bitmask helpers
# ----------------------------
def rotate_mask(mask: int, k: int) -> int:
    """
    Rotate mask clockwise k times (k in {0,1,2,3}).
    N->E->S->W->N
    """
    k %= 4
    for _ in range(k):
        n = (mask & N) != 0
        e = (mask & E) != 0
        s = (mask & S) != 0
        w = (mask & W) != 0
        mask = 0
        if w: mask |= N
        if n: mask |= E
        if e: mask |= S
        if s: mask |= W
    return mask


def mask_to_openings(mask: int) -> Set[str]:
    return {name for bit, name in BIT_TO_NAME.items() if mask & bit}


def mask_degree(mask: int) -> int:
    return ((mask & N) != 0) + ((mask & E) != 0) + ((mask & S) != 0) + ((mask & W) != 0)


def mask_kind(mask: int) -> str:
    deg = mask_degree(mask)
    if deg == 1:
        return "end"
    if deg == 2:
        # Straight if opposite directions
        if (mask & N and mask & S) or (mask & E and mask & W):
            return "straight"
        return "elbow"
    if deg == 3:
        return "tee"
    if deg == 4:
        return "cross"
    return "empty"


# ----------------------------
# Generator: spanning tree network
# ----------------------------
def generate_network(
    rows: int,
    cols: int,
    *,
    seed: Optional[int] = None,
    allow_cross: bool = True,
    prefer_source_degree_at_least: int = 2,
) -> Tuple[List[List[int]], List[List[int]], List[List[int]], Tuple[int, int]]:
    """
    Generate a Netwalk-style puzzle using a spanning tree on a grid.

    Returns:
      puzzle_masks   : rows x cols masks (randomly rotated from solution)
      solution_masks : rows x cols masks (correct orientation)
      rotations      : rows x cols rotation counts (0..3) applied to solution -> puzzle
      source         : (sr, sc) selected source/server cell

    Guarantees about solution network:
      - Single connected component
      - No cycles (tree)
    """
    if rows <= 0 or cols <= 0:
        raise ValueError("rows/cols must be positive.")
    rng = random.Random(seed)

    # 1) Build a spanning tree via randomized DFS
    solution = [[0 for _ in range(cols)] for _ in range(rows)]
    visited = [[False for _ in range(cols)] for _ in range(rows)]

    start = (rng.randrange(rows), rng.randrange(cols))
    stack = [start]
    visited[start[0]][start[1]] = True

    while stack:
        r, c = stack[-1]
        candidates = []
        for dr, dc, out_bit, in_bit in DIRS:
            nr, nc = r + dr, c + dc
            if 0 <= nr < rows and 0 <= nc < cols and not visited[nr][nc]:
                candidates.append((nr, nc, out_bit, in_bit))

        if not candidates:
            stack.pop()
            continue

        nr, nc, out_bit, in_bit = rng.choice(candidates)
        solution[r][c] |= out_bit
        solution[nr][nc] |= in_bit
        visited[nr][nc] = True
        stack.append((nr, nc))

    # 2) Optionally forbid 4-way crosses (degree == 4)
    if not allow_cross:
        for r in range(rows):
            for c in range(cols):
                if mask_degree(solution[r][c]) >= 4:
                    bump = rng.randrange(1, 1_000_000_000)
                    return generate_network(
                        rows, cols,
                        seed=(seed or 0) + bump,
                        allow_cross=allow_cross,
                        prefer_source_degree_at_least=prefer_source_degree_at_least,
                    )

    # 3) Choose a source cell (prefer degree >= K)
    candidates = [
        (r, c) for r in range(rows) for c in range(cols)
        if mask_degree(solution[r][c]) >= prefer_source_degree_at_least
    ]
    if not candidates:
        candidates = [(r, c) for r in range(rows) for c in range(cols)]
    source = rng.choice(candidates)

    # 4) Scramble by rotating each tile
    puzzle = [[0 for _ in range(cols)] for _ in range(rows)]
    rotations = [[0 for _ in range(cols)] for _ in range(rows)]
    for r in range(rows):
        for c in range(cols):
            k = rng.randrange(4)
            rotations[r][c] = k
            puzzle[r][c] = rotate_mask(solution[r][c], k)

    return puzzle, solution, rotations, source


# ----------------------------
# Tile construction + updates
# ----------------------------
def build_tiles_from_puzzle(
    puzzle_masks: List[List[int]],
    rotations: List[List[int]],
    source: Tuple[int, int],
) -> List[List[Tile]]:
    rows, cols = len(puzzle_masks), len(puzzle_masks[0])
    sr, sc = source

    tiles: List[List[Tile]] = [[None for _ in range(cols)] for _ in range(rows)]  # type: ignore
    for r in range(rows):
        for c in range(cols):
            m = puzzle_masks[r][c]
            tiles[r][c] = Tile(
                row=r,
                col=c,
                mask=m,
                rotation=rotations[r][c],
                openings=mask_to_openings(m),
                degree=mask_degree(m),
                kind=mask_kind(m),
                is_source=(r == sr and c == sc),
                is_powered=False,
            )
    return tiles


def rotate_tile_cw(tile: Tile, turns: int = 1) -> None:
    """Rotate a tile clockwise in-place, updating cached metadata."""
    turns %= 4
    if turns == 0:
        return
    tile.rotation = (tile.rotation + turns) % 4
    tile.mask = rotate_mask(tile.mask, turns)
    tile.openings = mask_to_openings(tile.mask)
    tile.degree = mask_degree(tile.mask)
    tile.kind = mask_kind(tile.mask)


# ----------------------------
# Connectivity ("powered") propagation
# ----------------------------
def propagate_power(tiles: List[List[Tile]]) -> None:
    """
    Marks tile.is_powered = True for all tiles connected to the source
    via matching openings. Clears all other tiles to False.
    """
    rows, cols = len(tiles), len(tiles[0])

    # Clear
    for r in range(rows):
        for c in range(cols):
            tiles[r][c].is_powered = False

    # Find source
    src: Optional[Tile] = None
    for r in range(rows):
        for c in range(cols):
            if tiles[r][c].is_source:
                src = tiles[r][c]
                break
        if src:
            break
    if src is None:
        return

    q = deque([src])
    src.is_powered = True

    def neighbor_of(r: int, c: int, d: str) -> Optional[Tuple[int, int]]:
        if d == "N":
            r -= 1
        elif d == "E":
            c += 1
        elif d == "S":
            r += 1
        elif d == "W":
            c -= 1
        else:
            return None
        if 0 <= r < rows and 0 <= c < cols:
            return r, c
        return None

    while q:
        t = q.popleft()
        for d in t.openings:
            nb = neighbor_of(t.row, t.col, d)
            if nb is None:
                continue
            nr, nc = nb
            nt = tiles[nr][nc]
            if nt.is_powered:
                continue
            # neighbor must have the opposite opening
            if OPPOSITE_NAME[d] in nt.openings:
                nt.is_powered = True
                q.append(nt)


# ----------------------------
# Optional: quick debug printing
# ----------------------------
def mask_to_str(mask: int) -> str:
    s = ""
    if mask & N: s += "N"
    if mask & E: s += "E"
    if mask & S: s += "S"
    if mask & W: s += "W"
    return s or "."


def print_tiles(tiles: List[List[Tile]]) -> None:
    for row in tiles:
        print(" ".join(
            ("S" if t.is_source else " ") +
            mask_to_str(t.mask).ljust(4) +
            ("*" if t.is_powered else " ")
            for t in row
        ))


# ----------------------------
# Example usage
# ----------------------------
if __name__ == "__main__":
    puzzle, solution, rots, source = generate_network(
        6, 6,
        seed=42,
        allow_cross=True,
        prefer_source_degree_at_least=2,
    )

    tiles = build_tiles_from_puzzle(puzzle, rots, source)
    propagate_power(tiles)

    print("SOURCE:", source)
    print("\nPUZZLE STATE (mask, source marked with 'S', powered marked with '*'):")
    print_tiles(tiles)

    # Example interaction: rotate one tile then recompute power
    r, c = 2, 2
    rotate_tile_cw(tiles[r][c], 1)
    propagate_power(tiles)

    print("\nAFTER ROTATING (2,2) CW ONCE:")
    print_tiles(tiles)
