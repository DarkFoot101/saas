from django.shortcuts import render
from django.http import HttpResponse
from visits.models import PageVisit

def home_page_view(request, *args, **kwargs):
    qs = PageVisit.objects.all()
    page_qs = PageVisit.objects.filter(path = request.path)
    
    my_title = "my page"
    my_context = {
        'page_title' : my_title,
        "page_visit_count" : qs.count(),
        "percent" : (page_qs.count() * 100.0) / qs.count(),
        "total_visit_count" : qs.count(), 
    }
    html_template = 'home.html'
    PageVisit.objects.create(path = request.path)

    return render(request, html_template, my_context)
