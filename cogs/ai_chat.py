import disnake as discord
from disnake.ext import commands
import google.generativeai as genai
import os

# Cấu hình Gemini
api_key = os.environ.get("GEMINI_KEY")
genai.configure(api_key=api_key)

# Dùng model Flash cho nhẹ và chuẩn 2026
model = genai.GenerativeModel(
    model_name='models/gemini-1.5-flash',
    safety_settings=[
        {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
        {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
        {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"},
        {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"},
    ]
)

class AIChat(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.target_channel_id = 1497555474852089947
        self.log_channel_id = 1498324476851392612

    @commands.Cog.listener()
    async def on_message(self, message):
        if message.author.bot: return

        is_mentioned = self.bot.user in message.mentions
        is_in_target_channel = message.channel.id == self.target_channel_id

        if is_mentioned or is_in_target_channel:
            async with message.channel.typing():
                try:
                    # Lấy nội dung và xóa tag bot
                    content = message.content.replace(f'<@!{self.bot.user.id}>', '').replace(f'<@{self.bot.user.id}>', '').strip()
                    if not content: content = "Chào bot"

                    response = model.generate_content(content)
                    
                    if response.text:
                        await message.reply(response.text)
                        
                        # Gửi log vào kênh riêng
                        log_chan = self.bot.get_channel(self.log_channel_id)
                        if log_chan:
                            await log_chan.send(f"**User:** {message.author}\n**Hỏi:** {content}\n**Bot:** {response.text[:500]}")
                    else:
                        await message.reply("🛡️ AI từ chối phản hồi do chính sách nội dung.")
                except Exception as e:
                    print(f"Lỗi: {e}")
                    await message.reply(f"❌ Lỗi: `{str(e)[:100]}`")

def setup(bot):
    bot.add_cog(AIChat(bot))
