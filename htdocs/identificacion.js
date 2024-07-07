document.getElementById('loginForm').addEventListener('submit', function(event) {
    event.preventDefault();
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;

    if (username === "admin" && password === "admin") {
        window.location.href = 'admin_login/admin.html'; // Página del administrador
    }
    else if (username === "usuario" && password === "usuario") {
        window.location.href = 'user_login/usuario.html'; // Página del usuario
    }
    else {
        alert('Credenciales incorrectas');
    }
});
