import os
import subprocess
from dotenv import load_dotenv
from xai_sdk import Client

# Load .env from repo root
load_dotenv(dotenv_path=os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env"))

client = Client(
    api_key=os.getenv("XAI_API_KEY"),
    management_api_key=os.getenv("XAI_MANAGEMENT_API_KEY")
)
collection_id = os.getenv("XAI_COLLECTION_ID")

if not collection_id:
    raise ValueError("XAI_COLLECTION_ID not found in .env")

repo_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

def get_changed_files(since="HEAD~1"):
    """Get list of changed files in last commit (or adjust for push)"""
    result = subprocess.run(
        ["git", "diff", "--name-only", since],
        capture_output=True, text=True, cwd=repo_path
    )
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]

changed_files = get_changed_files()

if not changed_files:
    print("No changed files detected since last commit.")
    exit(0)

print(f"Syncing {len(changed_files)} changed file(s) to collection {collection_id}...\n")

synced_count = 0

for rel_path in changed_files:
    file_path = os.path.join(repo_path, rel_path)

    if not os.path.exists(file_path) or not os.path.isfile(file_path):
        print(f"Skipping (deleted or not file): {rel_path}")
        continue

    try:
        with open(file_path, "rb") as f:
            data = f.read()

        client.collections.upload_document(
            collection_id=collection_id,
            name=rel_path,
            data=data,
        )
        print(f"Synced: {rel_path}")
        synced_count += 1
    except Exception as e:
        print(f"Error syncing {rel_path}: {str(e)}")

print(f"\nSync complete! {synced_count}/{len(changed_files)} files updated.")