import disnake as discord
from disnake.ext import commands
import google.generativeai as genai
import os

# Cấu hình Gemini
api_key = os.environ.get("GEMINI_KEY")
genai.configure(api_key=api_key)

# Dùng thẳng tên model ổn định nhất năm 2026
model = genai.GenerativeModel('gemini-1.5-flash')

class AIChat(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        # ID kênh chat của ông
        self.target_channel_id = 1497555474852089947

    @commands.Cog.listener()
    async def on_message(self, message):
        # Không trả lời bot khác
        if message.author.bot: return

        # Kiểm tra nếu được tag hoặc nhắn trong kênh chỉ định
        is_mentioned = self.bot.user in message.mentions
        is_in_channel = message.channel.id == self.target_channel_id

        if is_mentioned or is_in_channel:
            async with message.channel.typing():
                try:
                    # Xử lý nội dung tin nhắn
                    content = message.content.replace(f'<@!{self.bot.user.id}>', '').replace(f'<@{self.bot.user.id}>', '').strip()
                    if not content: content = "Xin chào"

                    # Gọi Gemini
                    response = model.generate_content(content)
                    
                    if response.text:
                        await message.reply(response.text)
                    else:
                        await message.reply("😅 AI không phản hồi nội dung này, thử câu khác nha!")

                except Exception as e:
                    error_str = str(e)
                    print(f"Lỗi AI: {error_str}")
                    
                    # Bắt lỗi Key hết hạn hoặc sai
                    if "API_KEY_INVALID" in error_str or "expired" in error_str:
                        await message.reply("❌ Lỗi: API Key Gemini đã hết hạn hoặc sai rồi Khôi ơi!")
                    elif "404" in error_str:
                        await message.reply("❌ Lỗi: Model AI chưa sẵn sàng hoặc sai phiên bản (404).")
                    else:
                        await message.reply(f"❌ Lỗi hệ thống: `{error_str[:100]}`")

def setup(bot):
    bot.add_cog(AIChat(bot))
