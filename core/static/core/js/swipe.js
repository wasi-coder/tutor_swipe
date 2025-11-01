// Minimal swipe interaction for the card stack.
// Updated: no major changes but left intact filter form usage.

document.addEventListener('DOMContentLoaded', () => {
  const stack = document.getElementById('card-stack');
  if (!stack) return;
  let cards = Array.from(stack.querySelectorAll('.swipe-card'));
  cards.forEach((c, i) => c.style.zIndex = cards.length - i);

  function bindCard(card) {
    let offsetX = 0, startX = 0;
    card.classList.add('top');

    function onPointerDown(e) {
      startX = e.clientX || (e.touches && e.touches[0].clientX);
      card.setPointerCapture && card.setPointerCapture(e.pointerId);
      card.style.transition = 'none';
    }
    function onPointerMove(e) {
      const x = (e.clientX || (e.touches && e.touches[0].clientX)) - startX;
      offsetX = x;
      card.style.transform = `translateX(${x}px) rotate(${x * 0.02}deg)`;
      card.style.opacity = `${Math.max(0.4, 1 - Math.abs(x) / 600)}`;
    }
    function onPointerUp(e) {
      try { card.releasePointerCapture && card.releasePointerCapture(e.pointerId); } catch (err) {}
      card.style.transition = 'transform 0.25s ease, opacity 0.25s ease';
      if (offsetX > 150) {
        card.style.transform = `translateX(1200px) rotate(20deg)`;
        sendAction(card.dataset.userId, 'right');
        removeCard(card);
      } else if (offsetX < -150) {
        card.style.transform = `translateX(-1200px) rotate(-20deg)`;
        sendAction(card.dataset.userId, 'left');
        removeCard(card);
      } else {
        card.style.transform = '';
        card.style.opacity = '1';
      }
      offsetX = 0;
    }

    card.addEventListener('pointerdown', onPointerDown);
    card.addEventListener('pointermove', onPointerMove);
    card.addEventListener('pointerup', onPointerUp);
    card.addEventListener('pointercancel', onPointerUp);
  }

  function removeCard(card) {
    card.classList.add('hidden');
    setTimeout(() => {
      card.remove();
      cards = Array.from(stack.querySelectorAll('.swipe-card'));
      if (cards.length) bindCard(cards[0]);
    }, 300);
  }

  if (cards.length) bindCard(cards[0]);

  // Buttons
  const likeBtn = document.getElementById('like-btn');
  const skipBtn = document.getElementById('skip-btn');

  likeBtn?.addEventListener('click', () => {
    const top = stack.querySelector('.swipe-card');
    if (top) {
      top.style.transform = `translateX(1200px) rotate(20deg)`;
      sendAction(top.dataset.userId, 'right');
      removeCard(top);
    }
  });
  skipBtn?.addEventListener('click', () => {
    const top = stack.querySelector('.swipe-card');
    if (top) {
      top.style.transform = `translateX(-1200px) rotate(-20deg)`;
      sendAction(top.dataset.userId, 'left');
      removeCard(top);
    }
  });

  function sendAction(userId, direction) {
    fetch('/swipe/action/', {
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded', 'X-CSRFToken': getCookie('csrftoken')},
      body: `to_user_id=${userId}&direction=${direction}`
    }).then(r => r.json()).then(data => {
      // handle response if needed
    });
  }

  // Cookie helper
  function getCookie(name) {
    const v = document.cookie.match('(^|;) ?' + name + '=([^;]*)(;|$)');
    return v ? v[2] : null;
  }
});