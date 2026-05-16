from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.date import DateTrigger
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)

class NotificationScheduler:
    def __init__(self):
        self.scheduler = BackgroundScheduler()
        self.scheduler.start()

    def schedule_reminder(self, to: str, order_id: str, minutes_before: int, run_at: datetime, callback):
        """
        Schedule a reminder message.
        """
        job_id = f"reminder_{order_id}_{minutes_before}"
        self.scheduler.add_job(
            callback,
            trigger=DateTrigger(run_date=run_at),
            args=[to, order_id],
            id=job_id,
            replace_existing=True
        )
        logger.info(f"Scheduled reminder {job_id} for {run_at}")

notification_scheduler = NotificationScheduler()
