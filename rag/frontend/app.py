import streamlit as st
from ask_repo import ask_repo
from db import init_db, get_threads, get_messages, create_thread, save_message, delete_thread, update_thread_title

# Initialize DB
init_db()

st.set_page_config(
    page_title="eks-ray-llm Assistant",
    page_icon="🚀",
    layout="centered"
)

st.title("🚀 eks-ray-llm Repo Assistant")
st.markdown("**Your AI co-pilot for distributed LLM inference on EKS + Ray + vLLM**")

# Sidebar: Thread management
with st.sidebar:
    st.header("Chat History")

    # New Chat button
    if st.button("🆕 Start New Chat"):
        st.session_state.thread_id = create_thread("New Chat")
        st.session_state.messages = []
        st.rerun()

    threads = get_threads()
    if threads:
        for thread in threads:
            thread_id, title, created_at = thread
            created_str = created_at.strftime("%b %d · %H:%M")

            col1, col2, col3 = st.columns([5, 1, 1])
            with col1:
                # Editable title
                new_title = st.text_input(
                    label=f"Thread {thread_id}",
                    value=title,
                    key=f"title_{thread_id}",
                    label_visibility="collapsed"
                )
                if new_title != title:
                    update_thread_title(thread_id, new_title)
                    st.rerun()

                if st.button(f"{created_str} — {new_title[:40]}{'...' if len(new_title) > 40 else ''}", 
                            key=f"load_{thread_id}", use_container_width=True):
                    if st.session_state.get("thread_id") != thread_id:
                        st.session_state.thread_id = thread_id
                        st.session_state.messages = get_messages(thread_id)
                        st.rerun()
            with col3:
                if st.button("🗑️", key=f"del_{thread_id}"):
                    delete_thread(thread_id)
                    if st.session_state.get("thread_id") == thread_id:
                        st.session_state.thread_id = None
                        st.session_state.messages = []
                    st.rerun()
    else:
        st.info("No chat history yet — start a conversation!")

# Initialize current thread
if "thread_id" not in st.session_state or st.session_state.thread_id is None:
    st.session_state.thread_id = create_thread("New Chat")
    st.session_state.messages = []

# Auto-title from first user message (once)
if st.session_state.messages and len(st.session_state.messages) >= 1:
    first_msg = st.session_state.messages[0]
    if first_msg["role"] == "user":
        auto_title = first_msg["content"][:60] + ("..." if len(first_msg["content"]) > 60 else "")
        # Update if still default
        current_title = next((t[1] for t in get_threads() if t[0] == st.session_state.thread_id), "")
        if "New Chat" in current_title or current_title == "":
            update_thread_title(st.session_state.thread_id, auto_title)

# Display messages
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# Input
if prompt := st.chat_input("Ask about your codebase..."):
    save_message(st.session_state.thread_id, "user", prompt)
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    with st.chat_message("assistant"):
        with st.spinner("Grok is thinking..."):
            response = ask_repo(prompt)
        st.markdown(response)

    save_message(st.session_state.thread_id, "assistant", response)
    st.session_state.messages.append({"role": "assistant", "content": response})

st.caption("Powered by xAI Grok Collections • Local history • Rename & delete to curate gold")