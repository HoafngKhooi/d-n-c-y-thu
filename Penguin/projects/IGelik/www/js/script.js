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

async function sendMessage() {
    const input = document.getElementById('user-input');
    const messageText = input.value.trim();

    if (messageText === "") return;

    // 1. Hiển thị tin nhắn người dùng (như cũ)
    appendMessage("Bạn", messageText);
    input.value = "";

    // 2. Gửi tới main.py (Backend)
    try {
        const response = await fetch('/api/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message: messageText })
        });
        
        const data = await response.json();
        
        // 3. Hiển thị phản hồi từ Server
        appendMessage("AI", data.reply);
    } catch (error) {
        console.error("Lỗi kết nối server:", error);
    }
}

function handleChatKeyPress(event) {
    if (event.key === "Enter" && !event.shiftKey) {
        event.preventDefault();
        sendMessage();
    }
}
