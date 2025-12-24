import streamlit as st
from ask_repo import ask_repo
from db import init_db, get_threads, get_messages, create_thread, save_message

# Initialize DB on first run
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
    threads = get_threads()
    thread_options = {f"{t[2][:10]} — {t[1]}": t[0] for t in threads}
    thread_options["New Chat"] = None

    selected = st.selectbox("Load a thread or start new", options=list(thread_options.keys()))

    if st.button("Delete Selected Thread") and selected != "New Chat":
        # TODO: Add delete function in Milestone 4
        st.warning("Delete coming in next milestone")

# Initialize session state
if "thread_id" not in st.session_state:
    st.session_state.thread_id = None
if "messages" not in st.session_state:
    st.session_state.messages = []

# Load selected thread
if selected != "New Chat":
    thread_id = thread_options[selected]
    if st.session_state.thread_id != thread_id:
        st.session_state.thread_id = thread_id
        st.session_state.messages = get_messages(thread_id)
else:
    if st.session_state.thread_id is None:
        st.session_state.thread_id = create_thread()

# Display messages
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# Input
if prompt := st.chat_input("Ask about your codebase..."):
    # Save user message
    save_message(st.session_state.thread_id, "user", prompt)
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # Get and save Grok response
    with st.chat_message("assistant"):
        with st.spinner("Grok is thinking..."):
            response = ask_repo(prompt)
        st.markdown(response)

    save_message(st.session_state.thread_id, "assistant", response)
    st.session_state.messages.append({"role": "assistant", "content": response})

st.caption("Powered by xAI Grok Collections • History saved locally")