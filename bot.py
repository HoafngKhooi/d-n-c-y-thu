import disnake as discord
from disnake.ext import commands
import os
from flask import Flask
from threading import Thread

# --- WEB KEEP ALIVE ---
app = Flask('')
@app.route('/')
def home(): return "Bot is Online!"

def run(): app.run(host='0.0.0.0', port=8080)
def keep_alive():
    t = Thread(target=run)
    t.start()

# --- BOT SETUP ---
intents = discord.Intents.all()
bot = commands.Bot(command_prefix="!", intents=intents)

@bot.event
async def on_ready():
    print(f"✅ Đã kích hoạt Bot: {bot.user}")

# --- TỰ ĐỘNG KÍCH HOẠT CÁC FILE TRONG FOLDER COGS ---
for filename in os.listdir('./cogs'):
    if filename.endswith('.py'):
        try:
            bot.load_extension(f'cogs.{filename[:-3]}')
            print(f'⚡ Đã nạp tính năng: {filename}')
        except Exception as e:
            print(f'❌ Lỗi khi nạp {filename}: {e}')

if __name__ == "__main__":
    keep_alive()
    token = os.environ.get('DISCORD_TOKEN')
    bot.run(token)
