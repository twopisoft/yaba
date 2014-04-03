from django.core.paginator import Paginator, InvalidPage

class BmPaginator(Paginator):
    def validate_number(self, number):
        try:
            number = super(BmPaginator, self).validate_number(number)
        except InvalidPage:
            number = 1

        return number