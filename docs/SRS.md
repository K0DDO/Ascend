# Ascend SRS Architecture

## Product constraint

User never sees intervals, stability, or SM-2 grades.

Only:

- **Повторить** (`repeat`)
- **Знаю** (`know`)

All scheduling is algorithmic and invisible.

---

## Domain types

```text
ReviewSignal
  result: repeat | know
  question_ms
  answer_ms
  total_ms
  source_opened: bool
  source_ms
  front_length
  back_length
  card_difficulty
  history_summary

CardMemoryState
  stability
  difficulty
  due_at
  interval
  reps
  lapses
  last_reviewed_at
  algorithm_version

SRSAlgorithm (interface)
  initial_state(card) -> CardMemoryState
  apply(state, signal, now) -> CardMemoryState
  retrievability(state, now) -> float
```

Implementations live in `backend/app/srs` and mirrored in `mobile/lib/domain/srs`.

UI depends only on the interface.

---

## Signal interpretation (v1 heuristics)

Normalize times by content length & difficulty before scoring.

| Observation | Interpretation |
|-------------|----------------|
| Long time on question + Know | Effortful recall — medium confidence |
| Short question time + short answer + Know | Strong recall |
| Short question + long answer + Know | Reading/learning — weak |
| Source opened | Strong evidence of insufficient recall |
| Repeat | Schedule relearning / short interval |
| Success streak | Increase stability carefully |
| Recent lapses | Increase difficulty, shorten interval |

**Never** use raw milliseconds alone.

---

## Scheduling requirements

| Parameter | Rule |
|-----------|------|
| min_interval | e.g. minutes–hours for fails |
| max_interval | hard cap (no “forever”) |
| forgetting | if retrievability drops or overdue performance worsens → due again |
| relearning | failed cards re-enter short cycle |
| new cards | gated by topic prerequisites |

Exact constants versioned as `ascend_srs_v1`; changing constants bumps version.

---

## Optimal Learning queue

Merge:

1. Relearning / forgotten
2. Due reviews
3. Weak cards (low retrievability / mastery)
4. New cards (prerequisite-satisfied only)

Ordering respects topic DAG: never introduce Advanced before Fundamentals.

---

## Mastery vs SRS

| System | Question |
|--------|----------|
| SRS | How well is this card remembered over time? |
| Mastery | Topic competence from retention + recency + difficulty + failures + AI scores |
| AI Interview | Can the user explain independently? |

Mastery is a **separate scorer** consuming SRS + AI + history — pluggable.

---

## Testing mandate

- Unit tests for apply() edge cases
- Property: max_interval never exceeded
- Property: Repeat never increases interval
- Multi-event merge ordering tests
- Length normalization tests

---

## Non-goals for v1

- Exposing “Why this card?” debug to students (mentor/admin only later)
- User-tunable ease factors
- FSRS grade buttons in UI
