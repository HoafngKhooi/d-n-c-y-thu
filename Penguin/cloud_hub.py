import os
import re
import gdown
from huggingface_hub import hf_hub_download

def download_to_codespace(cloud_url, filename, repo_id=None):
    """
    Hệ thống tự động tải file nặng vào thư mục tạm /tmp của Codespaces
    Hỗ trợ cả Google Drive và Hugging Face
    """
    # Tạo thư mục tạm an toàn, không lo đầy ổ đĩa chính
    target_dir = "/tmp/codespace_storage"
    os.makedirs(target_dir, exist_ok=True)
    output_path = os.path.join(target_dir, filename)
    
    print(f"🔄 Đang khởi tạo kết nối tải xuống...")

    # TRƯỜNG HỢP 1: NẾU LÀ LINK GOOGLE DRIVE
    if "://google.com" in cloud_url:
        print("🤖 Phát hiện nguồn: Google Drive")
        try:
            # Tự động tải bằng gdown thẳng vào /tmp
            gdown.download(cloud_url, output_path, quiet=False, fuzzy=True)
            print(f"✅ Tải thành công từ Google Drive! File lưu tại: {output_path}")
            return output_path
        except Exception as e:
            print(f"❌ Lỗi tải từ Google Drive: {e}")
            return None

    # TRƯỜNG HỢP 2: NẾU LÀ HUGGING FACE
    elif "huggingface.co" in cloud_url or repo_id:
        print("🤖 Phát hiện nguồn: Hugging Face")
        try:
            # Nếu người dùng truyền cả link, tự tách lấy repo_id
            if not repo_id:
                # Ví dụ link: https://huggingface.co
                matches = re.search(r"huggingface\.co/(datasets/)?([^/]+/[^/]+)", cloud_url)
                if matches:
                    repo_id = matches.group(2)
            
            repo_type = "dataset" if "datasets" in cloud_url else "model"
            
            # Tải file từ Hugging Face về thư mục tạm /tmp
            downloaded_file = hf_hub_download(
                repo_id=repo_id,
                filename=filename,
                repo_type=repo_type,
                local_dir=target_dir
            )
            print(f"✅ Tải thành công từ Hugging Face! File lưu tại: {downloaded_file}")
            return downloaded_file
        except Exception as e:
            print(f"❌ Lỗi tải từ Hugging Face: {e}")
            return None
            
    else:
        print("❌ Định dạng link không hỗ trợ. Hãy dùng link Google Drive hoặc Hugging Face.")
        return None

# =====================================================================
# CÁCH SỬ DỤNG (Bạn chỉ cần sửa phần dưới này trên điện thoại)
# =====================================================================
if __name__ == "__main__":
    
    # Ví dụ 1: Muốn tải từ Google Drive, bạn dán link vào đây:
    LINK_CỦA_BẠN = "https://://google.com/file/d/MÃ_FILE_CỦA_BẠN/view?usp=sharing"
    TEN_FILE = "data_game_50gb.zip"
    
    # Ví dụ 2: Nếu sau này đổi ý muốn dùng Hugging Face, chỉ cần đổi link thành:
    # LINK_CỦA_BẠN = "https://huggingface.co"
    # TEN_FILE = "model_ai.pth"

    # Chạy lệnh tải tự động
    file_da_tai = download_to_codespace(LINK_CỦA_BẠN, TEN_FILE)
    
    # Lúc này trong code cày game của bạn, bạn có thể gọi file từ 'file_da_tai' để chạy!

