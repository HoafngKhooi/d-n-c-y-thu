"""
staff_base.py — Lớp nền cho mọi Staff trong Penguin.

Mỗi Staff PHẢI:
1. Biết TỰ CHIA NHỎ (decompose) nhiệm vụ của mình thành các subtask rõ
   ràng, thay vì ôm nguyên khối task vào xử lý một lần trong một môi
   trường duy nhất.
2. Biết GỌI STAFF KHÁC để phối hợp (collaborate) khi một phần việc thuộc
   đúng chuyên môn của Staff kia — để việc hoàn thành ổn định hơn thay vì
   một Staff cố ôm hết những việc ngoài chuyên môn của mình.

BaseStaff cung cấp khung sẵn cho 2 việc này. Từng Staff cụ thể (trong
staff/<staff_name>/staff_agent.py) chỉ cần override `decompose()` và
`execute_subtask()` theo đúng chuyên môn của mình; phần điều phối
(chia nhỏ -> xử lý -> gộp báo cáo) đã có sẵn trong `handle()`.
"""
from __future__ import annotations

import re
from typing import List


class BaseStaff:
    # Staff con PHẢI override 2 thuộc tính này cho đúng vai trò của mình.
    name: str = "base_staff"
    specialty: str = "Chưa đặt chuyên môn"

    def __init__(self, manager=None):
        # Manager được Manager tự inject vào khi khởi tạo Staff, nhờ đó
        # Staff có thể gọi Staff khác phối hợp mà không cần biết chi tiết
        # về cách Manager quản lý các Staff.
        self.manager = manager

    # ------------------------------------------------------------------
    # 1) CHIA NHỎ NHIỆM VỤ
    # ------------------------------------------------------------------
    def decompose(self, task: str) -> List[str]:
        """
        Chia 1 task lớn thành các subtask nhỏ để dễ hoàn thành sạch hơn.
        Mặc định: tách theo các từ nối/thán từ thường gặp trong tiếng Việt
        (và, rồi, sau đó, dấu phẩy, dấu chấm phẩy).

        Staff con NÊN override lại hàm này nếu chuyên môn của mình cần
        cách chia nhỏ khác (vd: chia theo file, theo bước kỹ thuật...).
        """
        parts = re.split(r"\s*(?:,|;| và | rồi | sau đó |\n)\s*", task.strip())
        return [p for p in parts if p]

    # ------------------------------------------------------------------
    # 2) XỬ LÝ TỪNG SUBTASK — Staff con BẮT BUỘC override cho đúng chuyên môn
    # ------------------------------------------------------------------
    def execute_subtask(self, subtask: str) -> str:
        return f"  - [{self.name}] đã xử lý: {subtask}"

    # ------------------------------------------------------------------
    # 3) NHỜ STAFF KHÁC PHỐI HỢP
    # ------------------------------------------------------------------
    def collaborate(self, other_staff_name: str, subtask: str) -> str:
        """
        Nhờ một Staff khác xử lý phần việc không thuộc chuyên môn của
        mình. Việc phối hợp LUÔN đi qua Manager (không gọi chéo trực
        tiếp giữa các staff_agent.py với nhau) để Manager luôn nắm được
        toàn bộ bức tranh ai đang làm gì, tránh vòng lặp gọi nhau vô hạn.
        """
        if self.manager is None:
            return f"  - [{self.name}] không có Manager để nhờ '{other_staff_name}' giúp."
        result = self.manager.dispatch_to(other_staff_name, subtask, requested_by=self.name)
        return f"  - [{self.name}] nhờ [{other_staff_name}] phối hợp phần: {subtask}\n    -> {result}"

    # ------------------------------------------------------------------
    # ĐIỀU PHỐI CHÍNH: chia nhỏ -> xử lý/phối hợp từng phần -> gộp báo cáo
    # ------------------------------------------------------------------
    def handle(self, task: str) -> str:
        subtasks = self.decompose(task)
        lines = [f"[{self.name}] ({self.specialty}) nhận task, chia thành {len(subtasks)} phần:"]
        for st in subtasks:
            lines.append(self.execute_subtask(st))
        return "\n".join(lines)
