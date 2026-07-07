"""
manager.py — Quản lý điều phối của Penguin.

Luồng đúng theo vai trò:
    Khách hàng/User -> Chủ tịch (chairperson.py) -> Manager (file này)
    -> (một hoặc nhiều) Staff phù hợp -> Staff tự chia nhỏ việc của mình,
    tự nhờ Staff khác phối hợp nếu cần -> Manager gộp báo cáo -> trả về
    Chủ tịch -> trả lời Discord.

Manager KHÔNG tự làm việc chuyên môn. Manager chỉ:
1. Đọc task, xác định staff nào phù hợp (CÓ THỂ nhiều staff cùng lúc,
   vì một task thực tế thường cần nhiều chuyên môn phối hợp).
2. Import & khởi tạo đúng Staff đó từ staff/<staff_name>/staff_agent.py.
3. Gọi Staff xử lý, gộp các báo cáo lại.
4. Cũng đóng vai trò "tổng đài" khi một Staff cần nhờ Staff khác giúp
   (xem BaseStaff.collaborate trong staff_base.py).
"""
from __future__ import annotations

import importlib.util
import sys
from pathlib import Path
from typing import Dict, List

# staff/ nằm ở gốc dự án, cùng cấp với chairperson.py và platform/
STAFF_ROOT = Path(__file__).resolve().parent.parent.parent / "staff"

# Từ khoá (tiếng Việt + tiếng Anh) -> (các) staff phù hợp.
# Một task có thể khớp nhiều từ khoá -> nhiều staff cùng phối hợp.
# Tên staff PHẢI khớp đúng tên thư mục thật trong staff/.
SPECIALIZATIONS: Dict[str, List[str]] = {
    # agent_framework_engineer — MetaGPT
    "metagpt": ["agent_framework_engineer"],
    # agentscope_framework_engineer — AgentScope
    "agentscope": ["agentscope_framework_engineer"],
    # llm_gateway_engineer — multi-provider LLM gateway
    "gateway": ["llm_gateway_engineer"],
    "provider": ["llm_gateway_engineer"],
    "cổng llm": ["llm_gateway_engineer"],
    # coding_assistant_engineer — Aider
    "aider": ["coding_assistant_engineer"],
    "sửa code": ["coding_assistant_engineer"],
    "sửa bug": ["coding_assistant_engineer"],
    # reference_library_curator — awesome-llm-apps
    "ví dụ": ["reference_library_curator"],
    "tham khảo": ["reference_library_curator"],
    # design_skill_engineer — taste-skill
    "thiết kế": ["design_skill_engineer"],
    "design": ["design_skill_engineer"],
    "thẩm mỹ": ["design_skill_engineer"],
    # impeccable_product_engineer — impeccable
    "impeccable": ["impeccable_product_engineer"],
    "asset": ["impeccable_product_engineer"],
    # llm_api_service_engineer — freellmapi
    "api": ["llm_api_service_engineer"],
    # browser_engine_engineer — browser (Zig)
    "browser": ["browser_engine_engineer"],
    "trình duyệt": ["browser_engine_engineer"],
    # prompt_engineer — prompt-master
    "prompt": ["prompt_engineer"],
    # game_asset_skill_engineer — skills/ (spritecook)
    "sprite": ["game_asset_skill_engineer"],
    "animation": ["game_asset_skill_engineer"],
    "godot": ["game_asset_skill_engineer"],
    "hoạt hình": ["game_asset_skill_engineer"],
}

# Staff nhận task khi không khớp từ khoá nào — chọn staff tổng quát nhất.
DEFAULT_STAFF = "agent_framework_engineer"


class Manager:
    def __init__(self):
        self._staff_cache = {}

    # ------------------------------------------------------------------
    def _load_staff(self, staff_name: str):
        """Import động staff/<staff_name>/staff_agent.py, cache lại sau lần đầu."""
        if staff_name in self._staff_cache:
            return self._staff_cache[staff_name]

        module_path = STAFF_ROOT / staff_name / "staff_agent.py"
        if not module_path.exists():
            return None

        spec = importlib.util.spec_from_file_location(f"penguin_staff_{staff_name}", module_path)
        module = importlib.util.module_from_spec(spec)
        sys.modules[spec.name] = module
        spec.loader.exec_module(module)

        staff_instance = module.STAFF_CLASS(manager=self)
        self._staff_cache[staff_name] = staff_instance
        return staff_instance

    # ------------------------------------------------------------------
    def _match_staff(self, task: str) -> List[str]:
        task_lower = task.lower()
        matched: List[str] = []
        for keyword, staff_names in SPECIALIZATIONS.items():
            if keyword in task_lower:
                for s in staff_names:
                    if s not in matched:
                        matched.append(s)
        return matched or [DEFAULT_STAFF]

    # ------------------------------------------------------------------
    def dispatch(self, task: str) -> str:
        """Chủ tịch gọi hàm này. Có thể điều phối cho NHIỀU Staff cùng lúc."""
        staff_names = self._match_staff(task)
        reports = [self.dispatch_to(name, task, requested_by="chairperson") for name in staff_names]
        header = f"[Manager] Đã điều phối task cho: {', '.join(staff_names)}"
        return header + "\n\n" + "\n\n".join(reports)

    def dispatch_to(self, staff_name: str, task: str, requested_by: str = "manager") -> str:
        """
        Giao task cho MỘT staff cụ thể. Dùng cả khi:
        - Chủ tịch giao việc lần đầu (requested_by="chairperson")
        - Một Staff nhờ Staff khác phối hợp (requested_by=<tên staff nhờ>)
        """
        staff = self._load_staff(staff_name)
        if staff is None:
            return f"[Manager] Không tìm thấy Staff '{staff_name}' (thiếu staff/{staff_name}/staff_agent.py)."
        return staff.handle(task)


manager = Manager()
