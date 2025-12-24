import streamlit as st
from ask_repo import ask_repo

st.set_page_config(page_title="eks-ray-llm Assistant", layout="centered", initial_sidebar_state="collapsed")

st.title("🚀 eks-ray-llm Repo Assistant")
st.markdown("""
**Your personal AI co-pilot for distributed LLM inference on EKS + Ray + vLLM**

Ask anything about your codebase. Grok retrieves from the synced collection and answers with file references.
""")

question = st.text_input("What do you want to know?", placeholder="e.g., How do I add GPU support?")

if st.button("Ask Grok"):
    if question:
        with st.spinner("Grok is thinking..."):
            answer = ask_repo(question)
        st.markdown("### Answer")
        st.markdown(answer)
    else:
        st.warning("Please enter a question.")

st.caption("Powered by xAI Grok Collections • Auto-synced on every commit")