# 🏢 Pixel Agents + IGelik - Quick Start Guide

## ✅ Tích Hợp Đã Hoàn Thành!

Đã tích hợp thành công **pixel-agents** vào app **IGelik** kết hợp với **free-claude-code**.

## 🚀 Bắt Đầu Ngay (3 Bước)

### 📦 Bước 1: Cài Dependencies

```bash
cd Penguin/pixel-agents
pip install -r requirements.txt
```

### 🔧 Bước 2: Khởi Động Server

```bash
cd Penguin/pixel-agents
./start-server.sh
```

**Output:**
```
🚀 Pixel Agents Server Startup
🔧 Starting Pixel Agents Server...
Server will run on: http://127.0.0.1:8001
```

### 💻 Bước 3: Mở IGelik App

1. Mở file `Penguin/projects/IGelik/index.html` trong browser
2. Nhấp vào tab **"🏢 Văn phòng AI"** trong sidebar
3. Chọn một Agent và bắt đầu chat!

## 📂 File Được Tạo

### Backend (Pixel Agents Server)
```
pixel-agents/
├── agent_server.py          # FastAPI server chính
├── config.yaml             # Cấu hình
├── requirements.txt        # Dependencies
├── start-server.sh         # Startup script
├── setup.py               # Setup script
├── free-claude-code/       # Claude API proxy (cloned)
└── README.md              # Documentation
```

### Frontend (IGelik Integration)
```
projects/IGelik/
├── index.html                       # Updated with pixel-agents scripts
├── js/
│   ├── pixel-agents-client.js      # Client library (NEW)
│   └── office-ui.js                # Office UI component (NEW)
└── css/
    └── style.css                    # Updated with office styles
```

### Documentation
```
Penguin/
├── PIXEL_AGENTS_INTEGRATION.md      # Full integration guide
├── check-integration.sh             # Integration test script
└── QUICK_START.md                  # This file
```

## 🎯 Tính Năng

### ✨ Office Tab Features
- ✅ Auto-connect tới Pixel Agents Server
- ✅ Hiển thị danh sách Agent
- ✅ Chat interface với agent
- ✅ Lưu lịch sử chat
- ✅ Responsive design
- ✅ Real-time status

### 🤖 Available Agents
- **Claude Agent** - AI general-purpose
- **Code Agent** - Specialized for coding

## 🔗 API Endpoints

Server chạy tại: `http://127.0.0.1:8001`

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/health` | GET | Health check |
| `/api/agents` | GET | List agents |
| `/api/chat` | POST | Send message |
| `/api/execute` | POST | Execute task |
| `/api/status` | GET | Get status |

## 🧪 Test Integration

```bash
cd Penguin
./check-integration.sh
```

Sẽ kiểm tra tất cả files có tại chỗ không.

## 🐛 Troubleshooting

### "Cannot connect to server"
```bash
# Kiểm tra server đang chạy
curl http://127.0.0.1:8001/health

# Nếu port 8001 bận, kill process
lsof -i :8001
kill -9 <PID>
```

### "ModuleNotFoundError"
```bash
# Cài lại dependencies
pip install -r pixel-agents/requirements.txt --force-reinstall
```

### "No module named 'fastapi'"
```bash
# Chắc chắn bạn ở trong đúng thư mục
cd pixel-agents
pip install -r requirements.txt
```

## 📚 More Information

- Full guide: [PIXEL_AGENTS_INTEGRATION.md](./PIXEL_AGENTS_INTEGRATION.md)
- Server docs: [pixel-agents/README.md](./pixel-agents/README.md)
- free-claude-code: https://github.com/Alishahryar1/free-claude-code

## 🎯 Next Steps

1. ✅ Install dependencies
2. ✅ Start server
3. ✅ Open IGelik
4. ✅ Try Office tab
5. 🚀 Build custom agents!

---

**Bạn đã sẵn sàng!** Hãy khám phá Pixel Agents trong IGelik! 🚀
