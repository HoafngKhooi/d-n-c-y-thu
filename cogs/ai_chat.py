import disnake as discord
from disnake.ext import commands
from groq import Groq
import os

# Khởi tạo Groq
client = Groq(api_key=os.environ.get("GROQ_API_KEY"))

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
                    prompt = message.content.replace(f'<@!{self.bot.user.id}>', '').replace(f'<@{self.bot.user.id}>', '').strip() or "Xin chào"
                    
                    # Gọi Llama 3 qua Groq (siêu nhanh)
                    chat_completion = client.chat.completions.create(
                        messages=[{"role": "user", "content": prompt}],
                        model="llama-3.3-70b-versatile",
                    )
                    
                    response = chat_completion.choices[0].message.content
                    await message.reply(response)

                except Exception as e:
                    print(f"Lỗi Groq: {e}")
                    await message.reply(f"❌ Groq lỗi rồi: `{str(e)[:100]}`")

def setup(bot):
    bot.add_cog(AIChat(bot))
