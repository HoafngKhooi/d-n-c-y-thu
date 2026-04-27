import disnake as discord
from disnake.ext import commands
from groq import Groq
import os

# Khởi tạo Groq
client = Groq(api_key=os.environ.get("GROQ_API_KEY"))

class AIChat(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        # ID kênh chat mục tiêu
        self.target_channel_id = 1497555474852089947

    @commands.Cog.listener()
    async def on_message(self, message):
        # Không trả lời bot khác
        if message.author.bot: return

        # Kiểm tra điều kiện tag hoặc đúng kênh
        is_mentioned = self.bot.user in message.mentions
        is_in_channel = message.channel.id == self.target_channel_id

        if is_mentioned or is_in_channel:
            async with message.channel.typing():
                try:
                    # Lấy nội dung chat (bỏ tag bot)
                    prompt = message.content.replace(f'<@!{self.bot.user.id}>', '').replace(f'<@{self.bot.user.id}>', '').strip()
                    
                    # System Prompt bản 2026 - Tự do nhảy số (No lạm dụng liệt kê)
                    system_message = (
                        "Bạn là một Gen Z (2k2-2k6) đang chat Discord với bạn thân. "
                        "Nhiệm vụ: Dùng toàn bộ hiểu biết của bạn về ngôn ngữ mạng hiện đại (TikTok, Threads, Facebook) để phản hồi. "
                        "Yêu cầu: Không dùng ngôn ngữ robot, không chào hỏi khách sáo. "
                        "Tự do sử dụng tiếng lóng, từ viết tắt, emoji, và cả những từ ngữ 'chợ búa' nếu cần để hợp vibe. "
                        "Nhảy số cực nhanh: vui thì lầy, buồn thì chill, hỏi bài thì giải pro."
                    )

                    # Gọi Groq với Llama 3.3 70B
                    chat_completion = client.chat.completions.create(
                        messages=[
                            {"role": "system", "content": system_message},
                            {"role": "user", "content": prompt or "lô"}
                        ],
                        model="llama-3.3-70b-versatile",
                        temperature=0.9, # Độ bay bổng để AI tự học style
                        max_tokens=1024,
                    )
                    
                    response = chat_completion.choices[0].message.content
                    if response:
                        await message.reply(response)
                    else:
                        await message.reply("Vô tri quá tui chưa nghĩ ra gì để rep luôn á 💀")

                except Exception as e:
                    print(f"Lỗi Groq: {e}")
                    await message.reply(f"❌ Lỗi rồi Khôi ơi: `{str(e)[:100]}`")

def setup(bot):
    bot.add_cog(AIChat(bot))
