import disnake as discord
from disnake.ext import commands
from google import genai
from google.genai import types # Thêm dòng này
import os

# Cấu hình Client với cấu hình cụ thể
client = genai.Client(
    api_key=os.environ.get("GEMINI_KEY"),
    http_options={'api_version': 'v1'} # Ép dùng bản v1 ổn định, né v1beta bị lỗi 404
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
                    if not prompt: prompt = "Xin chào"

                    # Gọi model với tên đầy đủ
                    response = client.models.generate_content(
                        model="gemini-1.5-flash", 
                        contents=prompt
                    )
                    
                    if response.text:
                        await message.reply(response.text)
                    else:
                        await message.reply("😅 AI đang bận tí, ông thử lại sau nhé!")

                except Exception as e:
                    error_str = str(e)
                    print(f"Lỗi AI: {error_str}")
                    # Bắt lỗi vùng địa lý (Cực kỳ quan trọng trên Render)
                    if "location" in error_str.lower() or "supported" in error_str.lower():
                        await message.reply("❌ Lỗi: Server Render ở Đức/Châu Âu đang bị Google chặn. Khôi hãy đổi Region sang Singapore/Oregon nhé!")
                    else:
                        await message.reply(f"❌ Lỗi: `{error_str[:100]}`")

def setup(bot):
    bot.add_cog(AIChat(bot))
