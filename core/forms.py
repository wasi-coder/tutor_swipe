from django import forms
from django.contrib.auth.models import User
from .models import Profile, ChatMessage

class UserForm(forms.ModelForm):
    password = forms.CharField(widget=forms.PasswordInput, required=True)
    class Meta:
        model = User
        fields = ('username','email','password','first_name','last_name')

class ProfileForm(forms.ModelForm):
    class Meta:
        model = Profile
        fields = ('role','subjects','rate','bio','photo','location','auto_accept')

class MessageForm(forms.ModelForm):
    class Meta:
        model = ChatMessage
        fields = ('text','attachment')