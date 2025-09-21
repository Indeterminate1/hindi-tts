# Hindi TTS API Usage Guide

This guide explains how to use the Hindi TTS API running in your Docker container.

## API Endpoint
- **URL:** `http://<server-ip>:8000/tts/`
- **Method:** `POST`
- **Content-Type:** `application/json`

### Request Body
```
{
  "text": "<your text here>",
  "gender": "female" // or "male" (optional, default: "female")
}
```

### Example cURL Request
```
curl -X POST \
  http://localhost:8000/tts/ \
  -H "Content-Type: application/json" \
  -d '{"text": "नमस्ते, आप कैसे हैं?", "gender": "female"}'
```

### Response
- On success:
```
{
  "audio_wav_base64": "...base64-encoded-audio..."
}
```
- On error:
```
{
  "error": "<error message>"
}
```

### Saving the Audio
To save the returned base64 audio to a WAV file (Linux/macOS):

```
# Save the base64 string to a file (e.g., audio.b64)
# Then decode it:
cat audio.b64 | xxd -r -p > output.wav
```

---

## Python Example
```python
import requests

url = "http://localhost:8000/tts/"
data = {"text": "नमस्ते, आप कैसे हैं?", "gender": "female"}
resp = requests.post(url, json=data)
result = resp.json()
if "audio_wav_base64" in result:
    with open("output.wav", "wb") as f:
        f.write(bytes.fromhex(result["audio_wav_base64"]))
else:
    print("Error:", result.get("error"))
```

---

Replace `localhost` with your server's IP if running remotely.
