import os
import sys
from datetime import datetime

class Color:
    OK = '\033[92m'
    FAIL = '\033[91m'
    BLUE = '\033[94m'
    END = '\033[0m'

def get_dir_size(path='.'):
    total_size = 0
    for root, dirs, files in os.walk(path):
        for f in files:
            fp = os.path.join(root, f)
            try:
                total_size += os.path.getsize(fp)
            except OSError:
                continue
    return round(total_size / (1024 * 1024), 2)

def is_binary_file(file_path):
    try:
        with open(file_path, 'tr', encoding='utf-8') as f:
            f.read(1024)
            return False
    except UnicodeDecodeError:
        return True

def get_project_structure(root_path="."):
    structure = ["| Tên thành phần | Loại |", "| :--- | :--- |"]
    ignore = {'.git', '__pycache__', 'node_modules', '.env', 'PENGUIN_MANIFEST.md', 'error.log', 'project_code_bundle.txt'}
    for root, dirs, files in os.walk(root_path):
        dirs[:] = [d for d in dirs if d not in ignore]
        rel_path = os.path.relpath(root, root_path)
        level = 0 if rel_path == '.' else rel_path.count(os.sep) + 1
        indent = "&nbsp;&nbsp;" * level
        folder_name = os.path.basename(root)
        if rel_path == '.':
            folder_name = os.path.basename(os.path.abspath(root_path)) or 'Root'
        structure.append(f"| {indent}📂 **{folder_name}/** | Directory |")
        for f in files:
            if f not in ignore:
                structure.append(f"| {indent}&nbsp;&nbsp;📄 {f} | File |")
    return structure

def generate_code_bundle(root_path="."):
    bundle_filename = "project_code_bundle.txt"
    bundle_file = os.path.join(root_path, bundle_filename)
    MAX_FILE_SIZE = 100 * 1024 
    
    ignore = {'.git', '__pycache__', 'node_modules', '.env', 'check.py', 
              'PENGUIN_MANIFEST.md', 'error.log', bundle_filename, '.DS_Store'}
    
    with open(bundle_file, "w", encoding="utf-8") as outfile:
        outfile.write(f"PROJECT CODE BUNDLE - {datetime.now()}\n{'='*50}\n\n")
        for root, dirs, files in os.walk(root_path):
            dirs[:] = [d for d in dirs if d not in ignore]
            for f in files:
                if f not in ignore:
                    file_path = os.path.join(root, f)
                    file_size = os.path.getsize(file_path)
                    
                    if file_size > MAX_FILE_SIZE:
                        outfile.write(f"\n\n--- SKIPPED (Too large: {file_size/1024:.1f} KB): {file_path} ---\n")
                        continue
                    
                    if is_binary_file(file_path):
                        continue
                        
                    outfile.write(f"\n\n--- FILE: {file_path} ({file_size/1024:.1f} KB) ---\n\n")
                    try:
                        with open(file_path, "r", encoding="utf-8") as infile:
                            outfile.write(infile.read())
                    except Exception as e:
                        outfile.write(f"Could not read file: {e}")
    return bundle_file

def check_project(target_path="."):
    print(f"{Color.BLUE}--- HỆ THỐNG PENGUIN ({datetime.now().strftime('%H:%M:%S')}) ---{Color.END}")
    print(f"Thư mục đang quét: {Color.OK}{os.path.abspath(target_path)}{Color.END}\n")
    
    # 1. Tính toán dữ liệu từ target_path
    total_size = get_dir_size(target_path)
    
    # 2. Kiểm tra Checklist (kiểm tra theo đường dẫn target_path)
    checklist = {".env": "File .env", ".clinerules": "Rules", "staff/ai_core.py": "AI Core", "workflows/": "Workflows"}
    status_report = ""
    for path, desc in checklist.items():
        full_path = os.path.join(target_path, path)
        exists = os.path.exists(full_path)
        status = f"{Color.OK}PASS{Color.END}" if exists else f"{Color.FAIL}FAIL{Color.END}"
        print(f"[{status}] {desc}")
        status_report += f"| {desc} | { '✅' if exists else '❌' } |\n"

    # 3. Xuất file Manifest vào trong thư mục được quét
    manifest_file = os.path.join(target_path, "PENGUIN_MANIFEST.md")
    with open(manifest_file, "w", encoding="utf-8") as f:
        f.write(f"# 🐧 HỒ SƠ DỰ ÁN PENGUIN\n\n")
        f.write(f"### 📋 Tổng quan\n")
        f.write(f"- **Đường dẫn:** `{os.path.abspath(target_path)}`\n")
        f.write(f"- **Thời gian cập nhật:** `{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}`\n")
        f.write(f"- **Tổng dung lượng:** `{total_size} MB`\n\n")
        f.write(f"### 🛠 Trạng thái hệ thống\n| Thành phần | Trạng thái |\n| :--- | :--- |\n{status_report}\n")
        f.write(f"### 🌳 Cấu trúc thư mục\n")
        f.write("\n".join(get_project_structure(target_path)))
        f.write(f"\n\n---\n*Tự động tạo bởi Penguin System*")
        
    print(f"\n{Color.OK}[OK]{Color.END} Đã tạo Manifest tại: {manifest_file}")
    
    # 4. Gom code
    bundle = generate_code_bundle(target_path)
    print(f"{Color.OK}[OK]{Color.END} Đã gom code vào: {bundle}")

if __name__ == "__main__":
    # Lấy đường dẫn từ command line, nếu không có thì mặc định là thư mục hiện tại '.'
    target_directory = sys.argv[1] if len(sys.argv) > 1 else "."
    
    # Kiểm tra xem đường dẫn có tồn tại không
    if not os.path.isdir(target_directory):
        print(f"{Color.FAIL}[LỖI]{Color.END} Thư mục '{target_directory}' không tồn tại hoặc không phải là thư mục!")
        sys.exit(1)
        
    check_project(target_directory)
