import ray
from ray import serve
from fastapi import Request
import json

ray.init(address="local")  # Local mode for testing

@serve.deployment(num_replicas=1, ray_actor_options={"num_cpus": 1})
class DummyLLM:
    def __init__(self):
        self.model_name = "Dummy-LLM-v1"

    async def __call__(self, request: Request):
        data = await request.json()
        prompt = data.get("prompt", "Hello")
        # Fake response
        response = f"[Dummy LLM] You said: {prompt}. I'm running on Ray Serve!"
        return {"text": response, "model": self.model_name}

# Bind and run
app = DummyLLM.bind()

# Run the server
if __name__ == "__main__":
    serve.run(app, route_prefix="/v1")
    print("Ray Serve running at http://127.0.0.1:8000/v1")
    # Keep it alive
    import time
    while True:
        time.sleep(1)