import numpy as np
import torch
import torchaudio


def resample(
        audio_data_np: np.ndarray,
        sample_rate: int,
        target_sample_rate: int = 16000) -> torch.Tensor:
    if sample_rate != target_sample_rate:
        resampler = torchaudio.transforms.Resample(
            orig_freq=sample_rate,
            new_freq=target_sample_rate)
        return resampler(torch.tensor(audio_data_np, dtype=torch.float32))
    else:
        return torch.tensor(audio_data_np, dtype=torch.float32)
