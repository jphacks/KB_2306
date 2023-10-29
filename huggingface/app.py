import gradio as gr
from gradio.components import Dropdown, Audio, JSON
import stable_whisper
import soundfile as sf

from src.services.vocal_remover.runner import Separator, load_model
from src.services.transcribe import transcribe


separator_model, device = None, None
whisper_models = {}


def load_separator_model():
    global separator_model, device
    if separator_model is None or device is None:
        separator_pretrained_model_path = './baseline.pth'
        separator_model, device = load_model(
            pretrained_model=separator_pretrained_model_path)


def load_whisper_model(model_name):
    global whisper_models
    if model_name not in whisper_models:
        whisper_models[model_name] = stable_whisper.load_model(model_name)


def execute(whisper_model_name, audiofile):
    # 必要なモデルをオンデマンドでロード
    load_separator_model()
    load_whisper_model(whisper_model_name)

    # Read the audio file into a numpy array
    X, sample_rate = sf.read(audiofile)

    # Create a separator instance
    separator = Separator(model=separator_model, device=device)

    # V is vocals, Y is accompaniment
    # (2, T) numpy arrays
    Y, V = separator.separate(X)

    # Create a whisper instance
    whisper_model = whisper_models[whisper_model_name]

    # Transcribe the vocals with Whisper
    segments = transcribe(whisper_model, V.T, sample_rate)

    return segments


# Create a dropdown to select the model
model = Dropdown(choices=["base", "small", "medium",
                 "large", "large-v2"], label="Select a model")

# Create a file uploader for the audio file
audiofile = Audio(type='filepath', label="Upload an audio file")

# Create Gradio interface
iface = gr.Interface(
    fn=lambda whisper_model_name, audiofile: execute(
        whisper_model_name, audiofile),
    inputs=[model, audiofile],
    outputs=[JSON(label="Transcription")]
)

# Launch the interface
iface.launch()
