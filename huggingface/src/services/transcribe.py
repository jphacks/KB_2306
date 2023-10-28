from typing import Dict, Any
import whisper
import soundfile as sf
import numpy as np


from src.utils.resample import resample as resample_audio


def transcribe(
        model: whisper.Whisper,
        wave: np.ndarray,
        sample_rate: int) -> Dict[str, Any]:
    if len(wave.shape) != 1 and len(wave.shape) != 2:
        raise ValueError(
            "Audio data must be mono or stereo, not {}".format(
                wave.shape))

    # Convert to monaural if the audio has multiple channels
    if len(wave.shape) == 2 and wave.shape[1] >= 2:
        wave = np.mean(wave, axis=1)

    # Resample the audio data if necessary
    audio_data_tensor = resample_audio(wave, sample_rate)

    result = model.transcribe(audio_data_tensor, word_timestamps=True)

    return result.to_dict()  # type: ignore
