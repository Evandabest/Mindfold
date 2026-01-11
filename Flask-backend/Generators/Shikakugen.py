from __future__ import annotations
from dataclasses import dataclass
from typing import List, Optional, Tuple
import random

@dataclass(frozen=True)
class Rect:
    r0: int  # top
    c0: int  # left
    r1: int  # bottom (exclusive)
    c1: int  # right (exclusive)

    @property
    def h(self) -> int:
        return self.r1 - self.r0

    @property
    def w(self) -> int:
        return self.c1 - self.c0

    @property
    def area(self) -> int:
        return self.h * self.w


# ✅ ADD near imports / top-level
MIN_RECT_AREA = 2  # never allow 1x1 rectangles


def _split_rect(rect: Rect, rng: random.Random) -> Optional[Tuple[Rect, Rect]]:
    """
    Randomly split rect into two smaller rectangles with a straight cut.
    Returns (a, b) or None if it can't be split.
    Never returns a split that creates an area-1 rectangle.
    """
    can_h = rect.h >= 2
    can_v = rect.w >= 2
    if not can_h and not can_v:
        return None

    # ✅ NEW: try a few times to find a split where both children have area >= 2
    for _ in range(20):
        # Choose split orientation (bias toward the dimension that's larger).
        if can_h and can_v:
            choose_h = rng.random() < (rect.h / (rect.h + rect.w))
        else:
            choose_h = can_h

        if choose_h:
            # horizontal cut between rows
            cut = rng.randint(rect.r0 + 1, rect.r1 - 1)
            a = Rect(rect.r0, rect.c0, cut, rect.c1)
            b = Rect(cut, rect.c0, rect.r1, rect.c1)
        else:
            # vertical cut between cols
            cut = rng.randint(rect.c0 + 1, rect.c1 - 1)
            a = Rect(rect.r0, rect.c0, rect.r1, cut)
            b = Rect(rect.r0, cut, rect.r1, rect.c1)

        # ✅ NEW: reject splits that create 1x1 (area 1) rectangles
        if a.area >= MIN_RECT_AREA and b.area >= MIN_RECT_AREA:
            return a, b

    return None


def generate_shikaku_board(
    rows: int,
    cols: int,
    *,
    target_rects: Optional[int] = None,
    max_rect_area: Optional[int] = None,
    seed: Optional[int] = None,
) -> Tuple[List[List[int]], List[Rect]]:

    if rows <= 0 or cols <= 0:
        raise ValueError("rows and cols must be positive.")

    rng = random.Random(seed)

    total_cells = rows * cols
    if target_rects is None:
        target_rects = max(2, min(total_cells, total_cells // 5))

    rects: List[Rect] = [Rect(0, 0, rows, cols)]

    def should_split(rect: Rect) -> bool:
        # ✅ NEW: if area < 4, any split would create an area-1 child somewhere (e.g., 1x1 + 1x2)
        # so disallow splitting when we can't guarantee both children have area >= 2.
        if rect.area < MIN_RECT_AREA * 2:
            return False

        if max_rect_area is not None and rect.area > max_rect_area:
            return True

        return len(rects) < target_rects

    safety = 50_000
    while safety > 0:
        safety -= 1

        candidates = [i for i, r in enumerate(rects) if should_split(r)]
        if not candidates:
            break

        idx = rng.choice(candidates)
        r = rects[idx]
        split = _split_rect(r, rng)
        if split is None:
            continue

        a, b = split
        rects[idx] = a
        rects.append(b)

        if len(rects) >= target_rects and (max_rect_area is None):
            break

    board = [[0 for _ in range(cols)] for _ in range(rows)]
    for r in rects:
        rr = rng.randint(r.r0, r.r1 - 1)
        cc = rng.randint(r.c0, r.c1 - 1)
        board[rr][cc] = r.area

    return board, rects



def pretty_print_board(board: List[List[int]]) -> None:
    width = max(2, max((len(str(x)) for row in board for x in row), default=1))
    for row in board:
        print(" ".join(("_" if x == 0 else str(x)).rjust(width) for x in row))


# Example usage:
if __name__ == "__main__":
    b, solution = generate_shikaku_board(
        8, 10,
        target_rects=16,
        max_rect_area=12,
        seed=43,
    )
    pretty_print_board(b)
    print(f"\nRectangles: {len(solution)}  (areas: {[r.area for r in solution]})")