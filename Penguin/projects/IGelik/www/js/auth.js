// IGelik/js/auth.js
function openAuthModal() {
    document.getElementById('auth-modal').classList.add('show');
    switchAuthMode('login');
}

function closeAuthModal() {
    document.getElementById('auth-modal').classList.remove('show');
}

window.addEventListener('click', (e) => {
    const modal = document.getElementById('auth-modal');
    if (e.target === modal) closeAuthModal();
});

function switchAuthMode(mode) {
    const form = document.getElementById('auth-form');
    const title = document.getElementById('modal-title');
    const nameInput = document.getElementById('auth-name');
    const repassInput = document.getElementById('auth-repass');
    const termsLabel = document.getElementById('terms-label');
    const toggleText = document.getElementById('auth-toggle-text');
    
    form.setAttribute('data-mode', mode);
    
    if (mode === 'login') {
        title.innerText = "Đăng Nhập";
        nameInput.style.display = "none";
        repassInput.style.display = "none";
        termsLabel.style.display = "none";
        toggleText.innerHTML = `Chưa có tài khoản? <a href="#" onclick="switchAuthMode('register')">Đăng ký ngay</a>`;
    } else {
        title.innerText = "Đăng Ký Tài Khoản";
        nameInput.style.display = "block";
        repassInput.style.display = "block";
        termsLabel.style.display = "flex";
        toggleText.innerHTML = `Đã có tài khoản? <a href="#" onclick="switchAuthMode('login')">Đăng nhập</a>`;
    }
}

function handleSubmitAuth() {
    const mode = document.getElementById('auth-form').getAttribute('data-mode');
    const email = document.getElementById('auth-email').value.trim();
    const pass = document.getElementById('auth-pass').value;
    
    let usersList = JSON.parse(localStorage.getItem('registeredUsers')) || [];
    
    if (!email || !pass) return alert("Vui lòng điền đầy đủ Email và Mật khẩu!");
    
    if (mode === 'register') {
        const name = document.getElementById('auth-name').value.trim();
        const repass = document.getElementById('auth-repass').value;
        const terms = document.getElementById('terms').checked;
        
        if (!name) return alert("Vui lòng nhập tên của bạn!");
        if (!terms) return alert("Bạn cần đồng ý với điều khoản!");
        if (pass !== repass) return alert("Mật khẩu nhập lại không khớp!");
        
        const isExist = usersList.some(user => user.email === email);
        if (isExist) return alert("Email này đã tồn tại trên hệ thống!");
        
        const newUser = { name, email, password: pass, avatar: 'https://via.placeholder.com/40' };
        usersList.push(newUser);
        localStorage.setItem('registeredUsers', JSON.stringify(usersList));
        
        alert("Đăng ký thành công! Đang tự động đăng nhập...");
        loginSession(newUser);
    } else {
        const validUser = usersList.find(user => user.email === email && user.password === pass);
        if (!validUser) return alert("Sai tài khoản hoặc mật khẩu! Vui lòng kiểm tra lại.");
        
        alert(`Chào mừng ${validUser.name} đã quay trở lại!`);
        loginSession(validUser);
    }
}

function loginSession(user) {
    localStorage.setItem('currentUser', JSON.stringify(user));
    
    document.getElementById('open-auth-btn').style.display = 'none';
    document.getElementById('user-profile').style.display = 'flex';
    document.getElementById('user-avatar').src = user.avatar;
    document.getElementById('user-name').textContent = user.name;
    
    closeAuthModal();
}

function logout() {
    localStorage.removeItem('currentUser');
    document.getElementById('open-auth-btn').style.display = 'block';
    document.getElementById('user-profile').style.display = 'none';
    alert("Đăng xuất thành công!");
}

function triggerGoogleSignIn() {
    alert("Tính năng Google Sign-In sắp được kích hoạt!");
}

// Kiểm tra user khi tải trang
window.addEventListener('load', () => {
    const currentUser = localStorage.getItem('currentUser');
    if (currentUser) {
        const user = JSON.parse(currentUser);
        document.getElementById('open-auth-btn').style.display = 'none';
        document.getElementById('user-profile').style.display = 'flex';
        document.getElementById('user-avatar').src = user.avatar;
        document.getElementById('user-name').textContent = user.name;
    }
});