from django.urls import re_path
from . import consumers

websocket_urlpatterns = [
    # Chat websocket per match id, path: /ws/chat/<match_id>/
    re_path(r'ws/chat/(?P<match_id>\d+)/$', consumers.ChatConsumer.as_asgi()),
]