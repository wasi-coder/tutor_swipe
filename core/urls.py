from django.urls import path
from . import views

app_name = 'core'

urlpatterns = [
    path('', views.index, name='index'),
    path('register/', views.register, name='register'),
    path('profile/<int:user_id>/', views.profile_view, name='profile_view'),
    path('swipe/', views.swipe_feed, name='swipe_feed'),
    path('swipe/action/', views.swipe_action, name='swipe_action'),
    path('matches/', views.matches_list, name='matches_list'),
    path('chat/<int:match_id>/', views.chat_view, name='chat_view'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
]