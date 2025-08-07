// scripts/auth.js
document.addEventListener('DOMContentLoaded', () => {
  const registerForm = document.getElementById('registerForm');
  
  if (registerForm) {
    registerForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      
      // Get form values
      const formData = {
        name: document.getElementById('name').value,
        email: document.getElementById('email').value,
        password: document.getElementById('password').value,
        confirmPassword: document.getElementById('confirmPassword').value,
        street: document.getElementById('street').value,
        city: document.getElementById('city').value,
        state: document.getElementById('state').value,
        zip: document.getElementById('zip').value,
        country: document.getElementById('country').value,
        terms: document.getElementById('terms').checked
      };

      // Validate
      if (!validateForm(formData)) return;

      try {
        // Show loading state
        const submitBtn = registerForm.querySelector('button[type="submit"]');
        submitBtn.disabled = true;
        submitBtn.textContent = 'Registering...';

        // Send to backend
        const response = await fetch('http://localhost:3000/api/register', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(formData)
        });

        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.error || 'Registration failed');
        }

        // Success - redirect to login
        window.location.href = 'login.html?registered=true';

      } catch (err) {
        showError(err.message);
      } finally {
        // Reset button
        const submitBtn = registerForm.querySelector('button[type="submit"]');
        if (submitBtn) {
          submitBtn.disabled = false;
          submitBtn.textContent = 'Create Account';
        }
      }
    });
  }
});



function validateForm(data) {
  // Check required fields
  if (!data.name || !data.email || !data.password || !data.confirmPassword || 
      !data.street || !data.city || !data.country || !data.terms) {
    showError('Please fill in all required fields');
    return false;
  }

  // Check password match
  if (data.password !== data.confirmPassword) {
    showError('Passwords do not match');
    return false;
  }

  // Check password strength
  if (data.password.length < 8 || 
      !/\d/.test(data.password) || 
      !/[!@#$%^&*]/.test(data.password)) {
    showError('Password must be at least 8 characters with a number and special character');
    return false;
  }

  return true;
}

function showError(message) {
  // Clear previous errors
  const existingError = document.querySelector('.error-message');
  if (existingError) existingError.remove();

  // Create error element
  const errorElement = document.createElement('div');
  errorElement.className = 'error-message';
  errorElement.textContent = message;
  errorElement.style.color = 'red';
  errorElement.style.margin = '10px 0';

  // Insert after header
  const header = document.querySelector('.auth-header');
  header?.after(errorElement);
}

// Login Form Submission
document.getElementById('loginForm')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;

  try {
    const response = await fetch('http://localhost:3000/api/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });

    const data = await response.json();
    
    if (response.ok) {
      // Login successful - save user data (e.g., in localStorage)
      localStorage.setItem('user', JSON.stringify(data.user));
      alert('Login successful!');
      window.location.href = 'dashboard.html'; // Redirect
    } else {
      alert(data.error || 'Login failed');
    }
  } catch (err) {
    console.error('Login error:', err);
    alert('Network error. Try again.');
  }
});