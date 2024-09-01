document.addEventListener('DOMContentLoaded', function() {
    const themeToggleBtn = document.getElementById('theme-toggle-btn');
    const themeToggleIcon = document.getElementById('theme-toggle-icon');
    const body = document.body;

    function setTheme(isDark) {
        body.classList.toggle('dark-mode', isDark);
        themeToggleIcon.textContent = isDark ? '🌙' : '🌞';
        localStorage.setItem('theme', isDark ? 'dark' : 'light');
    }

    themeToggleBtn.addEventListener('click', function() {
        setTheme(!body.classList.contains('dark-mode'));
    });

    // Check for saved theme preference
    const savedTheme = localStorage.getItem('theme');
    setTheme(savedTheme === 'dark');
});
