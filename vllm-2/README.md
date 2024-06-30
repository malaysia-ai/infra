# OpenAI Compatible Server

vLLM provides an HTTP server that implements OpenAI’s Completions and Chat API.

To call the server, you can use the official OpenAI Python client library, or any other HTTP client.
```python
from openai import OpenAI
client = OpenAI(
    base_url="https://ariff-vllm.us-east2.mesolitica.com/v1",
    api_key="token-abc123",
)

completion = client.chat.completions.create(
  model="mistralai/Mistral-7B-v0.1",
  messages=[
    {"role": "user", "content": "saya lapar"}
  ]
)

print(completion.choices[0].message)
```

Reference [here](https://docs.vllm.ai/en/stable/serving/openai_compatible_server.html#openai-compatible-server)