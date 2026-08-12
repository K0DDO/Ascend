"""
ascend_srs_v1 — minimal stability-based SRS.

Public API:
    initial_state(difficulty) -> SRSState
    apply(state, signal, now)  -> SRSState
    retrievability(state, now) -> float   (0..1)
    due_at(state)              -> datetime

User sees only: Повторить | Знаю
Algorithm is fully invisible.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from datetime import UTC, datetime, timedelta
from typing import Final

ALGORITHM_VERSION: Final[str] = "ascend_srs_v1"

# ── Constants (bump version if changed) ───────────────────────────────────────
MIN_INTERVAL_FAIL: Final[float] = 10 / 60  # 10 minutes in hours
MIN_INTERVAL_KNOW: Final[float] = 16.0     # hours
MAX_INTERVAL: Final[float] = 24 * 365.0    # 1 year in hours
INITIAL_STABILITY: Final[float] = 1.5      # hours until ~90% retention
STABILITY_GROW_FACTOR: Final[float] = 2.4
STABILITY_DECAY_ON_FAIL: Final[float] = 0.4
DIFFICULTY_ADJUST_KNOW: Final[float] = -0.05
DIFFICULTY_ADJUST_FAIL: Final[float] = 0.12
MIN_DIFFICULTY: Final[float] = 0.1
MAX_DIFFICULTY: Final[float] = 1.0
TARGET_RETENTION: Final[float] = 0.9
# FSRS-inspired: R(t) = e^(-t / S)  where S = stability


@dataclass(frozen=True)
class SRSState:
    stability: float          # hours until ~e^-1 ≈ 37% retention; think of it as "memory strength"
    difficulty: float         # 0.1 (easy) … 1.0 (hard)
    interval_h: float         # scheduled interval in hours
    reps: int                 # successful "know" reps
    lapses: int               # "repeat" hits
    due_at: datetime
    last_reviewed_at: datetime
    algorithm_version: str = ALGORITHM_VERSION

    @property
    def is_new(self) -> bool:
        return self.reps == 0 and self.lapses == 0


def initial_state(card_difficulty: float, now: datetime | None = None) -> SRSState:
    now = now or datetime.now(UTC)
    difficulty = _clamp(card_difficulty, MIN_DIFFICULTY, MAX_DIFFICULTY)
    interval_h = _first_interval(difficulty)
    return SRSState(
        stability=INITIAL_STABILITY,
        difficulty=difficulty,
        interval_h=interval_h,
        reps=0,
        lapses=0,
        due_at=now + timedelta(hours=interval_h),
        last_reviewed_at=now,
    )


def apply(state: SRSState, signal: "ReviewSignalInput", now: datetime | None = None) -> SRSState:
    now = now or datetime.now(UTC)

    if signal.result == "repeat":
        return _apply_repeat(state, signal, now)
    return _apply_know(state, signal, now)


def retrievability(state: SRSState, now: datetime | None = None) -> float:
    """Fraction of memory retained: 1.0 = perfect, 0.0 = forgotten."""
    now = now or datetime.now(UTC)
    elapsed_h = max(0.0, (now - state.last_reviewed_at).total_seconds() / 3600)
    return math.exp(-elapsed_h / max(state.stability, 0.001))


def due_at(state: SRSState) -> datetime:
    return state.due_at


# ── Internal ──────────────────────────────────────────────────────────────────

@dataclass
class ReviewSignalInput:
    result: str           # "repeat" | "know"
    question_ms: int = 0
    answer_ms: int = 0
    source_opened: bool = False
    card_difficulty: float = 0.5


def _apply_know(state: SRSState, signal: ReviewSignalInput, now: datetime) -> SRSState:
    confidence = _confidence_score(signal)

    # Grow stability based on confidence
    new_stability = state.stability * (STABILITY_GROW_FACTOR * confidence)
    new_stability = _clamp(new_stability, MIN_INTERVAL_KNOW, MAX_INTERVAL)

    # Ease on difficulty with each successful recall
    new_difficulty = _clamp(state.difficulty + DIFFICULTY_ADJUST_KNOW * confidence, MIN_DIFFICULTY, MAX_DIFFICULTY)

    interval_h = _schedule_interval(new_stability, new_difficulty)
    return SRSState(
        stability=new_stability,
        difficulty=new_difficulty,
        interval_h=interval_h,
        reps=state.reps + 1,
        lapses=state.lapses,
        due_at=now + timedelta(hours=interval_h),
        last_reviewed_at=now,
    )


def _apply_repeat(state: SRSState, signal: ReviewSignalInput, now: datetime) -> SRSState:
    new_stability = max(state.stability * STABILITY_DECAY_ON_FAIL, INITIAL_STABILITY * 0.5)
    new_difficulty = _clamp(state.difficulty + DIFFICULTY_ADJUST_FAIL, MIN_DIFFICULTY, MAX_DIFFICULTY)
    interval_h = MIN_INTERVAL_FAIL
    return SRSState(
        stability=new_stability,
        difficulty=new_difficulty,
        interval_h=interval_h,
        reps=state.reps,
        lapses=state.lapses + 1,
        due_at=now + timedelta(hours=interval_h),
        last_reviewed_at=now,
    )


def _confidence_score(signal: ReviewSignalInput) -> float:
    """0.5 (weak) … 1.0 (strong), based on timing + source_opened."""
    score = 1.0

    total_ms = signal.question_ms + signal.answer_ms
    # Very fast answer (< 3s total) — possibly not thinking deeply
    if total_ms < 3_000:
        score *= 0.75
    # Very slow answer (> 60s) — likely struggled
    elif total_ms > 60_000:
        score *= 0.82

    # Source opened → weaker recall
    if signal.source_opened:
        score *= 0.65

    # Long answer time (reading vs recalling)
    if signal.answer_ms > signal.question_ms * 2 and signal.answer_ms > 10_000:
        score *= 0.85

    return _clamp(score, 0.5, 1.0)


def _first_interval(difficulty: float) -> float:
    """Interval for a brand-new card: easier → longer first interval."""
    base = MIN_INTERVAL_KNOW
    return _clamp(base * (1.5 - difficulty), MIN_INTERVAL_KNOW * 0.5, MIN_INTERVAL_KNOW * 2)


def _schedule_interval(stability: float, difficulty: float) -> float:
    """Target retention ≥ TARGET_RETENTION: t = -S * ln(R_target).

    stability is in hours (time to ~37% retention via R=e^{-t/S}).
    To achieve R_target=0.9: t = -S * ln(0.9) ≈ S * 0.105.
    We then multiply by 9 to make intervals human-meaningful (days range).
    """
    t = -stability * math.log(TARGET_RETENTION) * 9.0
    # Harder cards get shorter intervals as safety margin
    t *= (1.0 - difficulty * 0.3)
    return _clamp(t, MIN_INTERVAL_KNOW, MAX_INTERVAL)


def _clamp(value: float, lo: float, hi: float) -> float:
    return max(lo, min(hi, value))
