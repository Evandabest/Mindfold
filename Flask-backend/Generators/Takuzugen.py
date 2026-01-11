from __future__ import annotations
from dataclasses import dataclass
from typing import List, Optional, Tuple
import random

# Cell values: -1 = empty, 0/1 are the two symbols
EMPTY = -1


def _no_three_consecutive(line: List[int]) -> bool:
    # line may include EMPTY
    for i in range(len(line) - 2):
        a, b, c = line[i], line[i + 1], line[i + 2]
        if a != EMPTY and a == b == c:
            return False
    return True


def _count_ok(line: List[int]) -> bool:
    # For size N, each line must have exactly N/2 zeros and N/2 ones.
    # Partial lines: counts cannot exceed N/2.
    n = len(line)
    half = n // 2
    z = sum(1 for x in line if x == 0)
    o = sum(1 for x in line if x == 1)
    if z > half or o > half:
        return False
    # If complete line, must be exactly half/half
    if EMPTY not in line:
        return z == half and o == half
    return True


def _line_signature(line: List[int]) -> Optional[Tuple[int, ...]]:
    # Only compare duplicates when fully filled
    if EMPTY in line:
        return None
    return tuple(line)


def _valid_after_set(grid: List[List[int]], r: int, c: int, n: int) -> bool:
    # row/col constraints
    row = grid[r]
    col = [grid[i][c] for i in range(n)]

    if not _no_three_consecutive(row) or not _no_three_consecutive(col):
        return False
    if not _count_ok(row) or not _count_ok(col):
        return False

    # "No identical rows/cols" rule (only check when a line becomes complete)
    row_sig = _line_signature(row)
    if row_sig is not None:
        for rr in range(n):
            if rr != r and _line_signature(grid[rr]) == row_sig:
                return False

    col_sig = _line_signature(col)
    if col_sig is not None:
        for cc in range(n):
            if cc != c:
                other_col = [grid[i][cc] for i in range(n)]
                if _line_signature(other_col) == col_sig:
                    return False

    return True


def _find_next_cell(grid: List[List[int]]) -> Optional[Tuple[int, int]]:
    n = len(grid)
    for r in range(n):
        for c in range(n):
            if grid[r][c] == EMPTY:
                return r, c
    return None


def _solve_count_solutions(
    grid: List[List[int]],
    limit: int = 2,
) -> int:
    """
    Counts solutions up to 'limit' (early exit). Used for uniqueness checking.
    """
    n = len(grid)
    nxt = _find_next_cell(grid)
    if nxt is None:
        return 1

    r, c = nxt
    # Try 0/1
    total = 0
    for v in (0, 1):
        grid[r][c] = v
        if _valid_after_set(grid, r, c, n):
            total += _solve_count_solutions(grid, limit)
            if total >= limit:
                grid[r][c] = EMPTY
                return total
        grid[r][c] = EMPTY
    return total


def _generate_full_solution(n: int, rng: random.Random) -> List[List[int]]:
    """
    Generates a complete valid Takuzu solution by backtracking.
    Assumes n is even.
    """
    grid = [[EMPTY] * n for _ in range(n)]

    # simple heuristic ordering: randomize choices per cell
    def backtrack() -> bool:
        nxt = _find_next_cell(grid)
        if nxt is None:
            return True
        r, c = nxt
        vals = [0, 1]
        rng.shuffle(vals)
        for v in vals:
            grid[r][c] = v
            if _valid_after_set(grid, r, c, n) and backtrack():
                return True
            grid[r][c] = EMPTY
        return False

    if not backtrack():
        raise RuntimeError("Failed to generate a full solution (try a different seed).")

    return grid


def generate_binary_puzzle(
    n: int,
    *,
    givens_ratio: float = 0.45,
    ensure_unique: bool = True,
    seed: Optional[int] = None,
    max_removal_attempts: int = 50_000,
) -> Tuple[List[List[int]], List[List[int]]]:
    """
    Generates a Binary Puzzle (Takuzu/Binairo).

    Returns (puzzle, solution):
      puzzle: grid with EMPTY=-1 for blanks, 0/1 for given cells
      solution: full solved grid (0/1)

    Params:
      n: board size (must be even; typical 6, 8, 10, 12...)
      givens_ratio: fraction of cells left filled (lower => harder)
      ensure_unique: if True, removes cells only if puzzle still has 1 solution
      seed: RNG seed
      max_removal_attempts: safety bound
    """
    if n <= 0 or n % 2 != 0:
        raise ValueError("n must be a positive even number (e.g., 6, 8, 10).")
    if not (0.05 <= givens_ratio <= 0.95):
        raise ValueError("givens_ratio should be between 0.05 and 0.95.")

    rng = random.Random(seed)

    solution = _generate_full_solution(n, rng)
    puzzle = [row[:] for row in solution]

    total_cells = n * n
    target_givens = int(round(total_cells * givens_ratio))
    to_remove = total_cells - target_givens

    # Create a randomized list of positions to try removing
    positions = [(r, c) for r in range(n) for c in range(n)]
    rng.shuffle(positions)

    removed = 0
    attempts = 0

    # Remove cells while preserving solvability (and uniqueness if requested)
    i = 0
    while removed < to_remove and attempts < max_removal_attempts:
        attempts += 1
        if i >= len(positions):
            rng.shuffle(positions)
            i = 0

        r, c = positions[i]
        i += 1

        if puzzle[r][c] == EMPTY:
            continue

        backup = puzzle[r][c]
        puzzle[r][c] = EMPTY

        if ensure_unique:
            # Count solutions; must be exactly 1
            test_grid = [row[:] for row in puzzle]
            sol_count = _solve_count_solutions(test_grid, limit=2)
            if sol_count != 1:
                puzzle[r][c] = backup
                continue
        else:
            # Just ensure at least one solution (fast check via count>=1)
            test_grid = [row[:] for row in puzzle]
            sol_count = _solve_count_solutions(test_grid, limit=1)
            if sol_count < 1:
                puzzle[r][c] = backup
                continue

        removed += 1

    return puzzle, solution


def pretty_print(grid: List[List[int]]) -> None:
    # prints _ for empty, otherwise 0/1
    for row in grid:
        print(" ".join("_" if x == EMPTY else str(x) for x in row))


# Example usage:
if __name__ == "__main__":
    puzzle, sol = generate_binary_puzzle(
        8,
        givens_ratio=0.40,
        ensure_unique=True,
        seed=42,
    )
    print("PUZZLE:")
    pretty_print(puzzle)
    print("\nSOLUTION:")
    pretty_print(sol)
