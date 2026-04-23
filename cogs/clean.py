import disnake as discord
from disnake.ext import commands
import asyncio

class Clean(commands.Cog):
    def __init__(self, bot):
        self.bot = bot

    @commands.command()
    @commands.has_permissions(manage_messages=True)
    async def cleanall(self, ctx):
        """Xóa sạch tin nhắn trong kênh (giới hạn 14 ngày gần nhất)"""
        await ctx.send("🧹 Đang bắt đầu dọn dẹp toàn bộ tin nhắn... Vui lòng đợi.")
        
        # Xóa toàn bộ tin nhắn mà bot có thể tìm thấy
        # check=lambda m: True nghĩa là xóa mọi tin nhắn không ngoại lệ
        deleted = await ctx.channel.purge(limit=None, check=lambda m: True)
        
        # Nhắn tin thông báo kết quả và tự xóa thông báo đó sau 5 giây
        await ctx.send(f"✅ Đã dọn dẹp sạch sẽ {len(deleted)} tin nhắn!", delete_after=5)

def setup(bot):
    bot.add_cog(Clean(bot))
