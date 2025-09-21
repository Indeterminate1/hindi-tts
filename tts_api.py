from fastapi import FastAPI, UploadFile, File, Form
from pydantic import BaseModel
import uvicorn
import os
import tempfile
import subprocess

app = FastAPI()

# Model paths (matching Dockerfile extraction)
GLOW_MODEL_DIRS = {
    "female": "vakyansh-tts/checkpoints/glow/female",
    "male": "vakyansh-tts/checkpoints/glow/male"
}
HIFI_MODEL_DIRS = {
    "female": "vakyansh-tts/checkpoints/hifi/female",
    "male": "vakyansh-tts/checkpoints/hifi/male"
}

class TTSRequest(BaseModel):
    text: str
    gender: str = "female"  # or "male"

@app.post("/tts/")
def tts(req: TTSRequest):
    gender = req.gender if req.gender in GLOW_MODEL_DIRS else "female"
    with tempfile.NamedTemporaryFile("w", delete=False, suffix=".txt") as tf:
        tf.write(req.text)
        tf.flush()
        temp_txt = tf.name
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as wf:
        temp_wav = wf.name
    cmd = [
        "python", "vakyansh-tts/utils/inference/tts.py",
        "-a", GLOW_MODEL_DIRS[gender],
        "-v", HIFI_MODEL_DIRS[gender],
        "-d", "cpu",
        "-t_file", temp_txt,
        "-w", temp_wav
    ]
    try:
        subprocess.run(cmd, check=True)
        with open(temp_wav, "rb") as f:
            audio_bytes = f.read()
        result = {"audio_wav_base64": audio_bytes.hex()}
    except Exception as e:
        result = {"error": str(e)}
    finally:
        if os.path.exists(temp_txt):
            os.remove(temp_txt)
        if os.path.exists(temp_wav):
            os.remove(temp_wav)
    return result

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
