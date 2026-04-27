import disnake as discord
from disnake.ext import commands
import google.generativeai as genai
import os

# Cấu hình Gemini
genai.configure(api_key=os.environ.get("GEMINI_KEY"))
model = genai.GenerativeModel('gemini-pro')

class AIChat(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.target_channel_id = 123456789  # THAY ID KÊNH CHO PHÉP NHẮN TỰ DO VÀO ĐÂY
        self.log_channel_id = 987654321    # THAY ID KÊNH LƯU LOG VÀO ĐÂY

    @commands.Cog.listener()
    async def on_message(self, message):
        # Không trả lời tin nhắn của chính mình
        if message.author == self.bot.user:
            return

        # Kiểm tra xem có được tag không hoặc có ở trong kênh cho phép không
        is_mentioned = self.bot.user in message.mentions
        is_in_target_channel = message.channel.id == self.target_channel_id

        if is_mentioned or is_in_target_channel:
            # Nếu ở kênh thường mà không tag thì không trả lời
            if not is_in_target_channel and not is_mentioned:
                return

            async with message.channel.typing():
                try:
                    # Gửi nội dung tin nhắn cho Gemini
                    response = model.generate_content(message.content)
                    bot_response = response.text

                    # Gửi câu trả lời về Discord
                    await message.reply(bot_response)

                    # --- PHẦN LƯU LOG ---
                    # Thay vì lưu vào Drive (phức tạp), ta lưu vào 1 kênh Discord kín để bạn dễ xem lại
                    log_channel = self.bot.get_channel(self.log_channel_id)
                    if log_channel:
                        embed = discord.Embed(title="AI Chat Log", color=discord.Color.blue())
                        embed.add_field(name="Người hỏi", value=message.author.name, inline=True)
                        embed.add_field(name="Kênh", value=message.channel.name, inline=True)
                        embed.add_field(name="Nội dung", value=message.content, inline=False)
                        embed.add_field(name="AI trả lời", value=bot_response[:1024], inline=False) # Discord giới hạn 1024 ký tự
                        await log_channel.send(embed=embed)

                except Exception as e:
                    await message.reply(f"❌ Có lỗi khi gọi AI: {e}")

def setup(bot):
    bot.add_cog(AIChat(bot))
