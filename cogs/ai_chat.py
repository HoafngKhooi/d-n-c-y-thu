import disnake as discord
from disnake.ext import commands
import google.generativeai as genai
import os

# Cấu hình Gemini
api_key = os.environ.get("GEMINI_KEY")
genai.configure(api_key=api_key)

# HÀM CHỌN MODEL THÔNG MINH (Tránh lỗi 404)
def get_model():
    try:
        # Thử dùng bản flash mới nhất
        return genai.GenerativeModel('gemini-1.5-flash')
    except:
        # Nếu không được thì dùng bản dự phòng phổ biến nhất
        return genai.GenerativeModel('gemini-pro')

model = get_model()

class AIChat(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.target_channel_id = 1497555474852089947

    @commands.Cog.listener()
    async def on_message(self, message):
        if message.author.bot: return

        # Kiểm tra nếu được tag hoặc trong đúng kênh chat
        if self.bot.user in message.mentions or message.channel.id == self.target_channel_id:
            async with message.channel.typing():
                try:
                    # Lấy nội dung chat (bỏ tag bot)
                    prompt = message.content.replace(f'<@!{self.bot.user.id}>', '').replace(f'<@{self.bot.user.id}>', '').strip()
                    if not prompt: prompt = "Xin chào"

                    # Gọi AI với cơ chế bắt lỗi chi tiết
                    response = model.generate_content(prompt)
                    
                    if response.text:
                        await message.reply(response.text)
                    else:
                        await message.reply("😅 Tui chưa nghĩ ra câu trả lời, thử lại nhé!")

                except Exception as e:
                    error_msg = str(e)
                    print(f"Lỗi AI: {error_msg}")
                    # Nếu lỗi Key, báo cho chủ nhân biết
                    if "API_KEY_INVALID" in error_msg or "expired" in error_msg:
                        await message.reply("❌ Lỗi: API Key của Gemini đã hết hạn hoặc không hợp lệ. Khôi ơi cập nhật Key đi!")
                    else:
                        await message.reply(f"❌ Lỗi hệ thống: `{error_msg[:100]}`")

def setup(bot):
    bot.add_cog(AIChat(bot))
