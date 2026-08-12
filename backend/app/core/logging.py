import logging
import sys

from app.core.config import Settings


class _RequestIdFilter(logging.Filter):
    def filter(self, record: logging.LogRecord) -> bool:
        if not hasattr(record, "request_id"):
            record.request_id = "-"
        return True


def configure_logging(settings: Settings) -> None:
    root = logging.getLogger()
    if root.handlers:
        return

    level = getattr(logging, settings.log_level.upper(), logging.INFO)
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(
        logging.Formatter(
            "%(asctime)s %(levelname)s [%(name)s] request_id=%(request_id)s %(message)s"
        )
    )
    handler.addFilter(_RequestIdFilter())
    root.setLevel(level)
    root.addHandler(handler)
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
