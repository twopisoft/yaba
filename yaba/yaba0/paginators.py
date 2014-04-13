from django.core.paginator import Paginator

class BmPaginator(Paginator):
    def validate_number(self, number):
        try:
            if (number=='last'):
                number = self.num_pages
            else:
                number = int(number)
                if (number < 1):
                    number = 1
                elif (number > self.num_pages):
                    number = self.num_pages
        except (TypeError, ValueError):
            number = 1

        return number