"""Unit tests for ascend_srs_v1 algorithm."""

from datetime import UTC, datetime, timedelta

import pytest

from app.srs.algorithm import (
    MAX_INTERVAL,
    MIN_INTERVAL_FAIL,
    MIN_INTERVAL_KNOW,
    ReviewSignalInput,
    apply,
    initial_state,
    retrievability,
)

NOW = datetime(2026, 8, 12, 10, 0, 0, tzinfo=UTC)


def _know(question_ms=5000, answer_ms=5000, source_opened=False, card_difficulty=0.5):
    return ReviewSignalInput(
        result="know",
        question_ms=question_ms,
        answer_ms=answer_ms,
        source_opened=source_opened,
        card_difficulty=card_difficulty,
    )


def _repeat(card_difficulty=0.5):
    return ReviewSignalInput(result="repeat", card_difficulty=card_difficulty)


# ── initial_state ─────────────────────────────────────────────────────────────

def test_initial_state_sets_due_in_future():
    state = initial_state(0.5, NOW)
    assert state.due_at > NOW


def test_initial_state_reps_zero():
    state = initial_state(0.5, NOW)
    assert state.reps == 0
    assert state.lapses == 0
    assert state.is_new


# ── apply know ────────────────────────────────────────────────────────────────

def test_know_increases_interval():
    # First review on a new card is floored to MIN_INTERVAL_KNOW;
    # second review should grow beyond that floor.
    state = initial_state(0.5, NOW)
    state = apply(state, _know(), NOW)  # first: floor
    new = apply(state, _know(), NOW)    # second: should grow
    assert new.interval_h > MIN_INTERVAL_KNOW


def test_know_increases_reps():
    state = initial_state(0.5, NOW)
    new = apply(state, _know(), NOW)
    assert new.reps == state.reps + 1


def test_know_interval_never_exceeds_max():
    state = initial_state(0.1, NOW)
    for _ in range(30):
        state = apply(state, _know(question_ms=3000, answer_ms=2000), NOW)
    assert state.interval_h <= MAX_INTERVAL


# ── apply repeat ──────────────────────────────────────────────────────────────

def test_repeat_sets_short_interval():
    state = initial_state(0.5, NOW)
    new = apply(state, _repeat(), NOW)
    assert new.interval_h == pytest.approx(MIN_INTERVAL_FAIL)


def test_repeat_never_increases_interval():
    state = initial_state(0.5, NOW)
    # First give it a long interval via knows
    for _ in range(5):
        state = apply(state, _know(), NOW)
    interval_before = state.interval_h
    new = apply(state, _repeat(), NOW)
    assert new.interval_h < interval_before


def test_repeat_increases_lapses():
    state = initial_state(0.5, NOW)
    new = apply(state, _repeat(), NOW)
    assert new.lapses == 1


# ── retrievability ────────────────────────────────────────────────────────────

def test_retrievability_is_one_at_review_time():
    state = initial_state(0.5, NOW)
    ret = retrievability(state, NOW)
    assert ret == pytest.approx(1.0, abs=0.01)


def test_retrievability_decays_over_time():
    state = initial_state(0.5, NOW)
    future = NOW + timedelta(hours=state.stability * 2)
    ret = retrievability(state, future)
    assert ret < 0.9


def test_retrievability_range():
    state = initial_state(0.5, NOW)
    for delta_h in [0, 1, 10, 100, 1000]:
        ret = retrievability(state, NOW + timedelta(hours=delta_h))
        assert 0.0 <= ret <= 1.0


# ── difficulty clamp ──────────────────────────────────────────────────────────

def test_difficulty_clamps_at_bounds():
    state = initial_state(0.5, NOW)
    # Many fails should not push difficulty above 1.0
    for _ in range(20):
        state = apply(state, _repeat(), NOW)
    assert state.difficulty <= 1.0

    state2 = initial_state(0.5, NOW)
    for _ in range(20):
        state2 = apply(state2, _know(), NOW)
    assert state2.difficulty >= 0.1


# ── source_opened penalty ─────────────────────────────────────────────────────

def test_source_opened_gives_shorter_interval_than_clean_know():
    # On a second review the interval is above floor, so difference is visible
    state = initial_state(0.5, NOW)
    state = apply(state, _know(), NOW)  # warm up
    clean = apply(state, _know(source_opened=False), NOW)
    opened = apply(state, _know(source_opened=True), NOW)
    assert opened.interval_h < clean.interval_h
