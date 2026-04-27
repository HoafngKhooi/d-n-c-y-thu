import disnake as discord
from disnake.ext import commands
from google import genai
import os

# Khởi tạo client
client = genai.Client(api_key=os.environ.get("GEMINI_KEY"))

class AIChat(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.target_channel_id = 1497555474852089947
        # Danh sách model dự phòng
        self.models_to_try = [
            "gemini-1.5-flash",
            "gemini-1.5-pro",
            "gemini-1.0-pro"
        ]

    @commands.Cog.listener()
    async def on_message(self, message):
        if message.author.bot: return
        if self.bot.user in message.mentions or message.channel.id == self.target_channel_id:
            async with message.channel.typing():
                prompt = message.content.replace(f'<@!{self.bot.user.id}>', '').replace(f'<@{self.bot.user.id}>', '').strip() or "Xin chào"
                
                success = False
                for model_name in self.models_to_try:
                    try:
                        response = client.models.generate_content(
                            model=model_name,
                            contents=prompt
                        )
                        if response.text:
                            await message.reply(response.text)
                            success = True
                            break # Chạy được là dừng luôn
                    except Exception as e:
                        print(f"Thử {model_name} thất bại: {e}")
                        continue # Lỗi thì thử model tiếp theo
                
                if not success:
                    await message.reply("❌ Tất cả model đều đang bị Google chặn vùng hoặc API Key lỗi rồi Khôi ơi!")

def setup(bot):
    bot.add_cog(AIChat(bot))
