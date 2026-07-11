import json
import os
from datetime import datetime

class APIKeyManager:
    """
    API Key Vault & Rotation Manager (Penguin System)
    Tự động quản lý, phân loại ưu tiên (Free/Paid), tự động cách ly các API Key bị lỗi
    và tích hợp tính năng giả lập kiểm tra model không tốn token.
    """
    def __init__(self, storage_path='api_keys_vault.json'):
        self.storage_path = storage_path
        self.data = {}
        self._initialize_vault()

    def _initialize_vault(self):
        """Khởi tạo file lưu trữ cấu hình mặc định nếu chưa tồn tại"""
        if os.path.exists(self.storage_path):
            with open(self.storage_path, 'r', encoding='utf-8') as f:
                self.data = json.load(f)
        else:
            # 🟢 [CHỖ SỬA] Đổi tên toàn bộ các api model theo danh sách mới cập nhật
            self.data = {
                "google": [
                    {
                        "key": "AIzaSy_Google_Studio_Free_Key",
                        "type": "free",
                        "priority": 1,
                        "status": "active",
                        "error_count": 0,
                        "last_used": None,
                        "note": "Khung chứa Key Google AI Studio (Gồm cả Gemini và Gemma)",
                        "supported_models": {
                            "gemini-3.5-flash": {"rpm": 5, "rpd": 20, "tpm": 250000},
                            "gemini-3-flash-preview": {"rpm": 5, "rpd": 20, "tpm": 250000},
                            "gemini-3.1-flash-lite": {"rpm": 15, "rpd": 500, "tpm": 250000},
                            "gemini-2.5-flash": {"rpm": 5, "rpd": 20, "tpm": 250000},
                            "gemini-2.5-flash-lite": {"rpm": 10, "rpd": 20, "tpm": 250000},
                            "gemini-3.1-flash-tts-preview": {"rpm": 3, "rpd": 10, "tpm": 10000},
                            "gemini-2.5-flash-preview-tts": {"rpm": 3, "rpd": 10, "tpm": 10000},
                            "gemini-robotics-er-1.6-preview": {"rpm": 5, "rpd": 20, "tpm": 250000},
                            "gemini-robotics-er-1.5-preview": {"rpm": 10, "rpd": 20, "tpm": 250000},
                            "gemma-3-27b-it": {"rpm": 30, "rpd": 14400, "tpm": 15000},
                            "gemma-3-12b-it": {"rpm": 30, "rpd": 14400, "tpm": 15000},
                            "gemma-3-4b-it": {"rpm": 30, "rpd": 14400, "tpm": 15000},
                            "gemma-3-1b-it": {"rpm": 30, "rpd": 14400, "tpm": 15000}
                        }
                    },
                    {
                        "key": "AIzaSy_Google_Studio_Paid_Key",
                        "type": "paid",
                        "priority": 2,
                        "status": "active",
                        "error_count": 0,
                        "last_used": None,
                        "note": "Key trả phí dự phòng khi tài khoản free cạn kiệt",
                        "supported_models": "all"
                    }
                ],
                "openai": [
                    {"key": "sk-proj-Free_Key_1", "type": "free", "priority": 1, "status": "active", "error_count": 0, "last_used": None, "note": "Key OpenAI Free"}
                ],
                "claude": [
                    {"key": "sk-ant-Paid_Key_1", "type": "paid", "priority": 2, "status": "active", "error_count": 0, "last_used": None, "note": "Key Claude Pro"}
                ]
            }
            self.save_state()

    def save_state(self):
        """Ghi lại trạng thái và lịch sử sử dụng xuống file JSON"""
        with open(self.storage_path, 'w', encoding='utf-8') as f:
            json.dump(self.data, f, indent=4, ensure_ascii=False)

    def get_key_for_model(self, provider: str, model_name: str) -> str:
        """
        Lấy key tối ưu cho một model cụ thể của nhà cung cấp.
        Kiểm tra và chặn lỗi sai tên model nội bộ (Không tốn token của API thật).
        """
        provider = provider.lower()
        model_name = model_name.lower()

        if provider not in self.data:
            print(f"❌ [Kiểm tra] Không tìm thấy nhà cung cấp: '{provider}'")
            return None

        # 1. Thu thập tất cả các model được hỗ trợ bởi provider này để kiểm tra tính hợp lệ
        all_supported_models = set()
        for k in self.data[provider]:
            if isinstance(k.get('supported_models'), dict):
                all_supported_models.update(k['supported_models'].keys())

        # Giả lập check tên model
        has_global_key = any(k.get('supported_models') == "all" for k in self.data[provider])
        if not has_global_key and model_name not in all_supported_models:
            print(f"❌ [Giả lập chặn] Lỗi! Tên model '{model_name}' không tồn tại hoặc chưa được định nghĩa cho nhà cung cấp '{provider}'.")
            print(f"💡 Các model hợp lệ hiện tại: {list(all_supported_models)}")
            return None

        # 2. Lọc các key đang hoạt động ổn định và có hỗ trợ model này
        eligible_keys = []
        for k in self.data[provider]:
            if k['status'] != 'active':
                continue

            if k.get('supported_models') == "all" or (isinstance(k.get('supported_models'), dict) and model_name in k['supported_models']):
                eligible_keys.append(k)

        if not eligible_keys:
            print(f"🚫 Hết key khả dụng hỗ trợ riêng cho model: {model_name}!")
            return None

        # Sắp xếp thông minh: priority tăng dần (1 chạy trước), error_count tăng dần
        sorted_keys = sorted(eligible_keys, key=lambda x: (x['priority'], x['error_count']))

        best_key_info = sorted_keys[0]
        best_key_info['last_used'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.save_state()

        print(f"🎯 [Giả lập OK] Model '{model_name}' hợp lệ. Đã cấp key: {best_key_info['key']} ({best_key_info['note']})")
        return best_key_info['key']

    def report_failure(self, provider: str, bad_key: str):
        """AI Agent tự động gọi hàm này khi dùng key bị lỗi (Rate Limit/Expired)."""
        provider = provider.lower()
        if provider not in self.data:
            return

        for k in self.data[provider]:
            if k['key'] == bad_key:
                k['error_count'] += 1
                print(f"⚠️ Warning: Key {provider} gặp lỗi lần thứ {k['error_count']}.")

                if k['error_count'] >= 3:
                    k['status'] = 'inactive'
                    print(f"🚫 Auto-disabled: Vô hiệu hóa key {provider} do lỗi quá 3 lần!")
                break
        self.save_state()

    def reset_all_keys(self):
        """Kích hoạt lại toàn bộ các key"""
        for provider in self.data:
            for k in self.data[provider]:
                k['status'] = 'active'
                k['error_count'] = 0
        self.save_state()
        print("🔄 Đã đặt lại trạng thái hoạt động cho toàn bộ API Key.")

# --- ĐOẠN KHỐI GIẢ LẬP KIỂM TRA (TEST) ---
if __name__ == '__main__':
    # Xóa file cũ để cập nhật danh sách tên model mới sang file JSON mới
    if os.path.exists('api_keys_vault.json'):
        os.remove('api_keys_vault.json')

    manager = APIKeyManager()
    print("=== PENGUIN KEY VAULT INITIALIZED ===")

    print("\n--- [TEST 1] Gọi đúng tên model Gemini mới ---")
    key1 = manager.get_key_for_model("google", "gemini-3-flash-preview")

    print("\n--- [TEST 2] Gọi đúng tên model Gemma mới (-it) ---")
    # 🟢 [CHỖ SỬA] Cập nhật string test thành gemma-3-27b-it
    key2 = manager.get_key_for_model("google", "gemma-3-27b-it")

    print("\n--- [TEST 3] Giả lập gõ SAI Tên (Hệ thống tự chặn nội bộ không tốn token) ---")
    key3 = manager.get_key_for_model("google", "gemma-3-27b-instruct")

