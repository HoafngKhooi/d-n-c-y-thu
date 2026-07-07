#!/usr/bin/env bash
# ==============================================================================
# organize_penguin_staff.sh
# Sắp xếp lại GỐC dự án Penguin thành cấu trúc theo STAFF (nhân sự),
# mỗi staff phụ trách ĐÚNG MỘT chuyên ngành — KHÔNG gộp nhiều chuyên ngành
# vào chung một staff.
#
# ⚠️  QUAN TRỌNG: Script CHỈ DI CHUYỂN, KHÔNG XOÁ bất cứ file/thư mục nào.
# ⚠️  Mỗi "dự án con" (metagpt/, aider/, free-claude-code/, awesome-llm-apps/,
#     taste-skill/, impeccable/, freellmapi/, browser/, prompt-master/, skills/)
#     được di chuyển NGUYÊN KHỐI — không băm nhỏ nội bộ — vì đây là các
#     codebase/dependency hoàn chỉnh, băm nhỏ sẽ làm vỡ import/build.
#
# Dự án: Penguin (One-Person Company)
# Cấu trúc: staff/{staff_name}/{chuyên_ngành}/{nội dung gốc}
#
# Chạy từ THƯ MỤC GỐC thật sự của Penguin (nơi có main.py, check.py):
#   chmod +x organize_penguin_staff.sh
#   ./organize_penguin_staff.sh
#
# Script dùng `git mv` nếu đang trong git repo (giữ lịch sử), fallback `mv`.
# ==============================================================================
set -euo pipefail

ROOT="$(pwd)"

# Chủ tịch có thể tên là main.py (bản gốc) hoặc chairperson.py (đã đổi tên).
# Chỉ dùng để KIỂM TRA đang đứng đúng gốc dự án — KHÔNG dời file này đi đâu cả.
CHAIRMAN_FILE=""
if [ -e "main.py" ]; then
  CHAIRMAN_FILE="main.py"
elif [ -e "chairperson.py" ]; then
  CHAIRMAN_FILE="chairperson.py"
fi

# Các dấu hiệu nhận biết đang đứng đúng ở gốc Penguin
if [ -z "$CHAIRMAN_FILE" ] && [ ! -e "check.py" ] && [ ! -e "staff" ]; then
  echo "❌ Không thấy main.py / chairperson.py / check.py / staff/ ở đây."
  echo "   Hãy chạy script này từ đúng thư mục gốc của dự án Penguin."
  exit 1
fi

MV="mv"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  MV="git mv"
  echo "📦 Phát hiện git repo — dùng 'git mv' để giữ lịch sử."
else
  echo "📦 Không phải git repo — dùng 'mv' thường."
fi

move() {
  local from="$1" to="$2"
  if [ -e "$from" ]; then
    mkdir -p "$(dirname "$to")"
    $MV "$from" "$to"
    echo "  ✔ $from  →  $to"
  else
    echo "  ⏭  bỏ qua (không tồn tại): $from"
  fi
}

echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                   PENGUIN PROJECT — STAFF-BASED ORGANIZATION               ║"
echo "║                                                                            ║"
echo "║  Cấu trúc: staff/{staff_name}/{chuyên_ngành}/...                          ║"
echo "║  Nguyên tắc: 1 staff = 1 chuyên ngành duy nhất, KHÔNG gộp                  ║"
echo "║  Mode: 🔄 SẮP XẾP ONLY (không xoá files/folders)                          ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"

# ==============================================================================
# STAFF 1: CHAIRMAN_ORCHESTRATOR — Bot điều phối chính (code gốc của bạn)
# ==============================================================================
echo ""
echo "╭─ 👑 GỐC DỰ ÁN — GIỮ NGUYÊN, KHÔNG DỜI"
echo "│  chairperson.py  → file nắm quyền của Chủ tịch, phải ở GỐC mới đúng vai."
echo "│  check.py        → tool check nhanh, để GỐC cho tiện dùng ngay."
echo "│  platform/       → đi kèm chairperson.py (import dùng đường dẫn tương"
echo "│                    đối Path(__file__).parent), nên cũng ở GỐC theo."
echo "└─────────────────────────────────────────────────────────────────────────"
echo "  ⏭  giữ nguyên: main.py / chairperson.py (nếu có)"
echo "  ⏭  giữ nguyên: check.py"
echo "  ⏭  giữ nguyên: platform/"

# ==============================================================================
# STAFF 2: AGENT_FRAMEWORK_ENGINEER — MetaGPT (multi-agent framework)
# ==============================================================================
echo ""
echo "╭─ 🤖 STAFF 2: AGENT_FRAMEWORK_ENGINEER"
echo "│  Chuyên ngành: Multi-Agent Framework (MetaGPT)"
echo "└─────────────────────────────────────────────────────────────────────────"

move "metagpt" "staff/agent_framework_engineer/metagpt_multiagent_framework"

# ==============================================================================
# STAFF 3: LLM_GATEWAY_ENGINEER — free-claude-code (multi-provider LLM gateway)
# ==============================================================================
echo ""
echo "╭─ 🔀 STAFF 3: LLM_GATEWAY_ENGINEER"
echo "│  Chuyên ngành: Multi-Provider LLM Gateway (free-claude-code)"
echo "└─────────────────────────────────────────────────────────────────────────"

move "free-claude-code" "staff/llm_gateway_engineer/multi_provider_llm_gateway"

# ==============================================================================
# STAFF 4: CODING_ASSISTANT_ENGINEER — Aider (AI pair-programming CLI)
# ==============================================================================
echo ""
echo "╭─ 💻 STAFF 4: CODING_ASSISTANT_ENGINEER"
echo "│  Chuyên ngành: AI Pair-Programming CLI (Aider)"
echo "└─────────────────────────────────────────────────────────────────────────"

move "aider" "staff/coding_assistant_engineer/aider_pair_programming_cli"

# ==============================================================================
# STAFF 5: REFERENCE_LIBRARY_CURATOR — awesome-llm-apps (kho ví dụ tham khảo)
# ==============================================================================
echo ""
echo "╭─ 📚 STAFF 5: REFERENCE_LIBRARY_CURATOR"
echo "│  Chuyên ngành: LLM/Agent Example App Library (awesome-llm-apps)"
echo "└─────────────────────────────────────────────────────────────────────────"

move "awesome-llm-apps" "staff/reference_library_curator/llm_apps_example_library"

# ==============================================================================
# STAFF 6: DESIGN_SKILL_ENGINEER — taste-skill (bộ skill thẩm mỹ/thiết kế)
# ==============================================================================
echo ""
echo "╭─ 🎨 STAFF 6: DESIGN_SKILL_ENGINEER"
echo "│  Chuyên ngành: Design & Taste Skills (taste-skill)"
echo "└─────────────────────────────────────────────────────────────────────────"

move "taste-skill" "staff/design_skill_engineer/taste_skill_design_system"

# ==============================================================================
# STAFF 7: IMPECCABLE_PRODUCT_ENGINEER — impeccable (sản phẩm agent thiết kế asset)
# ==============================================================================
echo ""
echo "╭─ 🏗️  STAFF 7: IMPECCABLE_PRODUCT_ENGINEER"
echo "│  Chuyên ngành: Impeccable — Agent sản xuất & tinh chỉnh design asset"
echo "└─────────────────────────────────────────────────────────────────────────"

move "impeccable" "staff/impeccable_product_engineer/impeccable_asset_agent_product"

# ==============================================================================
# STAFF 8: LLM_API_SERVICE_ENGINEER — freellmapi (dịch vụ Free LLM API)
# ==============================================================================
echo ""
echo "╭─ 🌐 STAFF 8: LLM_API_SERVICE_ENGINEER"
echo "│  Chuyên ngành: Free LLM API Service (server + client)"
echo "└─────────────────────────────────────────────────────────────────────────"

move "freellmapi" "staff/llm_api_service_engineer/freellmapi_service"

# ==============================================================================
# STAFF 9: BROWSER_ENGINE_ENGINEER — browser (engine trình duyệt viết bằng Zig)
# ==============================================================================
echo ""
echo "╭─ 🧭 STAFF 9: BROWSER_ENGINE_ENGINEER"
echo "│  Chuyên ngành: Browser Engine (Zig)"
echo "└─────────────────────────────────────────────────────────────────────────"

move "browser" "staff/browser_engine_engineer/browser_engine_zig"

# ==============================================================================
# STAFF 10: PROMPT_ENGINEER — prompt-master (skill prompt engineering)
# ==============================================================================
echo ""
echo "╭─ ✍️  STAFF 10: PROMPT_ENGINEER"
echo "│  Chuyên ngành: Prompt Engineering Skill (prompt-master)"
echo "└─────────────────────────────────────────────────────────────────────────"

move "prompt-master" "staff/prompt_engineer/prompt_master_skill"

# ==============================================================================
# STAFF 11: GAME_ASSET_SKILL_ENGINEER — skills/ (bộ skill spritecook)
# ==============================================================================
echo ""
echo "╭─ 🎮 STAFF 11: GAME_ASSET_SKILL_ENGINEER"
echo "│  Chuyên ngành: Game Sprite/Tileset Generation Skills (spritecook-*)"
echo "└─────────────────────────────────────────────────────────────────────────"

move "skills" "staff/game_asset_skill_engineer/spritecook_asset_skills"

# ==============================================================================
# STAFF 11: AGENTSCOPE_FRAMEWORK_ENGINEER — agentscope (multi-agent framework)
# ==============================================================================
echo ""
echo "╭─ 🧩 STAFF 11: AGENTSCOPE_FRAMEWORK_ENGINEER"
echo "│  Chuyên ngành: Multi-Agent Framework (AgentScope)"
echo "└─────────────────────────────────────────────────────────────────────────"

move "agentscope" "staff/agentscope_framework_engineer/agentscope_multiagent_framework"

# ==============================================================================
# TỔNG KẾT
# ==============================================================================
echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                          ✅ REORGANIZATION COMPLETE                        ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Cấu trúc mới:"
echo ""
echo "  staff/"
echo "  ├── agent_framework_engineer/     → MetaGPT Multi-Agent Framework"
echo "  ├── llm_gateway_engineer/         → Multi-Provider LLM Gateway"
echo "  ├── coding_assistant_engineer/    → Aider Pair-Programming CLI"
echo "  ├── reference_library_curator/    → awesome-llm-apps Example Library"
echo "  ├── design_skill_engineer/        → taste-skill Design System"
echo "  ├── impeccable_product_engineer/  → Impeccable Asset Agent Product"
echo "  ├── llm_api_service_engineer/     → freellmapi Service"
echo "  ├── browser_engine_engineer/      → Browser Engine (Zig)"
echo "  ├── prompt_engineer/              → prompt-master Skill"
echo "  └── game_asset_skill_engineer/    → spritecook Skills"
echo "  └── agentscope_framework_engineer/→ AgentScope Multi-Agent Framework"
echo ""
echo "  Ở GỐC dự án (cố tình không dời):"
echo "  ├── chairperson.py (hoặc main.py)  → Chủ tịch, phải ở gốc mới đúng vai"
echo "  ├── check.py                       → tool check nhanh, để gốc cho tiện"
echo "  └── platform/                      → đi kèm chairperson.py bắt buộc"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  QUAN TRỌNG: Script CHỈ sắp xếp, KHÔNG XOÁ bất kỳ file/thư mục nào."
echo "    Nếu có file/thư mục ở gốc mà script không nhận diện được (không nằm"
echo "    trong danh sách 10 staff ở trên, và không phải chairperson.py/"
echo "    check.py/platform/), chúng sẽ GIỮ NGUYÊN ở vị trí cũ — script sẽ"
echo "    không tự đoán bừa staff cho chúng."
echo ""
echo "🔄 CẬP NHẬT CẦN THIẾT SAU KHI CHẠY:"
echo "  1. Nếu có script/CI nào tham chiếu đường dẫn cũ (vd. ./aider,"
echo "     ./metagpt, ./awesome-llm-apps...), cập nhật lại theo đường dẫn"
echo "     staff/... mới ở trên."
echo "  2. Nếu dùng virtualenv/poetry/npm riêng cho từng dự án con (aider,"
echo "     metagpt, free-claude-code, freellmapi...), chạy lại install trong"
echo "     thư mục mới của chúng vì đường dẫn tuyệt đối có thể đã đổi."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 Bất cứ thư mục/file mới nào phát sinh sau này ở gốc dự án nên được"
echo "   gán cho ĐÚNG MỘT staff theo đúng chuyên ngành của nó — không gộp"
echo "   2 chuyên ngành khác nhau vào chung 1 staff."
echo ""
