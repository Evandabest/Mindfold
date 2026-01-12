from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, List, Optional, Set, Tuple
import random

Coord = Tuple[int, int]  # (r, c)

# ----------------------------
# Tetromino definitions (canonical L, I, T, S)
# Each shape is defined as a set of (dr, dc) offsets from an anchor (0,0)
# We'll generate rotations automatically.
# ----------------------------

BASE_SHAPES: Dict[str, Set[Coord]] = {
    "I": {(0, 0), (0, 1), (0, 2), (0, 3)},
    "L": {(0, 0), (1, 0), (2, 0), (2, 1)},
    "J": {(0, 1), (1, 1), (2, 0), (2, 1)},  # J is mirrored L; both treated as "L" in LITS
    "T": {(0, 0), (0, 1), (0, 2), (1, 1)},
    "S": {(0, 1), (0, 2), (1, 0), (1, 1)},  # S shape
    "Z": {(0, 0), (0, 1), (1, 1), (1, 2)},  # Z is mirrored S; both treated as "S" in LITS
}


def _rot90(cells: Set[Coord]) -> Set[Coord]:
    # (r,c) -> (c, -r)
    return {(c, -r) for (r, c) in cells}


def _normalize(cells: Set[Coord]) -> Set[Coord]:
    min_r = min(r for r, _ in cells)
    min_c = min(c for _, c in cells)
    return {(r - min_r, c - min_c) for (r, c) in cells}


def all_rotations(shape: Set[Coord]) -> List[Set[Coord]]:
    rots: List[Set[Coord]] = []
    cur = shape
    for _ in range(4):
        cur = _normalize(cur)
        if cur not in rots:
            rots.append(cur)
        cur = _rot90(cur)
    return rots


# Generate rotations for each base shape
# Note: J is treated as "L" in LITS rules (same letter, different orientation)
# Note: Z is treated as "S" in LITS rules (same letter, different orientation)
_BASE_SHAPE_ROTS: Dict[str, List[Set[Coord]]] = {k: all_rotations(v) for k, v in BASE_SHAPES.items()}

# Merge J rotations into L (both are "L" in LITS rules)
# Merge Z rotations into S (both are "S" in LITS rules)
SHAPE_ROTS: Dict[str, List[Set[Coord]]] = {
    "I": _BASE_SHAPE_ROTS["I"],
    "L": _BASE_SHAPE_ROTS["L"] + [r for r in _BASE_SHAPE_ROTS["J"] if r not in _BASE_SHAPE_ROTS["L"]],
    "T": _BASE_SHAPE_ROTS["T"],
    "S": _BASE_SHAPE_ROTS["S"] + [r for r in _BASE_SHAPE_ROTS["Z"] if r not in _BASE_SHAPE_ROTS["S"]],
}

# ----------------------------
# Bitboard helpers (fast solver constraints)
# ----------------------------

def _region_masks(region_map: List[List[int]]) -> Dict[int, int]:
    """Return region_id -> bitmask of all cells in that region."""
    rows, cols = len(region_map), len(region_map[0])
    out: Dict[int, int] = {}
    for r in range(rows):
        for c in range(cols):
            rid = region_map[r][c]
            i = _cell_index(r, c, cols)
            out[rid] = out.get(rid, 0) | _bit(i)
    return out


def _mask_to_cells(mask: int, rows: int, cols: int) -> Tuple[Coord, ...]:
    """Convert bitmask to (r,c) coords. Used only for output grids / debugging."""
    cells: List[Coord] = []
    while mask:
        lsb = mask & -mask
        i = lsb.bit_length() - 1
        r, c = divmod(i, cols)
        cells.append((r, c))
        mask ^= lsb
    return tuple(cells)


def _iter_bits(mask: int):
    """Yield indices of set bits in mask."""
    while mask:
        lsb = mask & -mask
        yield (lsb.bit_length() - 1)
        mask ^= lsb
        

def _cell_index(r: int, c: int, cols: int) -> int:
    return r * cols + c


def _bit(i: int) -> int:
    return 1 << i


def _precompute_board(rows: int, cols: int):
    """
    Returns:
      neighbor_mask[i] : bitmask of 4-neighbors of cell i
      blocks_by_cell[i]: tuple of 2x2 block masks that include cell i
    """
    n = rows * cols

    neighbor_mask = [0] * n
    for r in range(rows):
        for c in range(cols):
            i = _cell_index(r, c, cols)
            m = 0
            if r > 0:
                m |= _bit(_cell_index(r - 1, c, cols))
            if r + 1 < rows:
                m |= _bit(_cell_index(r + 1, c, cols))
            if c > 0:
                m |= _bit(_cell_index(r, c - 1, cols))
            if c + 1 < cols:
                m |= _bit(_cell_index(r, c + 1, cols))
            neighbor_mask[i] = m

    blocks_by_cell: List[List[int]] = [[] for _ in range(n)]
    for r in range(rows - 1):
        for c in range(cols - 1):
            i00 = _cell_index(r, c, cols)
            i01 = _cell_index(r, c + 1, cols)
            i10 = _cell_index(r + 1, c, cols)
            i11 = _cell_index(r + 1, c + 1, cols)
            b = _bit(i00) | _bit(i01) | _bit(i10) | _bit(i11)
            blocks_by_cell[i00].append(b)
            blocks_by_cell[i01].append(b)
            blocks_by_cell[i10].append(b)
            blocks_by_cell[i11].append(b)

    return neighbor_mask, [tuple(x) for x in blocks_by_cell]


# ----------------------------
# Placement model (optimized)
# ----------------------------

@dataclass(frozen=True)
class Placement:
    region_id: int
    shape: str
    mask: int                 # bitmask of the 4 filled cells
    adj_mask: int             # bitmask of all 4-neighbors of those cells
    blocks: Tuple[int, ...]   # relevant 2x2 block masks this placement could complete
    cells: Tuple[Coord, ...]  # kept for building solution grid / debugging


# ----------------------------
# Region generation
# ----------------------------

def _neighbors4(r: int, c: int, rows: int, cols: int):
    if r > 0:
        yield (r - 1, c)
    if r + 1 < rows:
        yield (r + 1, c)
    if c > 0:
        yield (r, c - 1)
    if c + 1 < cols:
        yield (r, c + 1)


def _make_regions(
    rows: int,
    cols: int,
    rng: random.Random,
    *,
    min_region_size: int = 5,
    max_region_size: int = 9,
    max_attempts: int = 300,
) -> List[List[int]]:
    """
    Robust region partitioning:
      - Build a random spanning tree over the grid cells
      - Cut tree edges to form connected components (regions)
      - Ensure each region size is in [min_region_size, max_region_size]
    """
    if min_region_size < 4:
        raise ValueError("min_region_size must be >= 4 (region must fit a tetromino).")
    if min_region_size > max_region_size:
        raise ValueError("min_region_size must be <= max_region_size.")

    n = rows * cols
    if n < min_region_size:
        raise ValueError("Grid too small for given min_region_size.")

    def idx(r: int, c: int) -> int:
        return r * cols + c

    def rc(i: int) -> Tuple[int, int]:
        return divmod(i, cols)

    def grid_neighbors(i: int):
        r, c = rc(i)
        if r > 0:
            yield idx(r - 1, c)
        if r + 1 < rows:
            yield idx(r + 1, c)
        if c > 0:
            yield idx(r, c - 1)
        if c + 1 < cols:
            yield idx(r, c + 1)

    def build_spanning_tree() -> List[Set[int]]:
        """Randomized DFS spanning tree adjacency (size n)."""
        tree = [set() for _ in range(n)]
        seen = [False] * n
        start = rng.randrange(n)
        stack = [start]
        seen[start] = True

        while stack:
            u = stack[-1]
            unseen = [v for v in grid_neighbors(u) if not seen[v]]
            if not unseen:
                stack.pop()
                continue
            v = rng.choice(unseen)
            tree[u].add(v)
            tree[v].add(u)
            seen[v] = True
            stack.append(v)

        if not all(seen):
            raise RuntimeError("Spanning tree failed (should not happen).")
        return tree

    def split_component(tree_adj: List[Set[int]], nodes: Set[int]) -> Optional[Tuple[Set[int], Set[int], Tuple[int, int]]]:
        """
        Try to find an edge inside this component such that cutting it splits into two parts,
        both with size >= min_region_size.
        Returns (A, B, (u,v)) where (u,v) is the cut edge, or None.
        """
        root = next(iter(nodes))

        parent = {root: -1}
        order = [root]
        stack = [root]

        while stack:
            u = stack.pop()
            for v in tree_adj[u]:
                if v not in nodes:
                    continue
                if v not in parent:
                    parent[v] = u
                    stack.append(v)
                    order.append(v)

        sub = {u: 1 for u in nodes}
        for u in reversed(order):
            p = parent[u]
            if p != -1:
                sub[p] += sub[u]

        total = len(nodes)

        candidates: List[Tuple[int, int, int]] = []
        for child in nodes:
            p = parent.get(child, -1)
            if p == -1:
                continue
            a = sub[child]
            b = total - a
            if a >= min_region_size and b >= min_region_size:
                candidates.append((child, p, a))

        if not candidates:
            return None

        child, p, _ = rng.choice(candidates)

        A = set()
        stack = [child]
        A.add(child)
        while stack:
            u = stack.pop()
            for v in tree_adj[u]:
                if v not in nodes:
                    continue
                if parent.get(v, None) == u:
                    if v not in A:
                        A.add(v)
                        stack.append(v)

        B = nodes - A
        return A, B, (child, p)

    for _ in range(max_attempts):
        tree_adj = build_spanning_tree()

        comps: List[Set[int]] = [set(range(n))]

        changed = True
        while changed:
            changed = False
            new_comps: List[Set[int]] = []
            for comp in comps:
                if len(comp) <= max_region_size:
                    new_comps.append(comp)
                    continue

                res = split_component(tree_adj, comp)
                if res is None:
                    new_comps = []
                    break

                A, B, (u, v) = res
                tree_adj[u].remove(v)
                tree_adj[v].remove(u)

                new_comps.append(A)
                new_comps.append(B)
                changed = True

            if not new_comps:
                break
            comps = new_comps

        if not comps:
            continue

        if any(len(comp) < min_region_size or len(comp) > max_region_size for comp in comps):
            continue

        region_map = [[-1] * cols for _ in range(rows)]
        for rid, comp in enumerate(comps):
            for node in comp:
                r, c = divmod(node, cols)
                region_map[r][c] = rid

        if all(x != -1 for row in region_map for x in row):
            return region_map

    raise RuntimeError("Failed to generate regions. Try different parameters/seed.")


# ----------------------------
# Enumerate placements per region (optimized)
# ----------------------------

def _region_cells(region_map: List[List[int]]) -> Dict[int, List[Coord]]:
    rows, cols = len(region_map), len(region_map[0])
    out: Dict[int, List[Coord]] = {}
    for r in range(rows):
        for c in range(cols):
            out.setdefault(region_map[r][c], []).append((r, c))
    return out


def _enumerate_region_placements(region_map: List[List[int]]) -> Dict[int, List[Placement]]:
    rows, cols = len(region_map), len(region_map[0])

    neighbor_mask, blocks_by_cell = _precompute_board(rows, cols)
    reg_masks = _region_masks(region_map)

    placements: Dict[int, List[Placement]] = {rid: [] for rid in reg_masks.keys()}

    # Precompute each rotation as flat index offsets (dr*cols + dc) for speed
    rot_offsets: Dict[str, List[Tuple[int, int, int, int]]] = {}
    for shape, rots in SHAPE_ROTS.items():
        lst = []
        for rot in rots:
            offs = tuple((dr * cols + dc) for (dr, dc) in rot)
            # offs length is 4, but in arbitrary order; that's fine
            lst.append(offs)  # type: ignore
        rot_offsets[shape] = lst  # type: ignore

    # Enumerate: iterate every cell as potential anchor
    for r in range(rows):
        for c in range(cols):
            rid = region_map[r][c]
            region_mask = reg_masks[rid]
            anchor_i = _cell_index(r, c, cols)

            for shape, offs_list in rot_offsets.items():
                for offs in offs_list:
                    # Build placement mask quickly from anchor index + offsets
                    idxs = [anchor_i + d for d in offs]

                    # Bounds check: ensure all idxs are on-board AND preserve row correctness
                    # The dr/dc offsets can wrap rows if we only add flat offsets, so check via coords.
                    coords: List[Coord] = []
                    m = 0
                    ok = True
                    for d in offs:
                        rr = r + (d // cols)
                        cc = c + (d % cols)
                        if rr < 0 or rr >= rows or cc < 0 or cc >= cols:
                            ok = False
                            break
                        i = _cell_index(rr, cc, cols)
                        coords.append((rr, cc))
                        m |= _bit(i)
                    if not ok:
                        continue

                    # Fast region membership check: placement must be subset of region
                    if (m & region_mask) != m:
                        continue

                    # Precompute adj mask + blocks
                    adj = 0
                    blk_set = set()
                    for (rr, cc) in coords:
                        i = _cell_index(rr, cc, cols)
                        adj |= neighbor_mask[i]
                        adj &= ~m
                        for b in blocks_by_cell[i]:
                            blk_set.add(b)

                    placements[rid].append(
                        Placement(
                            region_id=rid,
                            shape=shape,
                            mask=m,
                            adj_mask=adj,
                            blocks=tuple(blk_set),
                            cells=tuple(coords),
                        )
                    )

    # De-dup by (shape, mask) per region
    for rid, ps in placements.items():
        uniq: Dict[Tuple[str, int], Placement] = {}
        for p in ps:
            uniq[(p.shape, p.mask)] = p
        placements[rid] = list(uniq.values())

    return placements

# ----------------------------
# Fast global constraints (bitmasks)
# ----------------------------

def _violates_2x2_mask(filled_mask: int, p: Placement) -> bool:
    merged = filled_mask | p.mask
    for b in p.blocks:
        if (merged & b) == b:
            return True
    return False


def _violates_same_shape_adjacency_mask(shape_filled: Dict[str, int], p: Placement) -> bool:
    existing = shape_filled.get(p.shape, 0)
    return (existing & p.adj_mask) != 0


# ----------------------------
# Unified solver: find solution and/or count solutions (optimized)
# ----------------------------

def _solve_or_count(
    placements: Dict[int, List[Placement]],
    *,
    limit: int,
    n_cells: int,
    rng: Optional[random.Random] = None,
    want_solution: bool = False,
):
    """
    If want_solution=False: returns count up to limit (int).
    If want_solution=True : returns (count_up_to_limit, solution_dict_or_None).

    Correct forward-checking:
      - 2x2 impact via blocks touched by placement
      - same-shape adjacency impact via neighbor cells (p.adj_mask), not p.mask
    """
    region_ids = list(placements.keys())
    region_ids.sort(key=lambda rid: len(placements[rid]))

    # ---- Dependency maps ----
    # block_mask -> regions that have placements that touch that block
    block_to_regions: Dict[int, Set[int]] = {}

    # cell_index -> regions that have placements that place a cell at that index
    cell_to_regions: List[Set[int]] = [set() for _ in range(n_cells)]

    for rid, ps in placements.items():
        for p in ps:
            for b in p.blocks:
                block_to_regions.setdefault(b, set()).add(rid)

            # register every cell the placement might occupy
            m = p.mask
            while m:
                lsb = m & -m
                i = lsb.bit_length() - 1
                if i < n_cells:
                    cell_to_regions[i].add(rid)
                m ^= lsb

    # ---- Solver state ----
    chosen: Dict[int, Placement] = {}
    filled_mask: int = 0
    shape_filled: Dict[str, int] = {}

    # Domains begin as all placements; we forward-check by replacing lists
    domains: Dict[int, List[Placement]] = {rid: list(ps) for rid, ps in placements.items()}

    found_solution: Optional[Dict[int, Placement]] = None

    # Localize for speed
    violates_2x2 = _violates_2x2_mask
    violates_adj = _violates_same_shape_adjacency_mask

    def is_valid(p: Placement) -> bool:
        if violates_2x2(filled_mask, p):
            return False
        if violates_adj(shape_filled, p):
            return False
        return True

    def pick_next_region_and_opts():
        # MRV: compute current valid options from domain (cheap bit checks)
        best_rid = None
        best_opts: Optional[List[Placement]] = None

        for rid in region_ids:
            if rid in chosen:
                continue
            opts = [p for p in domains[rid] if is_valid(p)]
            if best_opts is None or len(opts) < len(best_opts):
                best_rid = rid
                best_opts = opts
                if len(best_opts) == 0:
                    return None, None
                if len(best_opts) == 1:
                    return best_rid, best_opts
        return best_rid, best_opts

    def affected_regions_by(p: Placement) -> Set[int]:
        aff: Set[int] = set()

        # 2x2: any region whose placements touch blocks p touches
        for b in p.blocks:
            rs = block_to_regions.get(b)
            if rs:
                aff |= rs

        # same-shape adjacency: any region whose placements occupy neighbor cells of p
        # THIS is the correctness fix: use p.adj_mask, not p.mask
        adj = p.adj_mask
        while adj:
            lsb = adj & -adj
            i = lsb.bit_length() - 1
            if i < n_cells:
                aff |= cell_to_regions[i]
            adj ^= lsb

        return aff

    def backtrack() -> int:
        nonlocal filled_mask, found_solution

        if len(chosen) == len(region_ids):
            if want_solution and found_solution is None:
                found_solution = dict(chosen)
            return 1

        rid, opts = pick_next_region_and_opts()
        if rid is None or opts is None:
            return 0

        if rng is not None:
            rng.shuffle(opts)

        total = 0
        for p in opts:
            # Save state
            filled_before = filled_mask
            prev_shape_mask = shape_filled.get(p.shape, 0)

            # Place
            chosen[rid] = p
            filled_mask = filled_before | p.mask
            shape_filled[p.shape] = prev_shape_mask | p.mask

            # Forward-check only affected regions
            aff = affected_regions_by(p)
            aff.discard(rid)  # assigned

            domain_snapshots: Dict[int, List[Placement]] = {}
            failed = False

            for ar in aff:
                if ar in chosen:
                    continue
                old_dom = domains[ar]
                domain_snapshots[ar] = old_dom
                new_dom = [q for q in old_dom if is_valid(q)]
                domains[ar] = new_dom
                if not new_dom:
                    failed = True
                    break

            if not failed:
                total += backtrack()

            # Undo domains
            for ar, old_dom in domain_snapshots.items():
                domains[ar] = old_dom

            # Undo placement
            del chosen[rid]
            filled_mask = filled_before
            if prev_shape_mask == 0:
                del shape_filled[p.shape]
            else:
                shape_filled[p.shape] = prev_shape_mask

            if total >= limit:
                return total

        return total

    cnt = backtrack()
    if want_solution:
        return cnt, found_solution
    return cnt


def _count_solutions(
    regions: List[List[int]],  # kept for compatibility; not used now
    placements: Dict[int, List[Placement]],
    *,
    limit: int = 2,
    rng: Optional[random.Random] = None,
) -> int:
    return _solve_or_count(placements, limit=limit, rng=rng, want_solution=False)


# ----------------------------
# Public generator
# ----------------------------

@dataclass(frozen=True)
class LITSPuzzle:
    regions: List[List[int]]                    # region id map
    solution_shape: List[List[Optional[str]]]   # "L","I","T","S" on filled cells, None on empty
    solution_filled: List[List[bool]]           # True = filled (part of tetromino)
    placements: Dict[int, Placement]            # chosen placement per region


def generate_lits(
    rows: int,
    cols: int,
    *,
    seed: Optional[int] = None,
    min_region_size: int = 5,
    max_region_size: int = 9,
    ensure_unique: bool = True,
    max_region_attempts: int = 2000,
    max_solve_attempts_per_region_map: int = 500,
) -> LITSPuzzle:
    """
    Generates a LITS puzzle:
      - Random connected regions
      - One tetromino placement per region (L/I/T/S)
      - No 2x2 filled blocks
      - Same shapes cannot touch by edges

    Returns:
      regions map + full solution (filled cells + their shape labels)
    """
    if rows <= 0 or cols <= 0:
        raise ValueError("rows and cols must be positive.")
    rng = random.Random(seed)

    for _ in range(max_region_attempts):
        region_map = _make_regions(
            rows, cols, rng,
            min_region_size=min_region_size,
            max_region_size=max_region_size,
        )

        placements = _enumerate_region_placements(region_map)

        # quick feasibility check: every region must have at least 1 placement
        if any(len(ps) == 0 for ps in placements.values()):
            continue

        # Find one solution (randomized) and optionally enforce uniqueness
        for _ in range(max_solve_attempts_per_region_map):
            cnt1, sol = _solve_or_count(placements, limit=1, n_cells=rows*cols, rng=rng, want_solution=True)
            if cnt1 == 0 or sol is None:
                continue

            if ensure_unique:
                cnt = _solve_or_count(placements, limit=2, n_cells=rows*cols, rng=None, want_solution=False)
                if cnt != 1:
                    continue

            # Build solution grids
            sol_shape: List[List[Optional[str]]] = [[None for _ in range(cols)] for _ in range(rows)]
            sol_filled: List[List[bool]] = [[False for _ in range(cols)] for _ in range(rows)]
            for p in sol.values():
                for (r, c) in p.cells:
                    sol_shape[r][c] = p.shape
                    sol_filled[r][c] = True

            return LITSPuzzle(
                regions=region_map,
                solution_shape=sol_shape,
                solution_filled=sol_filled,
                placements=sol,
            )

    raise RuntimeError("Failed to generate a LITS puzzle. Try different seed/params.")


# ----------------------------
# Pretty printers (debug)
# ----------------------------

def print_regions(regions: List[List[int]]) -> None:
    w = max(2, len(str(max(x for row in regions for x in row))))
    for row in regions:
        print(" ".join(str(x).rjust(w) for x in row))


def print_solution(sol_shape: List[List[Optional[str]]]) -> None:
    for row in sol_shape:
        print(" ".join((x if x is not None else ".") for x in row))


if __name__ == "__main__":
    p = generate_lits(
        6, 7,
        seed=678566,
        min_region_size=4,
        max_region_size=9,
        ensure_unique=True,
    )

    print("REGIONS:")
    print_regions(p.regions)
    print("\nSOLUTION (letters on filled cells):")
    print_solution(p.solution_shape)
