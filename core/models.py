from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone

ROLE_CHOICES = (
    ('student', 'Student'),
    ('teacher', 'Teacher'),
)

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='student')
    subjects = models.CharField(max_length=200, blank=True)  # comma-separated subjects for demo
    rate = models.PositiveIntegerField(null=True, blank=True)  # hourly rate
    bio = models.TextField(blank=True)
    photo = models.ImageField(upload_to='profiles/', null=True, blank=True)
    location = models.CharField(max_length=200, blank=True)
    rating = models.FloatField(default=0.0)
    rating_count = models.PositiveIntegerField(default=0)
    auto_accept = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.user.username} ({self.role})"

class Swipe(models.Model):
    from_user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='swipes_from')
    to_user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='swipes_to')
    direction = models.CharField(max_length=5, choices=(('left','left'),('right','right')))
    timestamp = models.DateTimeField(default=timezone.now)

    class Meta:
        unique_together = ('from_user', 'to_user')

    def __str__(self):
        return f"{self.from_user} -> {self.to_user}: {self.direction}"

class Match(models.Model):
    student = models.ForeignKey(User, on_delete=models.CASCADE, related_name='matches_as_student')
    teacher = models.ForeignKey(User, on_delete=models.CASCADE, related_name='matches_as_teacher')
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        unique_together = ('student', 'teacher')

    def __str__(self):
        return f"Match: {self.student} <> {self.teacher}"

class ChatMessage(models.Model):
    match = models.ForeignKey(Match, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(User, on_delete=models.CASCADE)
    text = models.TextField(blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    attachment = models.FileField(upload_to='chat_files/', null=True, blank=True)

    def __str__(self):
        return f"Msg by {self.sender} on {self.created_at}"