from __future__ import annotations

from dataclasses import dataclass
from typing import Optional, Tuple
import random

# ============================
# "Tower" (Mastermind) SECRET generator only
# ============================
# - Secret is a length-N sequence of color indices [0..num_colors-1]
# - Repeats allowed if allow_repeats=True
# - No evaluation/scoring logic included (you'll do that in Swift)


@dataclass(frozen=True)
class MastermindConfig:
    code_len: int = 4
    num_colors: int = 4          # screenshot shows 4 colors; change if needed
    allow_repeats: bool = True   # screenshot says repeats allowed


@dataclass(frozen=True)
class MastermindSecret:
    config: MastermindConfig
    code: Tuple[int, ...]        # each int in [0..num_colors-1]


def generate_mastermind_secret(
    *,
    seed: Optional[int] = None,
    config: MastermindConfig = MastermindConfig(),
    avoid_trivial: bool = True,
) -> MastermindSecret:
    """
    Generate a secret code for a Mastermind-style puzzle.

    Returns:
      MastermindSecret(config=..., code=(...))

    Notes:
      - Colors are integers 0..num_colors-1 (map these to UI colors in Swift).
      - If avoid_trivial=True, we avoid very repetitive codes (optional UX tweak).
    """
    if config.code_len <= 0:
        raise ValueError("code_len must be positive.")
    if config.num_colors <= 1:
        raise ValueError("num_colors must be >= 2.")
    if not config.allow_repeats and config.num_colors < config.code_len:
        raise ValueError("num_colors must be >= code_len when repeats are disallowed.")

    rng = random.Random(seed)

    def is_trivial(code: Tuple[int, ...]) -> bool:
        if not avoid_trivial:
            return False

        # Avoid all same color
        uniq = len(set(code))
        if uniq == 1:
            return True

        # If repeats allowed, optionally avoid extreme repetition like 3-of-a-kind in length 4
        if config.allow_repeats:
            freq = {}
            for x in code:
                freq[x] = freq.get(x, 0) + 1
            if max(freq.values()) >= config.code_len - 1:  # e.g., 3 same in a 4 code
                return True

        return False

    max_tries = 10_000
    for _ in range(max_tries):
        if config.allow_repeats:
            code = tuple(rng.randrange(config.num_colors) for _ in range(config.code_len))
        else:
            code = tuple(rng.sample(range(config.num_colors), k=config.code_len))

        if not is_trivial(code):
            return MastermindSecret(config=config, code=code)

    # Fallback: return anything valid
    if config.allow_repeats:
        code = tuple(rng.randrange(config.num_colors) for _ in range(config.code_len))
    else:
        code = tuple(rng.sample(range(config.num_colors), k=config.code_len))
    return MastermindSecret(config=config, code=code)


# Example usage
if __name__ == "__main__":
    cfg = MastermindConfig(code_len=4, num_colors=4, allow_repeats=True)
    secret = generate_mastermind_secret(seed=42, config=cfg, avoid_trivial=True)
    print(secret.code)  # e.g. (2, 0, 3, 1)
