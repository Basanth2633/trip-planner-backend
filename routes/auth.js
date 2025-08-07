// Wait for DOM to load
document.addEventListener('DOMContentLoaded', () => {
  const loginForm = document.getElementById('loginForm');
  const emailInput = document.getElementById('email');
  const passwordInput = document.getElementById('password');

  if (loginForm) {
    loginForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      
      // Clear previous errors
      clearErrors();

      // Validate inputs
      if (!emailInput.value || !passwordInput.value) {
        showError('Please fill in all fields');
        return;
      }

      try {
        // Show loading state
        const submitBtn = loginForm.querySelector('button[type="submit"]');
        submitBtn.disabled = true;
        submitBtn.textContent = 'Logging in...';

        // Call login function
        const response = await loginUser(emailInput.value, passwordInput.value);
        
        // Store token and user data
        localStorage.setItem('authToken', response.token);
        localStorage.setItem('user', JSON.stringify(response.user));
        
        // Redirect (consider checking for redirect query param)
        const redirectTo = new URLSearchParams(window.location.search).get('redirect') || 'dashboard.html';
        window.location.href = redirectTo;

      } catch (err) {
        console.error('Login error:', err);
        showError(err.message || 'Login failed. Please try again.');
      } finally {
        // Reset button state
        const submitBtn = loginForm.querySelector('button[type="submit"]');
        if (submitBtn) {
          submitBtn.disabled = false;
          submitBtn.textContent = 'Log In';
        }
      }
    });
  }
});

// Helper functions
function clearErrors() {
  const errorElements = document.querySelectorAll('.error-message');
  errorElements.forEach(el => el.remove());
}

function showError(message) {
  const errorElement = document.createElement('div');
  errorElement.className = 'error-message';
  errorElement.textContent = message;
  errorElement.style.color = 'red';
  errorElement.style.marginTop = '10px';
  
  const loginForm = document.getElementById('loginForm');
  loginForm?.prepend(errorElement);
}