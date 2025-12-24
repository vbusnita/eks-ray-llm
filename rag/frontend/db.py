import sqlite3
import os
from datetime import datetime

DB_PATH = os.path.join(os.path.dirname(__file__), "chat_history.db")

def init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("""CREATE TABLE IF NOT EXISTS threads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )""")
    c.execute("""CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        thread_id INTEGER,
        role TEXT,
        content TEXT,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (thread_id) REFERENCES threads (id)
    )""")
    conn.commit()
    conn.close()

def get_threads():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("SELECT id, title, created_at FROM threads ORDER BY created_at DESC")
    threads = c.fetchall()
    conn.close()
    return threads

def get_messages(thread_id):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("SELECT role, content FROM messages WHERE thread_id = ? ORDER BY timestamp", (thread_id,))
    messages = [{"role": role, "content": content} for role, content in c.fetchall()]
    conn.close()
    return messages

def create_thread(title="New Chat"):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("INSERT INTO threads (title) VALUES (?)", (title,))
    thread_id = c.lastrowid
    conn.commit()
    conn.close()
    return thread_id

def save_message(thread_id, role, content):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("INSERT INTO messages (thread_id, role, content) VALUES (?, ?, ?)", (thread_id, role, content))
    conn.commit()
    conn.close()