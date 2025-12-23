from xai_sdk import Client
import os

client = Client(
    api_key=os.getenv("XAI_API_KEY"),                  
    management_api_key=os.getenv("XAI_MANAGEMENT_API_KEY")
)

collection = client.collections.create(
    name="eks-ray-llm repo knowledge base",
    model_name="grok-embedding-small"
)

print(f"Collection created!")
print(f"ID: {collection.collection_id}")