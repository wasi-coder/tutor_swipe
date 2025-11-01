import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth.models import AnonymousUser
from .models import Match, ChatMessage
from django.contrib.auth import get_user_model
from django.utils import timezone

User = get_user_model()

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.match_id = self.scope['url_route']['kwargs']['match_id']
        self.room_group_name = f'chat_{self.match_id}'

        user = self.scope["user"]
        if user.is_anonymous:
            # Reject anonymous connections
            await self.close()
            return

        # Verify user is participant in match
        allowed = await database_sync_to_async(self._is_participant)()
        if not allowed:
            await self.close()
            return

        await self.channel_layer.group_add(self.room_group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.room_group_name, self.channel_name)

    async def receive(self, text_data=None, bytes_data=None):
        if text_data is None:
            return
        data = json.loads(text_data)
        message = data.get('message', '').strip()
        if not message:
            return

        user = self.scope['user']
        # store message in DB
        chat_msg = await database_sync_to_async(self._save_message)(user.id, message)

        payload = {
            'type': 'chat.message',
            'message': message,
            'sender': user.username,
            'timestamp': chat_msg.created_at.isoformat(),
            'sender_id': user.id,
        }
        # broadcast to group
        await self.channel_layer.group_send(self.room_group_name, {
            'type': 'chat_message',
            'payload': payload
        })

    async def chat_message(self, event):
        payload = event['payload']
        await self.send(text_data=json.dumps(payload))

    # sync helpers
    def _is_participant(self):
        try:
            match = Match.objects.get(pk=self.match_id)
        except Match.DoesNotExist:
            return False
        user = self.scope['user']
        return match.student == user or match.teacher == user

    def _save_message(self, user_id, message_text):
        match = Match.objects.get(pk=self.match_id)
        user = User.objects.get(pk=user_id)
        msg = ChatMessage.objects.create(match=match, sender=user, text=message_text, created_at=timezone.now())
        return msg