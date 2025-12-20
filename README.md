# eks-ray-llm
Deploy a small-to-medium LLM (start with Meta-Llama-3.1-8B-Instruct or Mistral-7B-Instruct for lower cost) for inference on an AWS EKS cluster using Ray Serve + vLLM backend.

- Architecture note: "Local demo uses dummy; cluster version will use vLLM for high-throughput."
- Output for the Dummy LLM test:
```bash 
curl http://127.0.0.1:8000/v1 \
  -H "Content-Type: application/json" \
  -d '{"prompt": "What is the meaning of life?"}'

{"text":"[Dummy LLM] You said: What is the meaning of life?. I'm running on Ray Serve!","model":"Dummy-LLM-v1"}```