from django.contrib import admin
from .models import Profile, Swipe, Match, ChatMessage

@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'role', 'subjects', 'rate')

@admin.register(Swipe)
class SwipeAdmin(admin.ModelAdmin):
    list_display = ('from_user', 'to_user', 'direction', 'timestamp')

@admin.register(Match)
class MatchAdmin(admin.ModelAdmin):
    list_display = ('student', 'teacher', 'created_at')

@admin.register(ChatMessage)
class ChatMessageAdmin(admin.ModelAdmin):
    list_display = ('match', 'sender', 'text', 'timestamp')