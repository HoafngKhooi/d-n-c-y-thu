import disnake as discord
from disnake.ext import commands
from google import genai # Import theo chuẩn SDK mới
import os

# Cấu hình Client mới
client = genai.Client(api_key=os.environ.get("GEMINI_KEY"))

class AIChat(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.target_channel_id = 1497555474852089947

    @commands.Cog.listener()
    async def on_message(self, message):
        if message.author.bot: return

        if self.bot.user in message.mentions or message.channel.id == self.target_channel_id:
            async with message.channel.typing():
                try:
                    prompt = message.content.replace(f'<@!{self.bot.user.id}>', '').replace(f'<@{self.bot.user.id}>', '').strip()
                    if not prompt: prompt = "Xin chào"

                    # Cách gọi model mới của Gemini 2.0/1.5
                    response = client.models.generate_content(
                        model="gemini-1.5-flash",
                        contents=prompt
                    )
                    
                    if response.text:
                        await message.reply(response.text)
                    else:
                        await message.reply("😅 Tui chưa nghĩ ra câu trả lời, thử lại nhé!")

                except Exception as e:
                    print(f"Lỗi AI: {e}")
                    await message.reply(f"❌ Lỗi hệ thống (SDK mới): `{str(e)[:100]}`")

def setup(bot):
    bot.add_cog(AIChat(bot))
