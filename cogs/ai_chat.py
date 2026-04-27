import disnake as discord
from disnake.ext import commands
import google.generativeai as genai
import os

# Cấu hình Gemini với chế độ "mở" hơn để tránh lỗi chặn nội dung
genai.configure(api_key=os.environ.get("GEMINI_KEY"))

model = genai.GenerativeModel(
    model_name='gemini-pro',
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
        # Nhớ thay ID thật của bạn vào đây
        self.target_channel_id = 1497555474852089947
        self.log_channel_id = 1498324476851392612

    @commands.Cog.listener()
    async def on_message(self, message):
        if message.author == self.bot.user:
            return

        is_mentioned = self.bot.user in message.mentions
        is_in_target_channel = message.channel.id == self.target_channel_id

        if is_mentioned or is_in_target_channel:
            if not is_in_target_channel and not is_mentioned:
                return

            async with message.channel.typing():
                try:
                    # Lọc bỏ phần tag bot trong tin nhắn để AI không bị nhầm lẫn
                    prompt = message.content.replace(f'<@!{self.bot.user.id}>', '').replace(f'<@{self.bot.user.id}>', '').strip()
                    
                    if not prompt:
                        prompt = "Chào bạn, tôi có thể giúp gì?"

                    response = model.generate_content(prompt)
                    
                    # Kiểm tra xem Gemini có trả về kết quả không hay bị chặn
                    if response.parts:
                        bot_response = response.text
                    else:
                        bot_response = "😅 Nội dung này hơi 'căng', Gemini từ chối trả lời rồi!"

                    await message.reply(bot_response)

                    # Lưu Log
                    log_channel = self.bot.get_channel(self.log_channel_id)
                    if log_channel:
                        embed = discord.Embed(title="📝 AI Chat Log", color=0x3498db)
                        embed.add_field(name="Người dùng", value=f"{message.author}", inline=True)
                        embed.add_field(name="Câu hỏi", value=prompt[:1024], inline=False)
                        embed.add_field(name="AI trả lời", value=bot_response[:1024], inline=False)
                        await log_channel.send(embed=embed)

                except Exception as e:
                    print(f"Lỗi AI: {e}")
                    # Nếu lỗi do an toàn, báo cho người dùng biết
                    if "safety" in str(e).lower():
                        await message.reply("🛡️ Câu hỏi vi phạm chính sách an toàn của AI nên tui không trả lời được!")
                    else:
                        await message.reply("😅 Gemini đang bận tí, thử lại sau vài giây nhé!")

def setup(bot):
    bot.add_cog(AIChat(bot))
