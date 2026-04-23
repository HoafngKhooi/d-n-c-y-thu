import disnake as discord
from disnake.ext import commands

class Nuke(commands.Cog):
    def __init__(self, bot):
        self.bot = bot

    @commands.command()
    @commands.has_permissions(manage_channels=True)
    async def nuke(self, ctx):
        """Xóa sạch lịch sử bằng cách tạo lại kênh mới"""
        # Lưu lại thông tin kênh cũ
        position = ctx.channel.position
        name = ctx.channel.name
        category = ctx.channel.category
        overwrites = ctx.channel.overwrites
        topic = ctx.channel.topic

        await ctx.send("🧨 Đang kích hoạt chế độ dọn dẹp toàn bộ...")

        # Tạo kênh mới y hệt kênh cũ
        new_channel = await ctx.guild.create_text_channel(
            name=name,
            category=category,
            position=position,
            overwrites=overwrites,
            topic=topic,
            reason=f"Nuke bởi {ctx.author}"
        )

        # Xóa kênh cũ
        await ctx.channel.delete()

        # Nhắn tin xác nhận ở kênh mới
        await new_channel.send(f"🚀 Kênh đã được dọn sạch lịch sử bởi {ctx.author.mention}!")
        await new_channel.send("https://tenor.com/view/explosion-nuke-boom-nuclear-gif-15332822")

def setup(bot):
    bot.add_cog(Nuke(bot))
