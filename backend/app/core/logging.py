import logging
import sys

from app.core.config import Settings


def configure_logging(settings: Settings) -> None:
    root = logging.getLogger()
    if root.handlers:
        return

    level = getattr(logging, settings.log_level.upper(), logging.INFO)
    logging.basicConfig(
        level=level,
        format="%(asctime)s %(levelname)s [%(name)s] request_id=%(request_id)s %(message)s",
        stream=sys.stdout,
        defaults={"request_id": "-"},
    )
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
