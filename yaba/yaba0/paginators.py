from django.core.paginator import Paginator, InvalidPage, EmptyPage

class BmPaginator(Paginator):
    def validate_number(self, number):
        try:
        	if (number=='last'):
        		number = self.num_pages
        	else:
            	number = super(BmPaginator, self).validate_number(number)
        except InvalidPage:
            number = 1
        except EmptyPage:
        	number = 1

        return number