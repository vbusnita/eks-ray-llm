import os
from dotenv import load_dotenv
from xai_sdk import Client

# Load .env from repo root
load_dotenv(dotenv_path=os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env"))

client = Client(
    api_key=os.getenv("XAI_API_KEY"),
    management_api_key=os.getenv("XAI_MANAGEMENT_API_KEY")  # Optional for search, but safe to include
)
collection_id = os.getenv("XAI_COLLECTION_ID")

if not collection_id:
    raise ValueError("XAI_COLLECTION_ID not found in root .env!")

# Change this query to test different parts of your repo
query = """
Explain how the RayCluster GPU configuration in manifests/ connects to the EKS node groups 
and instance types defined in Terraform infra/. Include any relevant scaling or taint settings.
"""

print(f"Searching collection: {collection_id}")
print(f"Query: {query.strip()}\n")
print("="*80)

results = client.collections.search(
    query=query,
    collection_ids=[collection_id],
    limit=12,                    # More results = better context visibility
    retrieval_mode="hybrid"      # Optimal for code: semantic + keyword
)

if not results.results:
    print("No results found — check if upload completed and indexing finished.")
else:
    print(f"Found {len(results.results)} relevant chunks:\n")
    for i, r in enumerate(results.results, 1):
        print(f"{i}. File: {r.document.name}  (score: {r.score:.4f})")
        print("-" * 60)
        # Truncate long snippets for readability
        text_preview = r.text.strip()[:1000]
        print(text_preview)
        if len(r.text) > 1000:
            print("...")
        print("\n")