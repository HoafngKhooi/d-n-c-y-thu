import disnake as discord
from disnake.ext import commands
from flask import Flask
from threading import Thread
import os

# --- PHẦN 1: TẠO WEB MINI ĐỂ "LỪA" RENDER ---
app = Flask('')

@app.route('/')
def home():
    return "Bot đang chạy 24/7!"

def run():
    app.run(host='0.0.0.0', port=8080)

def keep_alive():
    t = Thread(target=run)
    t.start()

# --- PHẦN 2: CODE BOT DISCORD ---
intents = discord.Intents.all()
bot = commands.Bot(command_prefix="!", intents=intents)

@bot.event
async def on_ready():
    print(f"✅ Bot {bot.user} đã online!")

@bot.command()
async def ping(ctx):
    await ctx.send("Pong! Bot vẫn đang sống khỏe!")

# --- PHẦN 3: CHẠY CẢ HAI ---
if __name__ == "__main__":
    keep_alive() # Chạy web trước
    token = os.environ.get('DISCORD_TOKEN') # Lấy token từ môi trường (bảo mật)
    bot.run(token)