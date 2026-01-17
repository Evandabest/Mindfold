from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, List, Optional, Tuple
import random

# ============================
# "Tower" (Mastermind) SECRET generator
# + solvable-within-attempts guarantee (via internal solver)
# ============================
# - Secret is a length-N sequence of color indices [0..num_colors-1]
# - Repeats allowed if allow_repeats=True
# - We DO implement internal scoring/solver ONLY to verify "solvable within attempts".
#   Your Swift frontend can still implement scoring; this is generator-side validation.

Code = Tuple[int, ...]
Feedback = Tuple[int, int]  # (exact_matches, color_only_matches)


@dataclass(frozen=True)
class MastermindConfig:
    code_len: int = 4
    num_colors: int = 4          # screenshot shows 4 colors; change if needed
    allow_repeats: bool = True   # screenshot says repeats allowed


@dataclass(frozen=True)
class MastermindSecret:
    config: MastermindConfig
    code: Code                   # each int in [0..num_colors-1]
    max_attempts: int            # UI can use this to render attempt rows / difficulty


# ----------------------------
# Utilities: all codes + feedback
# ----------------------------
def _all_codes(cfg: MastermindConfig) -> List[Code]:
    if cfg.allow_repeats:
        # Cartesian product of [0..C-1]^N
        out: List[Code] = []
        base = list(range(cfg.num_colors))

        def rec(prefix: List[int]) -> None:
            if len(prefix) == cfg.code_len:
                out.append(tuple(prefix))
                return
            for v in base:
                prefix.append(v)
                rec(prefix)
                prefix.pop()

        rec([])
        return out
    else:
        # permutations without repetition
        # (for small sizes, just generate via recursion)
        out: List[Code] = []
        base = list(range(cfg.num_colors))

        def rec(prefix: List[int], used: List[bool]) -> None:
            if len(prefix) == cfg.code_len:
                out.append(tuple(prefix))
                return
            for i, v in enumerate(base):
                if not used[i]:
                    used[i] = True
                    prefix.append(v)
                    rec(prefix, used)
                    prefix.pop()
                    used[i] = False

        rec([], [False] * len(base))
        return out


def _feedback(guess: Code, secret: Code, num_colors: int) -> Feedback:
    """
    Standard Mastermind scoring:
      - exact: same color, same position
      - color_only: correct color, wrong position (with multiplicity), excluding exacts
    """
    exact = 0
    # counts excluding exact matches
    g_count = [0] * num_colors
    s_count = [0] * num_colors

    for g, s in zip(guess, secret):
        if g == s:
            exact += 1
        else:
            g_count[g] += 1
            s_count[s] += 1

    color_only = 0
    for c in range(num_colors):
        color_only += min(g_count[c], s_count[c])

    return (exact, color_only)


# ----------------------------
# Solver used ONLY for "solvable within attempts" validation
# ----------------------------
def _solve_steps_needed(cfg: MastermindConfig, secret: Code) -> int:
    """
    Returns how many guesses a deterministic solver needs to find `secret`.

    Strategy:
      - Maintain candidate set S of possible secrets.
      - Pick a guess that minimizes the *worst-case* size of S after feedback (minimax).
      - Guess from the universe of all codes (works well for small spaces like 4^4=256).
    """
    universe = _all_codes(cfg)
    candidates = universe[:]  # possible secrets remaining

    # A decent fixed first guess improves consistency (classic for 4 pegs is 0011-ish)
    # If fewer than 2 colors, config validation should have blocked it.
    if cfg.num_colors >= 2 and cfg.code_len >= 4:
        first = tuple([0, 0, 1, 1] + [0] * (cfg.code_len - 4))
    else:
        first = tuple([0] * cfg.code_len)

    guesses = 0
    guess = first

    # Precompute feedback table for speed: fb[(g_idx, s_idx)] -> Feedback
    # For small spaces this is fine.
    fb_table: Dict[Tuple[int, int], Feedback] = {}
    idx_of = {code: i for i, code in enumerate(universe)}
    s_idx = idx_of[secret]

    def fb_idx(g_idx: int, s_idx_: int) -> Feedback:
        key = (g_idx, s_idx_)
        if key not in fb_table:
            fb_table[key] = _feedback(universe[g_idx], universe[s_idx_], cfg.num_colors)
        return fb_table[key]

    while True:
        guesses += 1
        g_idx = idx_of[guess]
        fb = fb_idx(g_idx, s_idx)

        # Found it
        if fb[0] == cfg.code_len:
            return guesses

        # Filter candidates consistent with this feedback
        new_candidates: List[Code] = []
        for cand in candidates:
            if _feedback(guess, cand, cfg.num_colors) == fb:
                new_candidates.append(cand)
        candidates = new_candidates

        # Choose next guess by minimax (minimize worst-case remaining candidates)
        # If only one candidate remains, pick it.
        if len(candidates) == 1:
            guess = candidates[0]
            continue

        # Build a quick index list for candidates to avoid repeated tuple hashing.
        cand_indices = [idx_of[c] for c in candidates]

        best_guess: Optional[Code] = None
        best_worst = 10**18
        best_is_candidate = False

        for g in universe:
            g_i = idx_of[g]
            buckets: Dict[Feedback, int] = {}
            worst = 0

            for c_i in cand_indices:
                f = fb_idx(g_i, c_i)
                buckets[f] = buckets.get(f, 0) + 1
                if buckets[f] > worst:
                    worst = buckets[f]
                    if worst >= best_worst:
                        break  # prune

            if worst < best_worst:
                best_worst = worst
                best_guess = g
                best_is_candidate = (g in candidates)
            elif worst == best_worst and best_guess is not None:
                # Tie-break: prefer a guess that is actually a remaining candidate
                g_is_candidate = (g in candidates)
                if g_is_candidate and not best_is_candidate:
                    best_guess = g
                    best_is_candidate = True

        # Safety (should never happen)
        guess = best_guess if best_guess is not None else candidates[0]


# ============================
# Generator
# ============================
def generate_mastermind_secret(
    *,
    seed: Optional[int] = None,
    config: MastermindConfig = MastermindConfig(),
    avoid_trivial: bool = True,
    max_attempts: int = 10,
    enforce_solvable_within_attempts: bool = True,
    max_tries: int = 50_000,
) -> MastermindSecret:
    """
    Generate a secret code for a Mastermind/Tower puzzle, with an optional guarantee
    that it is solvable (by our deterministic solver) within `max_attempts`.

    Returns:
      MastermindSecret(config=..., code=(...), max_attempts=max_attempts)

    Notes:
      - Colors are integers 0..num_colors-1 (map these to UI colors in Swift).
      - "Solvable within attempts" here means: our built-in solver can deduce the
        secret within max_attempts guesses (not just "possible in theory").
    """
    if config.code_len <= 0:
        raise ValueError("code_len must be positive.")
    if config.num_colors <= 1:
        raise ValueError("num_colors must be >= 2.")
    if max_attempts <= 0:
        raise ValueError("max_attempts must be positive.")
    if not config.allow_repeats and config.num_colors < config.code_len:
        raise ValueError("num_colors must be >= code_len when repeats are disallowed.")

    rng = random.Random(seed)

    def is_trivial(code: Code) -> bool:
        if not avoid_trivial:
            return False

        # Avoid all same color
        uniq = len(set(code))
        if uniq == 1:
            return True

        # If repeats allowed, optionally avoid extreme repetition like 3-of-a-kind in length 4
        if config.allow_repeats:
            freq: Dict[int, int] = {}
            for x in code:
                freq[x] = freq.get(x, 0) + 1
            if max(freq.values()) >= config.code_len - 1:  # e.g., 3 same in a 4 code
                return True

        return False

    for _ in range(max_tries):
        if config.allow_repeats:
            code = tuple(rng.randrange(config.num_colors) for _ in range(config.code_len))
        else:
            code = tuple(rng.sample(range(config.num_colors), k=config.code_len))

        if is_trivial(code):
            continue

        if enforce_solvable_within_attempts:
            steps = _solve_steps_needed(config, code)
            if steps > max_attempts:
                continue

        return MastermindSecret(config=config, code=code, max_attempts=max_attempts)

    raise RuntimeError(
        "Failed to generate a secret solvable within the requested attempts; "
        "try increasing max_attempts, increasing max_tries, or changing seed/config."
    )


# Example usage
if __name__ == "__main__":
    cfg = MastermindConfig(code_len=4, num_colors=4, allow_repeats=True)
    secret = generate_mastermind_secret(
        seed=42,
        config=cfg,
        avoid_trivial=True,
        max_attempts=6,
        enforce_solvable_within_attempts=True,
    )
    print(secret.code, "attempts:", secret.max_attempts)
