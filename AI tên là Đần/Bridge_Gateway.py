from flask import Flask, request, jsonify

app = Flask(__name__)

# Biến lưu trữ dữ liệu tạm thời từ mắt thần (Observer)
current_game_state = {}

@app.route('/update_state', methods=['POST'])
def update_state():
    global current_game_state
    data = request.json
    # Dữ liệu từ điện thoại gửi lên: {distance, velocity, is_target}
    current_game_state = data

    # Ở đây Brain sẽ xử lý, nhưng tạm thời mình trả về lệnh chờ
    return jsonify({"action": "wait"}), 200

@app.route('/get_action', methods=['GET'])
def get_action():
    # Tay chân (Executor) sẽ gọi vào đây để hỏi: "Có nên bấm F không?"
    # Tạm thời giả lập: Nếu khoảng cách < 10 thì bảo bấm F
    if current_game_state.get('distance', 999) < 10:
        return jsonify({"command": "PARRY"}), 200
    return jsonify({"command": "IDLE"}), 200

if __name__ == '__main__':
    app.run(port=5000)
