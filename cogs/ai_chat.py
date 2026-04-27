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
        # --- CÀI ĐẶT ID Ở ĐÂY ---
        self.target_channel_id = 1497555474852089947  # ID kênh cho phép AI chat tự do
        self.log_channel_id = 1498324476851392612    # ID kênh riêng tư để bạn xem log

    @commands.Cog.listener()
    async def on_message(self, message):
        # Không trả lời tin nhắn của chính Bot
        if message.author == self.bot.user:
            return

        # Kiểm tra điều kiện: Được tag tên HOẶC đang ở trong kênh chat tự do
        is_mentioned = self.bot.user in message.mentions
        is_in_target_channel = message.channel.id == self.target_channel_id

        if is_mentioned or is_in_target_channel:
            # Nếu ở kênh khác mà không tag thì bơ luôn
            if not is_in_target_channel and not is_mentioned:
                return

            async with message.channel.typing():
                try:
                    # Gửi câu hỏi cho Gemini
                    prompt = message.content.replace(f'<@!{self.bot.user.id}>', '').strip()
                    if not prompt: prompt = "Chào bạn!"
                    
                    response = model.generate_content(prompt)
                    bot_response = response.text

                    # Trả lời trong Discord
                    await message.reply(bot_response)

                    # --- LƯU LOG VÀO KÊNH DISCORD RIÊNG ---
                    log_channel = self.bot.get_channel(self.log_channel_id)
                    if log_channel:
                        embed = discord.Embed(title="📝 AI Chat Log", color=0x3498db)
                        embed.add_field(name="Người dùng", value=f"{message.author} ({message.author.id})", inline=True)
                        embed.add_field(name="Kênh", value=message.channel.name, inline=True)
                        embed.add_field(name="Câu hỏi", value=prompt[:1024], inline=False)
                        embed.add_field(name="AI trả lời", value=bot_response[:1024], inline=False)
                        await log_channel.send(embed=embed)

                except Exception as e:
                    print(f"Lỗi AI: {e}")
                    await message.reply("😅 Hình như tui đang bị quá tải, thử lại sau chút nhé!")

def setup(bot):
    bot.add_cog(AIChat(bot))
