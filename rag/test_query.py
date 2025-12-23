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

response = client.collections.search(
        query=query,
        collection_ids=[collection_id],
        limit=12,
        retrieval_mode="hybrid"
    )

# The field is .matches (repeated Match message)
results = response.matches

print(f"Found {len(results)} relevant chunks:\n")

for i, r in enumerate(results, 1):
    # File name from the document in the match
    file_name = r.file_id  # Fallback if no name; but usually r.document.name if wrapped
    # From raw: it's r.chunk_content, score, etc.
    # Better: many have r.document.name? From raw no, but let's use file_id or extract

    # From your raw output: no r.document.name — it's direct chunk_content, score
    print(f"{i}. Score: {r.score:.4f} | File ID: {r.file_id} | Chunk ID: {r.chunk_id}")
    print("-" * 60)
    text_preview = r.chunk_content.strip()[:1000]
    print(text_preview)
    if len(r.chunk_content) > 1000:
        print("...")
    print("\n")