import disnake as discord
from disnake.ext import commands
import os
from flask import Flask
from threading import Thread

app = Flask('')
@app.route('/')
def home(): return "Bot is Online!"

def run(): app.run(host='0.0.0.0', port=8080)
def keep_alive():
    t = Thread(target=run)
    t.start()

intents = discord.Intents.all()
bot = commands.Bot(command_prefix="!", intents=intents)

@bot.event
async def on_ready():
    print(f"✅ Đã kết nối thành công: {bot.user}")

def load_all_cogs():
    if not os.path.exists('./cogs'):
        os.makedirs('./cogs')
    for filename in os.listdir('./cogs'):
        if filename.endswith('.py'):
            try:
                bot.load_extension(f'cogs.{filename[:-3]}')
                print(f'⚡ Đã nạp: {filename}')
            except Exception as e:
                print(f'❌ Lỗi nạp {filename}: {e}')

if __name__ == "__main__":
    keep_alive()
    load_all_cogs()
    token = os.environ.get('DISCORD_TOKEN')
    if token:
        bot.run(token)
    else:
        print("❌ LỖI: Thiếu DISCORD_TOKEN!")
