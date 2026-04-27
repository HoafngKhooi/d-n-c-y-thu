import disnake as discord
from disnake.ext import commands
import google.generativeai as genai
import os

# Cấu hình Gemini
genai.configure(api_key=os.environ.get("GEMINI_KEY"))

# ÉP BUỘC dùng gemini-1.5-flash để không bị lỗi 404
model = genai.GenerativeModel(
    model_name='gemini-1.5-flash',
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
                    prompt = message.content.replace(f'<@!{self.bot.user.id}>', '').replace(f'<@{self.bot.user.id}>', '').strip()
                    if not prompt: prompt = "Chào bạn!"

                    # Gọi AI
                    response = model.generate_content(prompt)
                    
                    if response.text:
                        await message.reply(response.text)
                    else:
                        await message.reply("🛡️ Nội dung bị chặn do chính sách an toàn.")

                except Exception as e:
                    print(f"Lỗi AI: {e}")
                    # Hiện lỗi thật ra Discord để ông nhìn cho rõ
                    await message.reply(f"❌ Lỗi: `{str(e)[:100]}`")

def setup(bot):
    bot.add_cog(AIChat(bot))
