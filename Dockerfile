# Use official Python image
FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y git ffmpeg && rm -rf /var/lib/apt/lists/*

# Set workdir
WORKDIR /app

# Copy requirements and install Python dependencies
COPY vakyansh-tts/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the TTS code
COPY vakyansh-tts/ ./vakyansh-tts/


# Download and extract Hindi male and female models
RUN mkdir -p vakyansh-tts/vakyansh-tts/checkpoints/hifi/female \
	&& mkdir -p vakyansh-tts/vakyansh-tts/checkpoints/glow/female \
	&& mkdir -p vakyansh-tts/vakyansh-tts/checkpoints/hifi/male \
	&& mkdir -p vakyansh-tts/vakyansh-tts/checkpoints/glow/male \
	&& apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/* \
	&& wget -O vakyansh-tts/vakyansh-tts/checkpoints/hifi/female/hifi.zip https://storage.googleapis.com/vakyansh-open-models/tts/hindi/hi-IN/female_voice_0/hifi.zip \
	&& wget -O vakyansh-tts/vakyansh-tts/checkpoints/glow/female/glow.zip https://storage.googleapis.com/vakyansh-open-models/tts/hindi/hi-IN/female_voice_0/glow.zip \
	&& wget -O vakyansh-tts/vakyansh-tts/checkpoints/hifi/male/hifi.zip https://storage.googleapis.com/vakyansh-open-models/tts/hindi/hi-IN/male_voice_1/hifi.zip \
	&& wget -O vakyansh-tts/vakyansh-tts/checkpoints/glow/male/glow.zip https://storage.googleapis.com/vakyansh-open-models/tts/hindi/hi-IN/male_voice_1/glow.zip \
	&& unzip vakyansh-tts/vakyansh-tts/checkpoints/hifi/female/hifi.zip -d vakyansh-tts/vakyansh-tts/checkpoints/hifi/female/ \
	&& unzip vakyansh-tts/vakyansh-tts/checkpoints/glow/female/glow.zip -d vakyansh-tts/vakyansh-tts/checkpoints/glow/female/ \
	&& unzip vakyansh-tts/vakyansh-tts/checkpoints/hifi/male/hifi.zip -d vakyansh-tts/vakyansh-tts/checkpoints/hifi/male/ \
	&& unzip vakyansh-tts/vakyansh-tts/checkpoints/glow/male/glow.zip -d vakyansh-tts/vakyansh-tts/checkpoints/glow/male/ \
	&& rm vakyansh-tts/vakyansh-tts/checkpoints/*/*/*.zip \
	&& mkdir -p /input /output

# Expose API port
EXPOSE 8000

# Set entrypoint for FastAPI TTS API
ENTRYPOINT ["python", "tts_api.py"]
