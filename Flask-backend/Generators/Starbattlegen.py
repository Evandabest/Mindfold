from __future__ import annotations
from typing import List, Tuple, Optional
from functools import lru_cache
import random

# ----------------------------
# Star Battle (1-star) generator
# - Generates a solved placement (one star per row/col, no touching diagonally)
# - Generates connected regions (polyominoes) so each region contains exactly 1 star
# - Optionally enforces unique solution (can be slower)
# ----------------------------

GridInt = List[List[int]]
GridBool = List[List[bool]]


@lru_cache(maxsize=None)
def _precompute_neighbors4(n: int) -> List[List[List[Tuple[int, int]]]]:
    neigh: List[List[List[Tuple[int, int]]]] = [[[] for _ in range(n)] for _ in range(n)]
    for r in range(n):
        for c in range(n):
            lst = neigh[r][c]
            if r > 0: lst.append((r - 1, c))
            if r + 1 < n: lst.append((r + 1, c))
            if c > 0: lst.append((r, c - 1))
            if c + 1 < n: lst.append((r, c + 1))
    return neigh

@lru_cache(maxsize=None)
def _row_order_middle_first(n: int) -> Tuple[int, ...]:
    return tuple(sorted(range(n), key=lambda r: abs(r - (n - 1) / 2)))

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

    # Reuse the same list to avoid allocating/shuffling a new list each row
    order = list(range(n))

    def backtrack(r: int) -> bool:
        if r == n:
            return True

        rng.shuffle(order)
        for c in order:
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

def _build_regions_from_stars(
    n: int,
    star_cols: List[int],
    rng: random.Random,
    neigh: List[List[List[Tuple[int, int]]]],
) -> GridInt:
    """
    Same logic as before, but frontier cells are encoded as ints (r*n + c)
    instead of (r, c) tuples to reduce hashing/allocation overhead.
    """
    regions: GridInt = [[-1] * n for _ in range(n)]
    sizes = [0] * n

    # frontier as (list, set) of INT cells to allow O(1) random pick + membership
    f_list: List[List[int]] = [[] for _ in range(n)]
    f_set: List[set] = [set() for _ in range(n)]

    def enc(r: int, c: int) -> int:
        return r * n + c

    def frontier_add(rid: int, cell_id: int) -> None:
        if cell_id not in f_set[rid]:
            f_set[rid].add(cell_id)
            f_list[rid].append(cell_id)

    # seed each region at its star cell
    for rid, c in enumerate(star_cols):
        r = rid
        regions[r][c] = rid
        sizes[rid] = 1
        for nr, nc in neigh[r][c]:
            if regions[nr][nc] == -1:
                frontier_add(rid, enc(nr, nc))

    unassigned = n * n - n

    # eligibility tracking (avoid O(n) list removes)
    is_eligible = [bool(f_set[rid]) for rid in range(n)]
    eligible_count = sum(is_eligible)

    while unassigned > 0:
        if eligible_count == 0:
            raise RuntimeError("Region growth got stuck; retry with a different seed.")

        # build eligible list only for sampling (n is small)
        eligible = [rid for rid in range(n) if is_eligible[rid]]

        # choose region to grow (bias toward smaller regions)
        min_size = min(sizes[rid] for rid in eligible)
        weights = [1 + max(0, (min_size + 3) - sizes[rid]) for rid in eligible]
        rid = rng.choices(eligible, weights=weights, k=1)[0]

        # pick random frontier cell using lazy deletion
        while True:
            if not f_list[rid]:
                # nothing left to try for this region; update eligibility from the set
                if not f_set[rid] and is_eligible[rid]:
                    is_eligible[rid] = False
                    eligible_count -= 1
                break

            idx = rng.randrange(len(f_list[rid]))
            cell_id = f_list[rid][idx]
            # swap-remove from list
            f_list[rid][idx] = f_list[rid][-1]
            f_list[rid].pop()

            # consume only if still present in the frontier set
            if cell_id in f_set[rid]:
                f_set[rid].remove(cell_id)

                r, c = divmod(cell_id, n)
                if regions[r][c] != -1:
                    # already taken by another region expansion
                    continue

                # claim cell
                regions[r][c] = rid
                sizes[rid] += 1
                unassigned -= 1

                # add new frontier cells
                for nr, nc in neigh[r][c]:
                    if regions[nr][nc] == -1:
                        frontier_add(rid, enc(nr, nc))

                # update eligibility in O(1)
                if f_set[rid] and not is_eligible[rid]:
                    is_eligible[rid] = True
                    eligible_count += 1
                elif (not f_set[rid]) and is_eligible[rid]:
                    is_eligible[rid] = False
                    eligible_count -= 1

                break

        # loop continues until all cells assigned

    return regions




def _count_solutions(regions: GridInt, limit: int = 2) -> int:
    n = len(regions)
    ALL = (1 << n) - 1

    row_order = _row_order_middle_first(n)
    row_choice = [-1] * n

    reg = [[regions[r][c] for c in range(n)] for r in row_order]

    # ✅ precompute once
    forbid_masks = [0] * n
    for x in range(n):
        m = 1 << x
        if x > 0: m |= 1 << (x - 1)
        if x + 1 < n: m |= 1 << (x + 1)
        forbid_masks[x] = m

    def backtrack(i: int, used_col_mask: int, used_reg_mask: int) -> int:
        if i == n:
            return 1

        orig_r = row_order[i]
        prev_c = row_choice[orig_r - 1] if orig_r > 0 else -1
        nxt_c  = row_choice[orig_r + 1] if orig_r + 1 < n else -1

        cand = ALL & ~used_col_mask
        forbid = 0
        if prev_c != -1: forbid |= forbid_masks[prev_c]
        if nxt_c != -1:  forbid |= forbid_masks[nxt_c]
        cand &= ~forbid

        total = 0
        while cand:
            lsb = cand & -cand
            c = lsb.bit_length() - 1
            cand -= lsb

            rid = reg[i][c]
            if (used_reg_mask >> rid) & 1:
                continue

            row_choice[orig_r] = c
            total += backtrack(
                i + 1,
                used_col_mask | (1 << c),
                used_reg_mask | (1 << rid),
            )
            row_choice[orig_r] = -1

            if total >= limit:
                return total

        return total

    return backtrack(0, 0, 0)

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
    neigh = _precompute_neighbors4(n)

    for _ in range(max_star_tries):
        # 1) Generate a valid "hidden" star placement
        star_cols = _generate_star_solution(n, rng)

        # 2) For that same placement, try many different region partitions
        for _ in range(max_region_tries_per_star):
            try:
                regions = _build_regions_from_stars(n, star_cols, rng, neigh)
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
        ensure_unique=True,
        seed=67856,
        max_star_tries=600,
        max_region_tries_per_star=100
    )

    print("REGIONS:")
    print_regions(regions)
    print("\nSOLUTION:")
    print_solution(sol)
