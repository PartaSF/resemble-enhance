from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
import requests
import torch
import torchaudio
import io
import soundfile as sf
import uvicorn

from resemble_enhance.enhancer.inference import denoise

if torch.cuda.is_available():
    device = "cuda"
else:
    device = "cpu"


class DenoiseAudioRequest(BaseModel):
  url: str

app = FastAPI()

@app.post("/denoise/")
def denoise_audio(request: DenoiseAudioRequest):
  with requests.get(request.url) as file:
    dwav, sr = torchaudio.load(io.BytesIO(file.content))
    dwav = dwav.mean(dim=0)

    wav1, new_sr = denoise(dwav, sr, device)
    wav1 = wav1.cpu().numpy()

    buffer = io.BytesIO()
    sf.write(buffer, wav1, new_sr, format='WAV')
    buffer.seek(0)

    return StreamingResponse(buffer, media_type="audio/wav")


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
