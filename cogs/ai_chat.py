import disnake as discord
from disnake.ext import commands
from google import genai
import os

# Khởi tạo client với API Version v1 (Bản ổn định)
client = genai.Client(
    api_key=os.environ.get("GEMINI_KEY"),
    http_options={'api_version': 'v1'}
)

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
                    response = client.models.generate_content(
                        model="gemini-1.5-flash", 
                        contents=prompt or "Xin chào"
                    )
                    await message.reply(response.text or "😅 AI không phản hồi.")
                except Exception as e:
                    print(f"Lỗi: {e}")
                    await message.reply(f"❌ Lỗi: `{str(e)[:100]}`")

def setup(bot):
    bot.add_cog(AIChat(bot))
