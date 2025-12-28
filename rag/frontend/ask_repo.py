import os
from dotenv import load_dotenv
from xai_sdk import Client
from xai_sdk.chat import user
from xai_sdk.tools import collections_search

# Load .env from repo root
load_dotenv(dotenv_path=os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), ".env"))

client = Client(api_key=os.getenv("XAI_API_KEY"))
collection_id = os.getenv("XAI_COLLECTION_ID")

def ask_repo(question: str, model: str = "grok-4"):
    # Create stateful Chat with tools
    chat = client.chat.create(
        model=model,
        tools=[
            collections_search(
                collection_ids=[collection_id],
                limit=20,
                retrieval_mode="hybrid"
            )
        ],
    )

    # Embed expertise + question in user message
    full_prompt = (
        "You are an expert in distributed LLM inference on Kubernetes using Ray (KubeRay), vLLM, and AWS EKS. "
        "Use the retrieved context from the eks-ray-llm repo to answer accurately. "
        "Always reference specific files and line patterns when possible. "
        "Be proactive: suggest optimizations, highlight potential issues, and propose next steps.\n\n"
        f"Question: {question}"
    )

    # Append the user message
    chat.append(user(full_prompt))

    # Generate the response (agentic: auto-calls tools if needed)
    response = chat.sample()

    return response.content

# Quick test
if __name__ == "__main__":
    question = "Walk me through adding GPU support: new EKS node group in Terraform, taints/tolerations, RayCluster worker specs, and any vLLM considerations."
    print("Question:", question)
    print("\nAnswer:")
    print(ask_repo(question))