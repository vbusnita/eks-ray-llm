import streamlit as st
from ask_repo import ask_repo

# Page config
st.set_page_config(
    page_title="eks-ray-llm Assistant",
    page_icon="🚀",
    layout="centered",
    initial_sidebar_state="collapsed"
)

st.title("🚀 eks-ray-llm Repo Assistant")
st.markdown("""
**Your personal AI co-pilot for distributed LLM inference on EKS + Ray + vLLM**

Ask anything about your codebase. Grok retrieves from the synced collection and answers with file references.
""")

# Initialize chat history in session state
if "messages" not in st.session_state:
    st.session_state.messages = []

# Display chat history
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# User input
if prompt := st.chat_input("What do you want to know about your codebase?"):
    # Add user message
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # Get Grok response
    with st.chat_message("assistant"):
        with st.spinner("Grok is thinking..."):
            response = ask_repo(prompt)
        st.markdown(response)

    # Add assistant message to history
    st.session_state.messages.append({"role": "assistant", "content": response})

st.caption("Powered by xAI Grok Collections • Auto-synced on every commit")