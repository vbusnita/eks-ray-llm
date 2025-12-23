import os
from dotenv import load_dotenv
from xai_sdk import Client

# Load .env from repo root
load_dotenv(dotenv_path=os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env"))

# Config
client = Client(
    api_key=os.getenv("XAI_API_KEY"),
    management_api_key=os.getenv("XAI_MANAGEMENT_API_KEY")
)
collection_id = os.getenv("XAI_COLLECTION_ID")

if not collection_id:
    raise ValueError("XAI_COLLECTION_ID not found in .env — check your root .env file!")

repo_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))  # Repo root

# Directories and patterns to skip
unwanted_dirs = {'.git', '__pycache__', '.terraform', '.venv', 'node_modules', '.terraform.lock.hcl'}
skip_extensions = {'~', '.bak'}
skip_large_mb = 20  # Skip files >20MB (Collections prefers text/code)

print(f"Starting full repo upload to collection {collection_id}")
print(f"Repo path: {repo_path}\n")

uploaded_count = 0

for root, dirs, files in os.walk(repo_path):
    # Prune unwanted dirs in-place
    dirs[:] = [d for d in dirs if d not in unwanted_dirs]

    for file in files:
        if any(file.endswith(ext) for ext in skip_extensions) or file.startswith('.'):
            continue

        file_path = os.path.join(root, file)
        rel_path = os.path.relpath(file_path, repo_path)

        # Skip large files
        try:
            if os.path.getsize(file_path) > skip_large_mb * 1024 * 1024:
                print(f"Skipping large file (>20MB): {rel_path}")
                continue
        except OSError:
            continue

        try:
            with open(file_path, "rb") as f:
                data = f.read()

            client.collections.upload_document(
                collection_id=collection_id,
                name=rel_path,  # Critical: preserves folder structure
                data=data,
            )
            print(f"Uploaded: {rel_path}")
            uploaded_count += 1
        except Exception as e:
            print(f"Error uploading {rel_path}: {str(e)}")

print(f"\nFull upload complete! {uploaded_count} files uploaded.")
print("Indexing in progress — check console.x.ai → Collections for status.")