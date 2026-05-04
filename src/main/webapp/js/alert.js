function showAlert(containerId, message, type = 'error') {
  const container = document.getElementById(containerId);
  if (!container) return;
  
  container.innerHTML = '';
  
  const alertDiv = document.createElement('div');
  alertDiv.className = 'alert alert-' + type;
  
  const iconSpan = document.createElement('span');
  if (type === 'error') {
    iconSpan.textContent = 'Error';
  } else if (type === 'success') {
    iconSpan.textContent = '✓';
  } else {
    iconSpan.textContent = 'ℹ️';
  }
  
  const msgSpan = document.createElement('span');
  msgSpan.textContent = message;
  
  alertDiv.appendChild(iconSpan);
  alertDiv.appendChild(msgSpan);
  container.appendChild(alertDiv);
  
  setTimeout(() => {
    if (alertDiv && alertDiv.parentNode) {
      alertDiv.style.opacity = '0';
      setTimeout(() => {
        if (alertDiv.parentNode) {
          alertDiv.parentNode.innerHTML = '';
        }
      }, 300);
    }
  }, 4000);
}
