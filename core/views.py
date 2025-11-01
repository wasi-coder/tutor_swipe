from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login, logout
from .forms import UserForm, ProfileForm, MessageForm
from .models import Profile, Swipe, Match, ChatMessage
from django.contrib.auth.models import User
from django.contrib import messages
from django.http import JsonResponse, HttpResponseForbidden
from django.db import IntegrityError, transaction
from django.views.decorators.http import require_POST
from django.contrib.auth.decorators import login_required

def index(request):
    if request.user.is_authenticated:
        return redirect('core:swipe_feed')
    return render(request, 'core/index.html')

def register(request):
    if request.method == 'POST':
        user_form = UserForm(request.POST)
        profile_form = ProfileForm(request.POST, request.FILES)
        if user_form.is_valid() and profile_form.is_valid():
            user = user_form.save(commit=False)
            user.set_password(user_form.cleaned_data['password'])
            user.save()
            profile = profile_form.save(commit=False)
            profile.user = user
            profile.save()
            messages.success(request, 'Registered. You can log in now.')
            return redirect('core:login')
    else:
        user_form = UserForm()
        profile_form = ProfileForm()
    return render(request, 'core/register.html', {'user_form': user_form, 'profile_form': profile_form})

def login_view(request):
    if request.method == 'POST':
        u = request.POST.get('username')
        p = request.POST.get('password')
        user = authenticate(request, username=u, password=p)
        if user:
            login(request, user)
            return redirect('core:swipe_feed')
        messages.error(request, 'Invalid credentials')
    return render(request, 'core/login.html')

def logout_view(request):
    logout(request)
    return redirect('core:index')

def profile_view(request, user_id):
    user = get_object_or_404(User, pk=user_id)
    profile = getattr(user, 'profile', None)
    return render(request, 'core/profile_view.html', {'profile_user': user, 'profile': profile})

@login_required
def swipe_feed(request):
    # Only students swipe teachers for this MVP
    try:
        if request.user.profile.role != 'student':
            return render(request, 'core/forbidden.html', status=403)
    except Profile.DoesNotExist:
        messages.error(request, 'Complete your profile')
        return redirect('core:profile_view', user_id=request.user.id)

    # Filters from GET
    subject = request.GET.get('subject', '').strip()
    max_rate = request.GET.get('max_rate', '').strip()
    location = request.GET.get('location', '').strip()

    swiped_ids = Swipe.objects.filter(from_user=request.user).values_list('to_user_id', flat=True)
    qs = User.objects.filter(profile__role='teacher').exclude(id__in=swiped_ids)

    if subject:
        qs = qs.filter(profile__subjects__icontains=subject)
    if max_rate:
        try:
            max_rate_val = int(max_rate)
            qs = qs.filter(profile__rate__lte=max_rate_val)
        except ValueError:
            pass
    if location:
        qs = qs.filter(profile__location__icontains=location)

    teachers = qs.order_by('-profile__rating')  # order by rating as simple heuristic

    return render(request, 'core/swipe_feed.html', {
        'teachers': teachers,
        'filter_subject': subject,
        'filter_max_rate': max_rate,
        'filter_location': location,
    })

@require_POST
@login_required
def swipe_action(request):
    to_user_id = int(request.POST.get('to_user_id'))
    direction = request.POST.get('direction')  # "left" or "right"
    to_user = get_object_or_404(User, pk=to_user_id)

    try:
        with transaction.atomic():
            swipe, created = Swipe.objects.get_or_create(from_user=request.user, to_user=to_user, defaults={'direction': direction})
            if not created:
                swipe.direction = direction
                swipe.save()

            # If right, check reciprocal or auto_accept
            if direction == 'right':
                reciprocal = Swipe.objects.filter(from_user=to_user, to_user=request.user, direction='right').first()
                teacher_profile = getattr(to_user, 'profile', None)
                if reciprocal or (teacher_profile and teacher_profile.auto_accept):
                    # create match (student is requester)
                    student = request.user
                    teacher = to_user
                    if student.profile.role == 'teacher':
                        student, teacher = teacher, student
                    Match.objects.get_or_create(student=student, teacher=teacher)
    except IntegrityError:
        return JsonResponse({'error': 'db_error'}, status=500)

    return JsonResponse({'status': 'ok'})

@login_required
def matches_list(request):
    as_student = Match.objects.filter(student=request.user)
    as_teacher = Match.objects.filter(teacher=request.user)
    return render(request, 'core/matches_list.html', {'as_student': as_student, 'as_teacher': as_teacher})

@login_required
def chat_view(request, match_id):
    match = get_object_or_404(Match, pk=match_id)
    if request.user != match.student and request.user != match.teacher:
        return render(request, 'core/forbidden.html', status=403)
    form = MessageForm()
    messages_qs = match.messages.order_by('created_at')
    return render(request, 'core/chat_view.html', {'match': match, 'messages': messages_qs, 'form': form})

# Teacher dashboard
@login_required
def teacher_dashboard(request):
    try:
        if request.user.profile.role != 'teacher':
            return render(request, 'core/forbidden.html', status=403)
    except Profile.DoesNotExist:
        return redirect('core:profile_view', user_id=request.user.id)

    # incoming likes: swipes where to_user==current & direction=='right' and no match exists yet
    incoming_swipes = Swipe.objects.filter(to_user=request.user, direction='right').exclude(from_user__matches_as_student__teacher=request.user)
    # outgoing matches (for display)
    matches = Match.objects.filter(teacher=request.user)
    return render(request, 'core/teacher_dashboard.html', {'incoming_swipes': incoming_swipes, 'matches': matches, 'profile': request.user.profile})

@require_POST
@login_required
def teacher_accept(request):
    if request.user.profile.role != 'teacher':
        return HttpResponseForbidden()
    from_user_id = int(request.POST.get('from_user_id'))
    action = request.POST.get('action')  # accept/reject
    from_user = get_object_or_404(User, pk=from_user_id)
    if action == 'accept':
        # create match if not exists
        student = from_user
        teacher = request.user
        Match.objects.get_or_create(student=student, teacher=teacher)
        # optionally notify student (left as exercise)
        return JsonResponse({'status': 'accepted'})
    else:
        # reject: remove the swipe or mark it
        Swipe.objects.filter(from_user=from_user, to_user=request.user).delete()
        return JsonResponse({'status': 'rejected'})

@require_POST
@login_required
def toggle_auto_accept(request):
    if request.user.profile.role != 'teacher':
        return HttpResponseForbidden()
    profile = request.user.profile
    profile.auto_accept = not profile.auto_accept
    profile.save()
    return JsonResponse({'auto_accept': profile.auto_accept})