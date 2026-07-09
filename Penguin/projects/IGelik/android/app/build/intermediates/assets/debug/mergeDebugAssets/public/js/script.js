// IGelik/js/script.js
function toggleSidebar() {
    const sidebar = document.getElementById("sidebar");
    sidebar.classList.toggle("active");
}

function navigateTo(viewId) {
    const views = document.querySelectorAll('.app-view');
    views.forEach(view => view.classList.remove('active'));
    
    const targetView = document.getElementById(`view-${viewId}`);
    if (targetView) targetView.classList.add('active');
    
    // Cập nhật class active cho menu
    const sidebarItems = document.querySelectorAll('.sidebar-item');
    sidebarItems.forEach(item => item.classList.remove('active'));
    event?.currentTarget.classList.add('active'); // Thêm dấu ? để an toàn

    // Tự động đóng sidebar trên thiết bị di động
    if (window.innerWidth <= 768) {
        document.getElementById("sidebar").classList.remove("active");
    }
}

function sendMessage() {
    const input = document.getElementById('user-input');
    const messageText = input.value.trim();
    
    if (!localStorage.getItem('currentUser')) {
        alert("Vui lòng đăng nhập để gửi tin nhắn!");
        openAuthModal();
        return;
    }
    
    if (messageText !== "") {
        const chatWindow = document.getElementById('chat-window');
        const msgDiv = document.createElement('div');
        msgDiv.className = 'chat-msg';
        
        const senderB = document.createElement('b');
        senderB.textContent = "Bạn: ";
        
        const textSpan = document.createElement('span');
        textSpan.textContent = messageText; 
        
        msgDiv.appendChild(senderB);
        msgDiv.appendChild(textSpan);
        chatWindow.appendChild(msgDiv);
        
        input.value = "";
        input.focus();
        chatWindow.scrollTop = chatWindow.scrollHeight;
    }
}

function handleChatKeyPress(event) {
    if (event.key === "Enter" && !event.shiftKey) {
        event.preventDefault();
        sendMessage();
    }
}