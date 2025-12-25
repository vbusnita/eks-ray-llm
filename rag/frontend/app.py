import streamlit as st
from ask_repo import ask_repo
from theme import apply_theme

# Apply theme (keeps the premium look)
apply_theme()

st.set_page_config(page_title="eks-ray-llm Assistant", page_icon="🚀", layout="centered")

st.title("🚀 eks-ray-llm Repo Assistant")
st.markdown("**Your AI co-pilot for distributed LLM inference on EKS + Ray + vLLM**")

# Initialize messages
if "messages" not in st.session_state:
    st.session_state.messages = []

# Display history with selective delete
for idx, message in enumerate(st.session_state.messages):
    with st.chat_message(message["role"]):
        col_msg, col_del = st.columns([10, 1])
        with col_msg:
            st.markdown(message["content"])
        with col_del:
            if message["role"] == "assistant":  # Only show delete on Grok answers
                if st.button("🗑️", key=f"del_{idx}", help="Delete this Q&A"):
                    # Remove both user prompt and assistant answer (2 items)
                    if idx > 0:  # safety
                        st.session_state.messages.pop(idx)      # remove answer
                        st.session_state.messages.pop(idx - 1)  # remove question
                    st.rerun()

# Input
if prompt := st.chat_input("Ask about your codebase..."):
    # User message
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # Grok response
    with st.chat_message("assistant"):
        with st.spinner("Grok is thinking..."):
            response = ask_repo(prompt)
        st.markdown(response)

    st.session_state.messages.append({"role": "assistant", "content": response})

st.caption("Powered by xAI Grok Collections • History preserved in session")