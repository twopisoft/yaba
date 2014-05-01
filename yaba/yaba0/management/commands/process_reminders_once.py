from django.core.management.base import NoArgsCommand
from yaba0.reminders import run_task_once

class Command(NoArgsCommand):
    def handle_noargs(self, **options):
        run_task_once()