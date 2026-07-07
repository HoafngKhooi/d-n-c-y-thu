# 🎯 Tích Hợp Pixel Agents vào IGelik - Hướng Dẫn Hoàn Chỉnh

## 📌 Tổng Quan

Bạn đã tích hợp thành công **Pixel Agents** vào app **IGelik** kết hợp với **free-claude-code**. 

### Cấu trúc tích hợp:
```
IGelik (Web App)
    │
    ├── 🏢 Văn phòng AI (Mới thêm)
    │   │
    │   ├── js/pixel-agents-client.js (Client thư viện)
    │   ├── js/office-ui.js (UI component)
    │   └── css/style.css (Styles mới)
    │
    └── Kết nối tới
        │
        ├── Pixel Agents Server (http://127.0.0.1:8001)
        │   │
        │   ├── agent_server.py (FastAPI server)
        │   └── config.yaml (Cấu hình)
        │
        └── free-claude-code (Claude API Proxy)
            │
            └── Claude AI Models
```

## 🚀 Hướng Dẫn Chạy

### Bước 1: Cài đặt Dependencies

```bash
# Từ thư mục pixel-agents
cd Penguin/pixel-agents
pip install -r requirements.txt
```

### Bước 2: Khởi động Pixel Agents Server

```bash
# Cách 1: Dùng startup script
./start-server.sh

# Cách 2: Chạy trực tiếp
python3 agent_server.py --host 127.0.0.1 --port 8001

# Cách 3: Dùng setup script trước
python3 setup.py
```

Output sẽ hiển thị:
```
🚀 Pixel Agents Server Startup
===============================

✓ Python 3 found: Python 3.x.x
✓ free-claude-code directory confirmed
✓ Dependencies installed

🔧 Starting Pixel Agents Server...
Server will run on: http://127.0.0.1:8001
Open IGelik app and navigate to '🏢 Văn phòng AI' tab

Press Ctrl+C to stop the server
```

### Bước 3: Mở IGelik App

1. Mở file `Penguin/projects/IGelik/index.html` trong trình duyệt
   - hoặc khởi động một local server: `python -m http.server 3000`

2. Nhấp vào tab "🏢 Văn phòng AI" trong sidebar

3. Ứng dụng sẽ:
   - Tự động kết nối tới Pixel Agents Server
   - Tải danh sách các Agent có sẵn
   - Cho phép bạn chọn agent và chat

## 📁 File Được Tạo Mới

### Trong `pixel-agents/`
- **agent_server.py** - Server chính (FastAPI)
- **config.yaml** - Cấu hình server
- **requirements.txt** - Dependencies
- **start-server.sh** - Script khởi động
- **setup.py** - Script setup
- **free-claude-code/** - Cloned repo
- **README.md** - Hướng dẫn

### Trong `projects/IGelik/js/`
- **pixel-agents-client.js** - Client library (giao tiếp với server)
- **office-ui.js** - UI component (giao diện Agent Office)

### Trong `projects/IGelik/css/`
- **style.css** - Thêm các style cho Office UI (section ".office-*")

### Cập nhật `projects/IGelik/`
- **index.html** - Thêm script tags và data-page attribute

## 💻 API Endpoints

### Health Check
```
GET /health
Response: {"status": "ok", "service": "pixel-agents", "version": "1.0.0"}
```

### List Agents
```
GET /api/agents
Response: {
  "agents": [
    {
      "id": "claude-agent",
      "name": "Claude Agent",
      "description": "AI agent powered by Claude",
      "capabilities": ["chat", "code-generation", "analysis"],
      "status": "ready"
    },
    ...
  ]
}
```

### Send Chat Message
```
POST /api/chat
Body: {
  "messages": [
    {"role": "user", "content": "Hello"},
    {"role": "assistant", "content": "Hi there!"}
  ],
  "model": "claude-3-5-sonnet-20241022",
  "temperature": 0.7,
  "max_tokens": 2048
}
Response: {
  "model": "claude-3-5-sonnet-20241022",
  "messages": [...],
  "response": {
    "role": "assistant",
    "content": "Response from Claude"
  }
}
```

### Execute Agent Task
```
POST /api/execute
Body: {
  "agent_type": "claude-agent",
  "task": "Write a Python function",
  "context": {...}
}
Response: {
  "agent": "claude-agent",
  "task": "Write a Python function",
  "status": "executing",
  "execution_id": "exec_12345"
}
```

### Get Agent Status
```
GET /api/status
Response: {
  "agents": {
    "claude-agent": {"status": "ready", "last_used": null},
    "code-agent": {"status": "ready", "last_used": null}
  },
  "server_status": "operational"
}
```

## 🎨 UI Components

### PixelAgentsClient Class
Thư viện JavaScript để giao tiếp với server:

```javascript
const client = new PixelAgentsClient('http://127.0.0.1:8001');

// Kiểm tra kết nối
client.isConnected() // true/false

// Lấy danh sách agent
const agents = await client.loadAgents()

// Gửi tin nhắn
const response = await client.sendMessage("Xin chào")

// Thực thi task
await client.executeTask("claude-agent", "Viết code Python")

// Chọn agent
client.selectAgent("code-agent")

// Xem lịch sử chat
const history = client.getHistory()

// Xóa lịch sử
client.clearHistory()
```

### Office UI Component
Giao diện trong tab "Văn phòng AI":

**Tính năng:**
- ✅ Hiển thị trạng thái kết nối
- ✅ Danh sách các agent (card view)
- ✅ Chi tiết capability của từng agent
- ✅ Chat box tích hợp
- ✅ Lịch sử tin nhắn
- ✅ Auto-reconnect (nếu cắt kết nối)

**Styling:**
- Gradient background (purple)
- Responsive grid layout
- Smooth animations
- Modern card design
- Color-coded messages

## ⚙️ Cấu Hình

File `pixel-agents/config.yaml`:

```yaml
server:
  host: "127.0.0.1"
  port: 8001
  debug: true

agents:
  claude:
    enabled: true
    provider: "free-claude-code"
    base_url: "http://127.0.0.1:8000"
    timeout: 30

services:
  agent_service:
    enabled: true
    port: 8001
    endpoints:
      - /api/agents
      - /api/chat
      - /api/execute

igelik_integration:
  enabled: true
  api_endpoint: "http://127.0.0.1:8001"
  cors_origins:
    - "http://localhost:3000"
    - "http://127.0.0.1:3000"
    - "file://"
```

## 🔧 Troubleshooting

### ❌ "Không thể kết nối đến Pixel Agents Server"

**Giải pháp:**
1. Đảm bảo server đang chạy: `python3 agent_server.py`
2. Kiểm tra port 8001 có disponible: `netstat -an | grep 8001`
3. Kiểm tra CORS settings trong `config.yaml`
4. Kiểm tra console của trình duyệt (F12) xem lỗi gì

### ❌ "ModuleNotFoundError: No module named 'fastapi'"

**Giải pháp:**
```bash
cd pixel-agents
pip install -r requirements.txt
```

### ❌ "Port 8001 already in use"

**Giải pháp:**
```bash
# Tìm process sử dụng port 8001
lsof -i :8001

# Kill process (nếu cần)
kill -9 <PID>

# Hoặc dùng port khác
python3 agent_server.py --host 127.0.0.1 --port 8002
```

### ❌ Agents không hiển thị

**Giải pháp:**
1. Kiểm tra server logs: `python3 agent_server.py`
2. Thử gọi endpoint trực tiếp: `curl http://127.0.0.1:8001/api/agents`
3. Kiểm tra cấu hình trong `config.yaml`

## 📚 Tài Liệu Liên Quan

- [free-claude-code GitHub](https://github.com/Alishahryar1/free-claude-code)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Anthropic Claude API](https://www.anthropic.com/)
- [IGelik Project README](../projects/IGelik/README.md)

## 🎯 Các Tính Năng Có Thể Thêm Tiếp Theo

1. **Persistent Storage** - Lưu lịch sử chat vào database
2. **Authentication** - Xác thực người dùng cho agent access
3. **Multi-user Support** - Hỗ trợ nhiều người dùng cùng lúc
4. **Agent Marketplace** - Tìm kiếm và cài đặt agent mới
5. **Custom Agent Creation** - Cho phép tạo agent tuỳ biến
6. **WebSocket Real-time** - Chat real-time thay vì polling
7. **Voice Integration** - Chat bằng giọng nói
8. **Analytics Dashboard** - Thống kê sử dụng agent

## 📝 Ghi Chú Quan Trọng

1. **Local Development Only** - Hiện tại cấu hình cho local development
2. **CORS Configuration** - Để deploy production, cập nhật CORS origins
3. **Authentication** - Thêm authentication layer trước production
4. **Rate Limiting** - Cộng thêm rate limiting cho API endpoints
5. **Logging** - Logs được lưu trong `pixel-agents.log`

## ✅ Checklist Hoàn Thành

- ✅ Cloned free-claude-code vào pixel-agents folder
- ✅ Tạo agent_server.py (FastAPI backend)
- ✅ Tạo config.yaml (cấu hình)
- ✅ Tạo pixel-agents-client.js (client library)
- ✅ Tạo office-ui.js (UI component)
- ✅ Cập nhật index.html với script tags
- ✅ Thêm CSS styles cho Office UI
- ✅ Tạo start-server.sh (startup script)
- ✅ Tạo setup.py (setup script)
- ✅ Tạo requirements.txt
- ✅ Tạo README.md
- ✅ Tạo INTEGRATION.md (file này)

## 🎉 Tiếp Theo

1. Chạy server: `./pixel-agents/start-server.sh`
2. Mở IGelik: `projects/IGelik/index.html`
3. Vào tab "🏢 Văn phòng AI"
4. Bắt đầu chat với AI agents!

---

**Tích hợp hoàn tất!** 🚀
