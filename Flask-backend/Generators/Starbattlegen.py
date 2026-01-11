from __future__ import annotations
from typing import List, Tuple, Optional
import random

# ----------------------------
# Star Battle (1-star) generator
# - Generates a solved placement (one star per row/col, no touching diagonally)
# - Generates connected regions (polyominoes) so each region contains exactly 1 star
# - Optionally enforces unique solution (can be slower)
# ----------------------------

GridInt = List[List[int]]
GridBool = List[List[bool]]


def _neighbors4(r: int, c: int, n: int):
    if r > 0: yield r - 1, c
    if r + 1 < n: yield r + 1, c
    if c > 0: yield r, c - 1
    if c + 1 < n: yield r, c + 1


def _no_touch_ok(stars_col_by_row: List[int], r: int, c: int) -> bool:
    """With exactly 1 star per row, only need to check adjacency to previous row."""
    if r == 0:
        return True
    pc = stars_col_by_row[r - 1]
    return abs(pc - c) >= 2  # forbids vertical (same col) and diagonal (±1)


def _generate_star_solution(n: int, rng: random.Random) -> List[int]:
    """
    Returns a list cols[r] = column of star in row r.
    Ensures:
      - one per row (by construction)
      - one per column (permutation)
      - no touching (no vertical/diagonal adjacency)
    """
    cols = [-1] * n
    used_cols = [False] * n

    def backtrack(r: int) -> bool:
        if r == n:
            return True
        candidates = list(range(n))
        rng.shuffle(candidates)
        for c in candidates:
            if used_cols[c]:
                continue
            if not _no_touch_ok(cols, r, c):
                continue
            cols[r] = c
            used_cols[c] = True
            if backtrack(r + 1):
                return True
            used_cols[c] = False
            cols[r] = -1
        return False

    if not backtrack(0):
        raise RuntimeError("Failed to generate a star placement; try a different seed.")
    return cols


def _build_regions_from_stars(n: int, star_cols: List[int], rng: random.Random) -> GridInt:
    """
    Creates n connected regions, each containing exactly one star cell.
    Multi-source randomized growth starting from each star.
    """
    regions: GridInt = [[-1] * n for _ in range(n)]
    sizes = [0] * n
    frontiers = [set() for _ in range(n)]

    # Seed each region with its star cell
    for rid, c in enumerate(star_cols):
        r = rid
        regions[r][c] = rid
        sizes[rid] = 1
        for nr, nc in _neighbors4(r, c, n):
            if regions[nr][nc] == -1:
                frontiers[rid].add((nr, nc))

    unassigned = n * n - n

    # Expand until all assigned
    while unassigned > 0:
        # Eligible regions that can expand
        eligible = [rid for rid in range(n) if frontiers[rid]]
        if not eligible:
            # Should be rare; restart by raising (caller can retry with new seed)
            raise RuntimeError("Region growth got stuck; retry with a different seed.")

        # Bias growth toward smaller regions for nicer-looking partitions
        min_size = min(sizes[rid] for rid in eligible)
        weighted = []
        for rid in eligible:
            # smaller => more weight
            w = 1 + (max(0, (min_size + 3) - sizes[rid]))
            weighted.extend([rid] * w)

        rid = rng.choice(weighted)

        # Pick a random frontier cell
        cell = rng.choice(tuple(frontiers[rid]))
        frontiers[rid].remove(cell)
        r, c = cell

        if regions[r][c] != -1:
            continue  # already taken by another region expansion

        regions[r][c] = rid
        sizes[rid] += 1
        unassigned -= 1

        # Add new frontier cells
        for nr, nc in _neighbors4(r, c, n):
            if regions[nr][nc] == -1:
                frontiers[rid].add((nr, nc))

        # Clean up frontier entries that became assigned
        for rr, cc in list(frontiers[rid]):
            if regions[rr][cc] != -1:
                frontiers[rid].remove((rr, cc))

    return regions


def _count_solutions(regions: GridInt, limit: int = 2) -> int:
    """
    Counts solutions up to 'limit' for 1-star Star Battle:
      - 1 star per row, column, region
      - stars can't touch (including diagonals)
    """
    n = len(regions)
    # region id -> list of cells
    region_cells = [[] for _ in range(n)]
    for r in range(n):
        for c in range(n):
            region_cells[regions[r][c]].append((r, c))

    # choose 1 cell from each row, respecting constraints
    row_choice = [-1] * n
    used_col = [False] * n
    used_region = [False] * n

    def ok_place(r: int, c: int) -> bool:
        if used_col[c]:
            return False
        rid = regions[r][c]
        if used_region[rid]:
            return False

        # no-touch: check previous row only (because 1 per row)
        if r > 0 and row_choice[r - 1] != -1:
            if abs(row_choice[r - 1] - c) <= 1:
                return False
        # Also need to check next row only when it gets assigned, so done later.
        return True

    # Heuristic: order rows by how constrained their available cells are (dynamic)
    rows = list(range(n))

    def backtrack(idx: int) -> int:
        if idx == n:
            return 1
        # pick next unfilled row with smallest candidate count
        best_row = -1
        best_cands = None
        for r in rows:
            if row_choice[r] != -1:
                continue
            cands = []
            for c in range(n):
                if ok_place(r, c):
                    # also check no-touch with already-set next row (if any)
                    if r + 1 < n and row_choice[r + 1] != -1:
                        if abs(row_choice[r + 1] - c) <= 1:
                            continue
                    cands.append(c)
            if best_cands is None or len(cands) < len(best_cands):
                best_row = r
                best_cands = cands
                if len(best_cands) == 0:
                    return 0
                if len(best_cands) == 1:
                    break

        r = best_row
        cands = best_cands
        # random-ish iteration not needed for counting, keep deterministic
        total = 0
        for c in cands:
            rid = regions[r][c]
            row_choice[r] = c
            used_col[c] = True
            used_region[rid] = True

            total += backtrack(idx + 1)
            if total >= limit:
                # undo
                row_choice[r] = -1
                used_col[c] = False
                used_region[rid] = False
                return total

            row_choice[r] = -1
            used_col[c] = False
            used_region[rid] = False
        return total

    return backtrack(0)


def generate_starbattle_1star(
    n: int,
    *,
    ensure_unique: bool = True,
    seed: Optional[int] = None,
    max_star_tries: int = 2_000,        # ✅ was max_tries
    max_region_tries_per_star: int = 200,  # ✅ NEW: retry regions a lot (cheap)
) -> Tuple[GridInt, GridBool]:
    """
    Returns (regions, solution_stars)

    regions: n x n grid of ints in [0..n-1] indicating region id (connected)
    solution_stars: n x n bool grid with exactly one True per row/col/region,
                    and no two True cells touch (including diagonals)

    Notes:
      - This matches your "Kings" game (1 per row/col/region, no touching).
      - If ensure_unique=True, it retries until the region partition yields a unique solution.
    """
    if n <= 0:
        raise ValueError("n must be positive.")
    rng = random.Random(seed)

    for _ in range(max_star_tries):
        # 1) Generate a valid "hidden" star placement
        star_cols = _generate_star_solution(n, rng)

        # 2) For that same placement, try many different region partitions
        for _ in range(max_region_tries_per_star):
            try:
                regions = _build_regions_from_stars(n, star_cols, rng)
            except RuntimeError:
                # region growth got stuck; just retry
                continue

            if ensure_unique:
                if _count_solutions(regions, limit=2) != 1:
                    continue

            stars: GridBool = [[False] * n for _ in range(n)]
            for r, c in enumerate(star_cols):
                stars[r][c] = True
            return regions, stars

    raise RuntimeError(
        "Failed to generate (unique) puzzle within limits. "
        "Try a different seed, increase max_star_tries/max_region_tries_per_star, "
        "or set ensure_unique=False."
    )


# ----------------------------
# Helpers to visualize
# ----------------------------
def print_regions(regions: GridInt) -> None:
    n = len(regions)
    w = max(2, len(str(n - 1)))
    for r in range(n):
        print(" ".join(str(regions[r][c]).rjust(w) for c in range(n)))


def print_solution(stars: GridBool) -> None:
    for row in stars:
        print(" ".join("K" if x else "." for x in row))


if __name__ == "__main__":
    regions, sol = generate_starbattle_1star(
        8,
        ensure_unique=False,
        seed=67856,
        max_star_tries=600,
        max_region_tries_per_star=100
    )

    print("REGIONS:")
    print_regions(regions)
    print("\nSOLUTION:")
    print_solution(sol)
