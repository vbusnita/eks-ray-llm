import streamlit as st

def apply_theme():
    st.markdown("""
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Global font — Inter everywhere */
        html, body, [class*="css"] {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif !important;
        }

        /* Main background */
        .main {
            background-color: #0a0e17;
        }

        /* Chat messages — premium bubbles */
        section[data-testid="stChatMessage"] {
            background: #1e293b !important;
            border-radius: 16px !important;
            padding: 1.2em !important;
            margin: 1em 0 !important;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.4) !important;
            border: 1px solid #334155 !important;
        }

        /* User message */
        section[data-testid="stChatMessage"] div[data-testid="chatMessageUser"] {
            background: #2563eb !important;
            margin-left: 15% !important;
        }

        /* Assistant message */
        section[data-testid="stChatMessage"] div[data-testid="chatMessageAssistant"] {
            background: #0f172a !important;
            border: 1px solid #3b82f6 !important;
            margin-right: 15% !important;
        }

        /* Code blocks — standout */
        .stMarkdown pre {
            background: #111827 !important;
            border-left: 6px solid #3b82f6 !important;
            padding: 1.5em !important;
            border-radius: 12px !important;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.5) !important;
            font-size: 1.05em !important;
        }

        /* Headings — big and bold */
        .stMarkdown h1 {
            font-size: 2.6em !important;
            color: #60a5fa !important;
            text-align: center !important;
            margin: 1.5em 0 !important;
        }
        .stMarkdown h2 {
            font-size: 2.0em !important;
            color: #93c5fd !important;
            border-bottom: 3px solid #3b82f6 !important;
            padding-bottom: 0.5em !important;
            margin-top: 2em !important;
        }
        .stMarkdown h3 {
            font-size: 1.6em !important;
            color: #bfdbfe !important;
        }
    </style>
    """, unsafe_allow_html=True)