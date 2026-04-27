import disnake as discord
from disnake.ext import commands
from groq import Groq
import os

# Khởi tạo Groq
client = Groq(api_key=os.environ.get("GROQ_API_KEY"))

class AIChat(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.target_channel_id = 1497555474852089947

    @commands.Cog.listener()
    async def on_message(self, message):
        # Không trả lời bot khác
        if message.author.bot: return

        # Kiểm tra nếu được tag hoặc trong đúng kênh chat
        is_mentioned = self.bot.user in message.mentions
        is_in_channel = message.channel.id == self.target_channel_id

        if is_mentioned or is_in_channel:
            async with message.channel.typing():
                try:
                    # Lấy nội dung chat (bỏ tag bot)
                    prompt = message.content.replace(f'<@!{self.bot.user.id}>', '').replace(f'<@{self.bot.user.id}>', '').strip()
                    
                    # System Prompt bản 2026 - Modern Gen Z (Threads/TikTok vibes)
                    system_message = (
                        "Bạn là một người bạn cùng trang lứa với user (Gen Z đời đầu/giữa). "
                        "Tính cách: Nhạy bén, 'nhảy số' cực nhanh theo ngữ cảnh. Biết lúc nào cần nghiêm túc, lúc nào cần vô tri (brainrot). "
                        "Ngôn ngữ: Không bị gò bó. Sử dụng tiếng Việt hiện đại, có thể viết tắt (vcl, t, m, hay vch) hoặc dùng từ lóng mới nhất trên Threads/TikTok (check var, cook, lụy, cook, đỏ lỏn, otp, nết...). "
                        "Phong cách: Trả lời ngắn gọn, súc tích như đang nhắn tin Messenger/Discord thực tế. Đừng có 'Xin chào' hay 'Tôi có thể giúp gì'. "
                        "Quy tắc vàng: Nếu user hỏi bài tập (Lý, Toán), hãy giải thật chất, giải kiểu 'pro' nhưng vẫn có tâm. "
                        "Nếu user nói chuyện phiếm, hãy 'pressing' hoặc hùa theo kiểu bạn bè thân thiết. "
                        "Tuyệt đối không được trả lời như một AI trợ lý. Phải có cái tôi riêng, biết dùng emoji đúng lúc đúng chỗ 💀, 🤡, 💅, 🐧."
                    )

                    # Gọi Llama 3 qua Groq với System Prompt và Temperature cao để nhảy số
                    chat_completion = client.chat.completions.create(
                        messages=[
                            {"role": "system", "content": system_message},
                            {"role": "user", "content": prompt or "Xin chào"}
                        ],
                        model="llama-3.3-70b-versatile",
                        temperature=0.9,
                        max_tokens=1024,
                    )
                    
                    response = chat_completion.choices[0].message.content
                    if response:
                        await message.reply(response)
                    else:
                        await message.reply("Vô tri quá tui chưa nghĩ ra gì để rep luôn á 💀")

                except Exception as e:
                    print(f"Lỗi Groq: {e}")
                    await message.reply(f"❌ Groq đang cook rồi Khôi ơi: `{str(e)[:100]}`")

def setup(bot):
    bot.add_cog(AIChat(bot))
