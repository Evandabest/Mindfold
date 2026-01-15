from __future__ import annotations

from dataclasses import dataclass
from typing import List, Optional, Tuple, Set, Dict
import random
from collections import deque

Coord = Tuple[int, int]


# ============================
# Mosaic / Flood-paint puzzle (tap-a-region-to-recolor)
# ============================
# Move:
#   - pick a cell (r,c)
#   - its "area" is the whole connected component of the same color (4-neighborhood)
#   - repaint that entire component to the chosen color
#   - adjacent components of that color merge automatically
#
# Goal:
#   - make the whole board a single color within <= move_limit moves
#
# This generator:
#   - creates a random board
#   - (optionally) searches for a solution within move_limit using a depth-limited DFS
#   - returns the board + move_limit (+ optional solution for debugging)
#
# NOTE: This is a generator only; your Swift frontend can implement scoring/UX.
#       The solver here is ONLY to ensure the generated puzzle is solvable.


@dataclass(frozen=True)
class MosaicPuzzle:
    rows: int
    cols: int
    num_colors: int
    move_limit: int
    grid: List[List[int]]                 # color indices 0..num_colors-1
    solution: Optional[List[Tuple[int,int,int]]] = None
    # solution is list of moves (r, c, new_color) that solves within move_limit (if ensure_solvable=True)


# ----------------------------
# Helpers: components, apply move
# ----------------------------

def _inb(r: int, c: int, rows: int, cols: int) -> bool:
    return 0 <= r < rows and 0 <= c < cols


def _component(grid: List[List[int]], sr: int, sc: int) -> Set[Coord]:
    """Return the 4-connected component of (sr,sc) with the same color."""
    rows, cols = len(grid), len(grid[0])
    color = grid[sr][sc]
    q = deque([(sr, sc)])
    seen: Set[Coord] = {(sr, sc)}
    while q:
        r, c = q.popleft()
        for dr, dc in ((1,0), (-1,0), (0,1), (0,-1)):
            rr, cc = r + dr, c + dc
            if _inb(rr, cc, rows, cols) and (rr, cc) not in seen and grid[rr][cc] == color:
                seen.add((rr, cc))
                q.append((rr, cc))
    return seen


def _apply_move(
    grid: List[List[int]],
    sr: int,
    sc: int,
    new_color: int,
) -> List[List[int]]:
    """Return a new grid after repainting the component at (sr,sc) to new_color."""
    rows, cols = len(grid), len(grid[0])
    old = grid[sr][sc]
    if new_color == old:
        return grid  # no-op (caller should avoid)

    comp = _component(grid, sr, sc)
    out = [row[:] for row in grid]
    for r, c in comp:
        out[r][c] = new_color
    return out


def _is_solved(grid: List[List[int]]) -> bool:
    first = grid[0][0]
    return all(cell == first for row in grid for cell in row)


def _grid_key(grid: List[List[int]]) -> Tuple[int, ...]:
    return tuple(cell for row in grid for cell in row)


def _count_colors(grid: List[List[int]]) -> int:
    return len(set(cell for row in grid for cell in row))


def _boundary_seeds(grid: List[List[int]]) -> List[Coord]:
    """
    Return representative cells likely to be useful moves:
    cells that sit on a boundary between different colors.
    """
    rows, cols = len(grid), len(grid[0])
    seeds: List[Coord] = []
    for r in range(rows):
        for c in range(cols):
            col = grid[r][c]
            for dr, dc in ((1,0), (-1,0), (0,1), (0,-1)):
                rr, cc = r + dr, c + dc
                if _inb(rr, cc, rows, cols) and grid[rr][cc] != col:
                    seeds.append((r, c))
                    break
    return seeds or [(0, 0)]


def _neighbor_colors(grid: List[List[int]], comp: Set[Coord]) -> Set[int]:
    """Colors that touch the component by an edge (useful recolor targets)."""
    rows, cols = len(grid), len(grid[0])
    out: Set[int] = set()
    for r, c in comp:
        for dr, dc in ((1,0), (-1,0), (0,1), (0,-1)):
            rr, cc = r + dr, c + dc
            if _inb(rr, cc, rows, cols) and (rr, cc) not in comp:
                out.add(grid[rr][cc])
    return out


# ----------------------------
# Depth-limited solver (used only for generation)
# ----------------------------

def _find_solution_within(
    start: List[List[int]],
    num_colors: int,
    move_limit: int,
    rng: random.Random,
    *,
    node_limit: int = 200_000,
) -> Optional[List[Tuple[int, int, int]]]:
    """
    Try to find any solution within move_limit moves using DFS + pruning.

    Pruning heuristics:
      - If number of distinct colors > remaining_moves + 1, impossible (each move can eliminate
        at most one color in best case).
      - Prefer moves that recolor a component into a neighboring color (merges components).
      - Only consider boundary components (likely to merge).
    """
    seen: Dict[Tuple[Tuple[int, ...], int], int] = {}
    nodes = 0

    def dfs(grid: List[List[int]], depth_left: int) -> Optional[List[Tuple[int, int, int]]]:
        nonlocal nodes
        nodes += 1
        if nodes > node_limit:
            return None

        if _is_solved(grid):
            return []

        # simple necessary condition
        distinct = _count_colors(grid)
        if distinct > depth_left + 1:
            return None
        if depth_left == 0:
            return None

        key = (_grid_key(grid), depth_left)
        if key in seen:
            return None
        seen[key] = 1

        # Candidate seeds: boundary cells, shuffled
        seeds = _boundary_seeds(grid)
        rng.shuffle(seeds)

        # Build candidate moves, score by "merge potential"
        moves: List[Tuple[int, int, int, int]] = []  # (score, r, c, new_color)
        for r, c in seeds[: min(len(seeds), 40)]:  # cap seeds to keep branching sane
            comp = _component(grid, r, c)
            old = grid[r][c]
            ncols = _neighbor_colors(grid, comp)
            if not ncols:
                continue
            for new_col in ncols:
                if new_col == old:
                    continue
                # score: how many boundary contacts already have new_col (approx merge gain)
                score = 0
                for rr, cc in comp:
                    for dr, dc in ((1,0), (-1,0), (0,1), (0,-1)):
                        r2, c2 = rr + dr, cc + dc
                        if _inb(r2, c2, len(grid), len(grid[0])) and (r2, c2) not in comp:
                            if grid[r2][c2] == new_col:
                                score += 1
                moves.append((score, r, c, new_col))

        # If no neighbor-color moves, fall back to any recolor (rare)
        if not moves:
            r, c = seeds[0]
            old = grid[r][c]
            for new_col in range(num_colors):
                if new_col != old:
                    moves.append((0, r, c, new_col))

        # Try best moves first
        moves.sort(reverse=True, key=lambda x: x[0])
        # Add a little randomness at the top to diversify
        top = moves[: min(12, len(moves))]
        rng.shuffle(top)
        moves = top + moves[min(12, len(moves)) : min(40, len(moves))]

        for _, r, c, new_col in moves:
            nxt = _apply_move(grid, r, c, new_col)
            if nxt is grid:  # no-op
                continue
            res = dfs(nxt, depth_left - 1)
            if res is not None:
                return [(r, c, new_col)] + res

        return None

    return dfs(start, move_limit)


# ----------------------------
# Generator
# ----------------------------

def generate_mosaic(
    rows: int,
    cols: int,
    *,
    num_colors: int = 4,
    move_limit: int = 4,
    seed: Optional[int] = None,
    ensure_solvable: bool = True,
    max_tries: int = 500,
    noise_blocks: int = 14,
) -> MosaicPuzzle:
    """
    Generate a Mosaic puzzle board.

    Generation strategy:
      1) Create a board by painting random "blobby" blocks (so it looks like regions).
      2) If ensure_solvable=True, search for a solution within move_limit.
         If not solvable, retry with a new random board.

    Returns:
      MosaicPuzzle(grid=..., move_limit=..., solution=optional list of moves)
    """
    if rows <= 0 or cols <= 0:
        raise ValueError("rows and cols must be positive.")
    if num_colors < 2:
        raise ValueError("num_colors must be >= 2.")
    if move_limit <= 0:
        raise ValueError("move_limit must be positive.")

    rng = random.Random(seed)

    def make_board() -> List[List[int]]:
        # start with random noise
        g = [[rng.randrange(num_colors) for _ in range(cols)] for _ in range(rows)]

        # then overwrite with a few bigger rectangles to form “mosaic blobs”
        for _ in range(noise_blocks):
            r0 = rng.randrange(rows)
            c0 = rng.randrange(cols)
            h = rng.randint(2, max(2, rows // 3))
            w = rng.randint(2, max(2, cols // 3))
            col = rng.randrange(num_colors)
            for r in range(r0, min(rows, r0 + h)):
                for c in range(c0, min(cols, c0 + w)):
                    g[r][c] = col
        return g

    for _ in range(max_tries):
        grid = make_board()

        # avoid already-solved boards
        if _is_solved(grid):
            continue

        sol = None
        if ensure_solvable:
            sol = _find_solution_within(grid, num_colors, move_limit, rng)
            if sol is None:
                continue

        return MosaicPuzzle(
            rows=rows,
            cols=cols,
            num_colors=num_colors,
            move_limit=move_limit,
            grid=grid,
            solution=sol,
        )

    raise RuntimeError("Failed to generate a solvable Mosaic puzzle; try different seed/params.")


# ----------------------------
# Debug printer
# ----------------------------
def pretty_print_grid(grid: List[List[int]]) -> None:
    for row in grid:
        print(" ".join(str(x) for x in row))


if __name__ == "__main__":
    p = generate_mosaic(
        12, 12,
        num_colors=4,
        move_limit=4,
        seed=7,
        ensure_solvable=True,
        max_tries=500,
    )
    pretty_print_grid(p.grid)
    print("moves:", p.move_limit)
    print("solution (r,c,new_color):", p.solution)
