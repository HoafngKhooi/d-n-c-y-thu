from flask import Flask, send_from_directory, request, jsonify

# Khởi tạo Flask, trỏ tới thư mục 'www'
app = Flask(__name__, static_folder='www')

# Route chính: Truy cập trang chủ
@app.route('/')
def index():
    return send_from_directory('www', 'index.html')

# Route cho các file tĩnh (CSS, JS, v.v.)
@app.route('/<path:path>')
def serve_static(path):
    return send_from_directory('www', path)

# --- CÁC ĐIỂM NỐI API (Backend Logic) ---

# Ví dụ: Xử lý tin nhắn từ frontend
@app.route('/api/chat', methods=['POST'])
def chat():
    data = request.json
    user_message = data.get('message')
    
    # Ở đây bạn sẽ gọi AI hoặc logic xử lý của bạn
    response = f"Server đã nhận tin nhắn: {user_message}"
    
    return jsonify({"reply": response})

if __name__ == '__main__':
    print("Server đang chạy tại: http://localhost:5000")
    app.run(debug=True, port=5000)

