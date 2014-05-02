from django.core.management.base import NoArgsCommand
from yaba0.reaper import remove_accounts

class Command(NoArgsCommand):
    def handle_noargs(self, **options):
        remove_accounts()