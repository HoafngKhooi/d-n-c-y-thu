"""
chairperson.py — Chủ tịch Penguin (Discord Bot)
-----------------------------------------
Chủ tịch giờ sống trong group Discord: nhận task từ member trong server qua
lệnh !penguin <task> (hoặc @mention bot), giao cho Staff xử lý, rồi trả lời
trực tiếp trong channel Discord.
"""

import asyncio
import importlib
import os
from typing import List

import discord
from discord.ext import commands

DISCORD_TOKEN = os.environ.get("DISCORD_BOT_TOKEN")
COMMAND_PREFIX = os.environ.get("PENGUIN_PREFIX", "!penguin")

intents = discord.Intents.default()
intents.message_content = True

bot = commands.Bot(command_prefix=COMMAND_PREFIX, intents=intents, help_command=None)

try:
    manager_module = importlib.import_module("manager")
    manager = getattr(manager_module, "manager")
except (ImportError, ModuleNotFoundError):
    class _SimpleManager:
        def dispatch(self, task: str) -> str:
            return (
                f"Đã nhận task: {task}\n"
                "Manager chưa được cung cấp trong dự án, nên bot đang trả về phản hồi mẫu."
            )

    manager = _SimpleManager()


def chairman_handle(task: str) -> str:
    """Delegate the task to the manager layer."""
    return manager.dispatch(task)


def _split_for_discord(text: str, limit: int = 1900) -> List[str]:
    """Split long reports into Discord-safe chunks."""
    chunks: List[str] = []
    while text:
        chunks.append(text[:limit])
        text = text[limit:]
    return chunks or [""]


async def _process_task(channel: discord.abc.Messageable, task: str) -> None:
    await channel.send("[Chủ tịch Penguin] Đã nhận task, đang giao cho Staff xử lý...")
    loop = asyncio.get_running_loop()
    report = await loop.run_in_executor(None, chairman_handle, task)
    for chunk in _split_for_discord(report):
        await channel.send(chunk)


@bot.event
async def on_ready() -> None:
    print(f"[Chủ tịch Penguin] Đã đăng nhập Discord với tên: {bot.user}")


@bot.command(name="task", help="Giao task cho Staff xử lý. Ví dụ: !penguin task sửa bug ở main.py")
async def task_command(ctx: commands.Context, *, task: str) -> None:
    await _process_task(ctx.channel, task)


@bot.event
async def on_message(message: discord.Message) -> None:
    if message.author.bot:
        return

    if bot.user in message.mentions:
        content = message.content.replace(f"<@{bot.user.id}>", "").strip()
        if content:
            await _process_task(message.channel, content)
        return

    if message.content.startswith(COMMAND_PREFIX):
        payload = message.content[len(COMMAND_PREFIX):].strip()
        if payload:
            if payload.startswith("task"):
                task = payload[4:].strip()
                if task:
                    await _process_task(message.channel, task)
                else:
                    await message.channel.send("Vui lòng cung cấp nội dung task.")
            else:
                await _process_task(message.channel, payload)
            return

    await bot.process_commands(message)


def main() -> None:
    if not DISCORD_TOKEN:
        raise SystemExit(
            "Chưa có DISCORD_BOT_TOKEN trong biến môi trường. "
            "Set: export DISCORD_BOT_TOKEN=\"token_moi_cua_ban\" rồi chạy lại."
        )
    bot.run(DISCORD_TOKEN)


if __name__ == "__main__":
    main()
