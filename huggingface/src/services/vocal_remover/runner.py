# https://github.com/fabiogra/moseca/blob/main/app/service/vocal_remover/runner.py
#
# MIT License
#
# Copyright (c) 2023 Fabio Grasso
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# You can see how to call the Separator here:
# https://github.com/fabiogra/moseca/blob/main/scripts/inference.py

import librosa
import numpy as np
import torch

from . import nets


def _standardize_wave(X):
    """
    Standardize the shape of the audio input to (2, T)

    Parameters:
    - X: np.ndarray
        The input audio signal. Could be shape (T, ), (T, 2), or (2, T)

    Returns:
    - np.ndarray
        Standardized audio signal of shape (2, T)
    """
    X = np.asarray(X)

    # If mono audio (T, )
    if X.ndim == 1:
        return np.stack([X, X])

    # If stereo audio but shape is (T, 2)
    if X.shape[1] == 2:
        return X.T

    # If already in the shape (2, T)
    if X.shape[0] == 2:
        return X

    raise ValueError(
        "Unsupported audio shape. Must be either (T, ), (T, 2), or (2, T)")


def _merge_artifacts(y_mask, thres=0.05, min_range=64, fade_size=32):
    if min_range < fade_size * 2:
        raise ValueError("min_range must be >= fade_size * 2")

    idx = np.where(y_mask.min(axis=(0, 1)) > thres)[0]
    start_idx = np.insert(idx[np.where(np.diff(idx) != 1)[0] + 1], 0, idx[0])
    end_idx = np.append(idx[np.where(np.diff(idx) != 1)[0]], idx[-1])
    artifact_idx = np.where(end_idx - start_idx > min_range)[0]
    weight = np.zeros_like(y_mask)
    if len(artifact_idx) > 0:
        start_idx = start_idx[artifact_idx]
        end_idx = end_idx[artifact_idx]
        old_e = None

        for s, e in zip(start_idx, end_idx):
            if old_e is not None and s - old_e < fade_size:
                s = old_e - fade_size * 2

            if s != 0:
                weight[:, :, s: s + fade_size] = np.linspace(0, 1, fade_size)
            else:
                s -= fade_size

            if e != y_mask.shape[2]:
                weight[:, :, e - fade_size: e] = np.linspace(1, 0, fade_size)
            else:
                e += fade_size

            weight[:, :, s + fade_size: e - fade_size] = 1
            old_e = e

    v_mask = 1 - y_mask
    y_mask += weight * v_mask

    return y_mask


def _make_padding(width, cropsize, offset):
    left = offset
    roi_size = cropsize - offset * 2
    if roi_size == 0:
        roi_size = cropsize
    right = roi_size - (width % roi_size) + left

    return left, right, roi_size


def _stereo_wave_to_spectrogram(wave, hop_length, n_fft):
    wave_left = np.asfortranarray(wave[0])
    wave_right = np.asfortranarray(wave[1])

    spec_left = librosa.stft(wave_left, n_fft=n_fft, hop_length=hop_length)
    spec_right = librosa.stft(wave_right, n_fft=n_fft, hop_length=hop_length)
    spec = np.asfortranarray([spec_left, spec_right])

    return spec


def _spectrogram_to_stereo_wave(spec, hop_length=1024):
    spec_left = np.asfortranarray(spec[0])
    spec_right = np.asfortranarray(spec[1])

    wave_left = librosa.istft(spec_left, hop_length=hop_length)
    wave_right = librosa.istft(spec_right, hop_length=hop_length)
    spec = np.asfortranarray([wave_left, wave_right])

    return spec


def load_model(pretrained_model, n_fft=2048):
    model = nets.CascadedNet(n_fft, 32, 128)
    if torch.cuda.is_available():
        device = torch.device("cuda:0")
        model.to(device)
    else:
        device = torch.device("cpu")
    model.load_state_dict(torch.load(pretrained_model, map_location=device))
    return model, device


class Separator(object):
    def __init__(self, model, device, batchsize=4, cropsize=256, postprocess=False):
        self.model = model
        self.offset = model.offset
        self.device = device
        self.batchsize = batchsize
        self.cropsize = cropsize
        self.postprocess = postprocess

    def _separate(self, X_mag_pad, roi_size):
        X_dataset = []
        patches = (X_mag_pad.shape[2] - 2 * self.offset) // roi_size
        for i in range(patches):
            start = i * roi_size
            X_mag_crop = X_mag_pad[:, :, start: start + self.cropsize]
            X_dataset.append(X_mag_crop)

        X_dataset = np.asarray(X_dataset)

        self.model.eval()
        with torch.no_grad():
            mask = []
            for i in range(0, patches, self.batchsize):
                X_batch = X_dataset[i: i + self.batchsize]
                X_batch = torch.from_numpy(X_batch).to(
                    dtype=torch.float32).to(self.device)

                pred = self.model.predict_mask(X_batch)

                pred = pred.detach().cpu().numpy()
                pred = np.concatenate(pred, axis=2)
                mask.append(pred)

            mask = np.concatenate(mask, axis=2)

        return mask

    def _preprocess(self, X, hop_length=1024, n_fft=2048):
        X_spec = _stereo_wave_to_spectrogram(X, hop_length, n_fft)

        X_mag = np.abs(X_spec)
        X_phase = np.angle(X_spec)

        return X_mag, X_phase

    def _postprocess(self, mask, X_mag, X_phase):
        if self.postprocess:
            mask = _merge_artifacts(mask)

        y_spec = mask * X_mag * np.exp(1.0j * X_phase)
        v_spec = (1 - mask) * X_mag * np.exp(1.0j * X_phase)

        return y_spec, v_spec

    def separate(self, X):
        X = _standardize_wave(X)

        X_mag, X_phase = self._preprocess(X)

        n_frame = X_mag.shape[2]
        pad_l, pad_r, roi_size = _make_padding(
            n_frame, self.cropsize, self.offset)
        X_mag_pad = np.pad(
            X_mag, ((0, 0), (0, 0), (pad_l, pad_r)), mode="constant")
        X_mag_pad /= X_mag_pad.max()

        mask = self._separate(X_mag_pad, roi_size)
        mask = mask[:, :, :n_frame]

        y_spec, v_spec = self._postprocess(mask, X_mag, X_phase)

        y = _spectrogram_to_stereo_wave(y_spec)
        v = _spectrogram_to_stereo_wave(v_spec)

        return y, v
