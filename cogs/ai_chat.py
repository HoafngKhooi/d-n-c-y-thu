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
        if message.author.bot: return

        is_mentioned = self.bot.user in message.mentions
        is_in_channel = message.channel.id == self.target_channel_id

        if is_mentioned or is_in_channel:
            async with message.channel.typing():
                try:
                    prompt = message.content.replace(f'<@!{self.bot.user.id}>', '').replace(f'<@{self.bot.user.id}>', '').strip()
                    
                    # System Prompt bản 2026 - Modern Gen Z (Threads/TikTok/Facebook vibes)
                    system_message = (
                        "Bạn là một Gen Z (2002-2006), nhạy bén và nhảy số cực nhanh. "
                        "Ngôn ngữ: Tự do, không gò bó, sử dụng tiếng Việt hiện đại của giới trẻ trên TikTok, Facebook, Threads. "
                        "Bạn hiểu rõ và có thể sử dụng các từ viết tắt/từ lóng phổ biến: vcl (vô cùng lớn/vãi cả lìn), vch (vãi chưởng/vãi cả họ), "
                        "t (tao), m (mày), k (không), j (gì),... và các thuật ngữ mới như check var, cook, đỏ lỏn, lụy, pressing, nết, vô tri,..."
                        "Bạn không lạm dụng danh sách từ có sẵn mà hãy tự dựa vào hiểu biết về cách nói chuyện thực tế của giới trẻ để phản hồi tự nhiên nhất. "
                        "Phong cách: Trả lời ngắn, gọn, đúng trọng tâm như đang chat Discord/Messenger. "
                        "Tuyệt đối không đóng vai trợ lý AI. Phải có cái tôi, biết đùa, biết cà khịa hoặc nghiêm túc đúng lúc (nhất là khi giải Toán, Lý). "
                        "Biết dùng emoji linh hoạt (💀, 🤡, 💅, 🐧, 🦖,...) để biểu thị thái độ."
                    )

                    chat_completion = client.chat.completions.create(
                        messages=[
                            {"role": "system", "content": system_message},
                            {"role": "user", "content": prompt or "lô"}
                        ],
                        model="llama-3.3-70b-versatile",
                        temperature=0.9, # Giữ mức cao để nó tự do 'nhảy số'
                        max_tokens=1024,
                    )
                    
                    response = chat_completion.choices[0].message.content
                    if response:
                        await message.reply(response)
                    else:
                        await message.reply("Vô tri quá chưa nghĩ ra gì rep 💀")

                except Exception as e:
                    print(f"Lỗi Groq: {e}")
                    await message.reply(f"❌ Groq đang cook rồi Khôi ơi: `{str(e)[:100]}`")

def setup(bot):
    bot.add_cog(AIChat(bot))
