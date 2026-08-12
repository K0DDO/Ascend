from pydantic import BaseModel


class AchievementItem(BaseModel):
    key: str
    title: str
    unlocked: bool
    progress: float  # 0..1


class GamificationOverviewResponse(BaseModel):
    streak_days: int
    xp_total: int
    xp_today: int
    daily_goal_reviews: int
    daily_progress_reviews: int
    achievements: list[AchievementItem]
