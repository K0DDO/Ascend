from datetime import date

from pydantic import BaseModel, Field


class WeakAreaItem(BaseModel):
    topic_id: str
    topic_title: str
    mastery: float = Field(ge=0, le=1)


class ActivityDay(BaseModel):
    day: date
    reviews: int = 0


class ProgressOverviewResponse(BaseModel):
    total_reviews: int
    know_rate: float = Field(ge=0, le=1)
    readiness: float = Field(ge=0, le=1)
    weak_areas: list[WeakAreaItem]
    activity: list[ActivityDay]
