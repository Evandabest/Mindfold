from __future__ import annotations
from dataclasses import dataclass
from typing import List, Tuple, Optional, Dict
import random

Cell = Tuple[int, int]  # (r, c)

# ----------------------------
# Data model
# ----------------------------
@dataclass(frozen=True)
class SnapClue:
    value: int   # 1..K
    r: int
    c: int

@dataclass(frozen=True)
class SnapPuzzle:
    rows: int
    cols: int
    clues: List[SnapClue]          # what you render
    solution_path: List[Cell]      # optional (for testing/debug)

# ----------------------------
# Helpers
# ----------------------------
DIRS: List[Cell] = [(1,0), (-1,0), (0,1), (0,-1)]

def _in_bounds(r: int, c: int, R: int, C: int) -> bool:
    return 0 <= r < R and 0 <= c < C

def _neighbors(cell: Cell, R: int, C: int) -> List[Cell]:
    r, c = cell
    out = []
    for dr, dc in DIRS:
        rr, cc = r + dr, c + dc
        if _in_bounds(rr, cc, R, C):
            out.append((rr, cc))
    return out

def _degree(cell: Cell, used: set[Cell], R: int, C: int) -> int:
    """How many unused neighbors remain."""
    return sum((n not in used) for n in _neighbors(cell, R, C))

# ----------------------------
# Hamiltonian path generator
# ----------------------------
def _hamiltonian_path_warnsdorff(
    R: int, C: int, rng: random.Random, max_restarts: int = 500
) -> Optional[List[Cell]]:
    """
    Builds a Hamiltonian path using a randomized Warnsdorff-style heuristic:
    at each step, move to the unused neighbor with the fewest onward moves.
    Random tie-breaks.
    Works very well for typical mobile sizes (e.g., 5x5 up to ~10x10),
    but is heuristic (may need restarts).
    """
    N = R * C
    all_cells = [(r, c) for r in range(R) for c in range(C)]

    for _ in range(max_restarts):
        start = rng.choice(all_cells)
        path = [start]
        used = {start}

        while len(path) < N:
            cur = path[-1]
            candidates = [n for n in _neighbors(cur, R, C) if n not in used]
            if not candidates:
                break

            # Warnsdorff: prefer smallest remaining degree
            # Randomize by shuffling first so ties are broken randomly.
            rng.shuffle(candidates)
            candidates.sort(key=lambda n: _degree(n, used, R, C))
            nxt = candidates[0]

            used.add(nxt)
            path.append(nxt)

        if len(path) == N:
            return path

    return None

# ----------------------------
# Public generator
# ----------------------------
def generate_snap(
    rows: int,
    cols: int,
    *,
    num_clues: int,
    seed: Optional[int] = None,
    keep_endpoints_labeled: bool = True,
    max_tries: int = 2000,
) -> SnapPuzzle:
    """
    Generate a Snap-like puzzle:
    - one continuous path through every cell exactly once
    - clue numbers 1..K placed on K cells along that path, must be visited in order.

    Parameters:
      num_clues: K (>=2). In your screenshots it's like 1..6-ish.
      keep_endpoints_labeled: if True, forces clue 1 = path start and clue K = path end.
    """
    if rows <= 0 or cols <= 0:
        raise ValueError("rows/cols must be positive.")
    if num_clues < 2:
        raise ValueError("num_clues must be >= 2.")
    if num_clues > rows * cols:
        raise ValueError("num_clues cannot exceed number of cells.")

    rng = random.Random(seed)

    for _ in range(max_tries):
        path = _hamiltonian_path_warnsdorff(rows, cols, rng, max_restarts=200)
        if path is None:
            continue

        N = rows * cols

        # Choose K indices along the path in increasing order.
        if keep_endpoints_labeled:
            # fixed endpoints
            idxs = [0, N - 1]
            remaining = num_clues - 2
            if remaining > 0:
                mids = sorted(rng.sample(range(1, N - 1), remaining))
                idxs = [0] + mids + [N - 1]
        else:
            idxs = sorted(rng.sample(range(N), num_clues))

        clues: List[SnapClue] = []
        for i, idx in enumerate(idxs, start=1):
            r, c = path[idx]
            clues.append(SnapClue(value=i, r=r, c=c))

        return SnapPuzzle(rows=rows, cols=cols, clues=clues, solution_path=path)

    raise RuntimeError("Failed to generate Snap puzzle; try different seed/params.")


# ----------------------------
# Quick demo
# ----------------------------
if __name__ == "__main__":
    p = generate_snap(5, 5, num_clues=6, seed=7, keep_endpoints_labeled=False)
    print("Clues:")
    for clue in p.clues:
        print(clue)

    # optional: print clue grid
    grid = [["." for _ in range(p.cols)] for _ in range(p.rows)]
    for clue in p.clues:
        grid[clue.r][clue.c] = str(clue.value)
    print("\nGrid:")
    for r in range(p.rows):
        print(" ".join(x.rjust(2) for x in grid[r]))
