# Ascend Backend

FastAPI modular monolith. See `../docs/ARCHITECTURE.md`.

## Quick start

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate          # Windows
pip install -e ".[dev]"

copy .env.example .env
docker compose up -d              # PostgreSQL
alembic upgrade head
uvicorn app.main:app --reload
```

- API: http://127.0.0.1:8000
- Docs: http://127.0.0.1:8000/docs
- Health: http://127.0.0.1:8000/api/v1/health
- Readiness (DB): http://127.0.0.1:8000/api/v1/ready

## Tests

```bash
pytest
```

## Migrations

```bash
alembic revision --autogenerate -m "description"
alembic upgrade head
```

## Layout

```
app/
  main.py           # FastAPI factory
  core/             # config, db, errors, middleware
  models/           # SQLAlchemy models
  api/v1/           # versioned routers
alembic/            # migrations
tests/
```
