// WebSocket client for chat page
document.addEventListener('DOMContentLoaded', () => {
  const chatBox = document.getElementById('chat-box');
  const form = document.querySelector('form');
  if (!chatBox || !form) return;

  // match id derived from current path: /chat/<match_id>/
  const pathParts = window.location.pathname.split('/').filter(Boolean);
  const matchId = pathParts.includes('chat') ? pathParts[pathParts.indexOf('chat') + 1] : null;
  if (!matchId) return;

  const wsScheme = window.location.protocol === 'https:' ? 'wss' : 'ws';
  const wsUrl = `${wsScheme}://${window.location.host}/ws/chat/${matchId}/`;
  const socket = new WebSocket(wsUrl);

  socket.addEventListener('open', () => {
    console.log('WebSocket connected');
  });

  socket.addEventListener('message', (event) => {
    const data = JSON.parse(event.data);
    const el = document.createElement('div');
    el.innerHTML = `<strong>${data.sender}</strong><div>${escapeHtml(data.message)}</div><small class="text-muted">${new Date(data.timestamp).toLocaleString()}</small>`;
    chatBox.appendChild(el);
    chatBox.scrollTop = chatBox.scrollHeight;
  });

  form.addEventListener('submit', (e) => {
    e.preventDefault();
    const input = form.querySelector('textarea, input[type="text"]');
    const message = input.value.trim();
    if (!message) return;
    socket.send(JSON.stringify({message}));
    input.value = '';
  });

  function escapeHtml(text) {
    const div = document.createElement('div');
    div.innerText = text;
    return div.innerHTML;
  }
});