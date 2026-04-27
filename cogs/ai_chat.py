import disnake as discord
from disnake.ext import commands
import google.generativeai as genai
import os

# Cấu hình Gemini
api_key = os.environ.get("GEMINI_KEY")
if api_key:
    genai.configure(api_key=api_key)
    # Sử dụng gemini-1.5-flash: Nhanh hơn, nhẹ hơn và ít lỗi vùng mi
    model = genai.GenerativeModel(
        model_name='gemini-1.5-flash', 
        safety_settings=[
            {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"},
        ]
    )
else:
    print("❌ LỖI: Chưa cấu hình GEMINI_KEY trên Render!")

class AIChat(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        # ID kênh đã được cập nhật theo tin nhắn của bạn
        self.target_channel_id = 1497555474852089947
        self.log_channel_id = 1498324476851392612

    @commands.Cog.listener()
    async def on_message(self, message):
        if message.author.bot:
            return

        is_mentioned = self.bot.user in message.mentions
        is_in_target_channel = message.channel.id == self.target_channel_id

        if is_mentioned or is_in_target_channel:
            async with message.channel.typing():
                try:
                    # Lọc sạch tag để AI nhận diện câu hỏi tốt nhất
                    prompt = message.content.replace(f'<@!{self.bot.user.id}>', '').replace(f'<@{self.bot.user.id}>', '').strip()
                    
                    if not prompt:
                        prompt = "Chào bạn!"

                    response = model.generate_content(prompt)
                    
                    # Xử lý phản hồi an toàn
                    try:
                        bot_response = response.text
                    except Exception:
                        bot_response = "🛡️ Nội dung này bị hệ thống an toàn của Google chặn rồi!"

                    await message.reply(bot_response)

                    # Lưu Log vào kênh riêng
                    log_channel = self.bot.get_channel(self.log_channel_id)
                    if log_channel:
                        embed = discord.Embed(title="📝 AI Chat Log", color=0x3498db)
                        embed.add_field(name="Người dùng", value=f"{message.author}", inline=True)
                        embed.add_field(name="Câu hỏi", value=prompt[:1024], inline=False)
                        embed.add_field(name="AI trả lời", value=bot_response[:1024], inline=False)
                        await log_channel.send(embed=embed)

                except Exception as e:
                    error_str = str(e)
                    print(f"Lỗi AI chi tiết: {error_str}")
                    
                    if "API_KEY_INVALID" in error_str or "expired" in error_str:
                        await message.reply("🔑 Lỗi: API Key của Gemini bị sai hoặc hết hạn rồi ông chủ ơi!")
                    elif "location" in error_str.lower():
                        await message.reply("🌍 Lỗi: Vùng này (Region) chưa được Google hỗ trợ AI. Hãy đổi Region trên Render sang Singapore!")
                    else:
                        await message.reply(f"😅 Lỗi rồi: `{error_str[:50]}...`")

def setup(bot):
    bot.add_cog(AIChat(bot))
