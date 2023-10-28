import gradio as gr
from gradio.components import Dropdown, Audio, JSON
import stable_whisper
import soundfile as sf

from src.services.vocal_remover.runner import Separator, load_model
from src.services.transcribe import transcribe

# Transcribe function
def execute(whisper_model_name, audiofile):
    # Read the audio file into a numpy array
    X, sample_rate = sf.read(audiofile)

    # Create a separator instance
    separator_pretrained_model_path = './baseline.pth'
    separator_model, device = load_model(pretrained_model=separator_pretrained_model_path)
    separator = Separator(model=separator_model, device=device)

    # V is vocals, Y is accompaniment
    # (2, T) numpy arrays
    Y, V = separator.separate(X)

    # Save the separated audio sources to files
    accompaniment_file_path = 'accompaniment.wav'
    vocals_file_path = 'vocals.wav'
    sf.write(accompaniment_file_path, Y.T, sample_rate)
    sf.write(vocals_file_path, V.T, sample_rate)

    # Create a whisper instance
    whisper_model = stable_whisper.load_model(whisper_model_name)

    # Transcribe the vocals with Whisper
    segments = transcribe(whisper_model, V.T, sample_rate)

    # Return the file paths for download
    return accompaniment_file_path, vocals_file_path, segments

# Create a dropdown to select the model
model_options = ["base", "small", "medium", "large", "large-v2"]
model = Dropdown(choices=model_options, label="Select a model")

# Create a file uploader for the audio file
audiofile = Audio(type='filepath', label="Upload an audio file")

# Create Gradio interface
iface = gr.Interface(
    fn=lambda whisper_model_name, audiofile: execute(whisper_model_name, audiofile),
    inputs=[model, audiofile],
    outputs=[
        gr.outputs.Audio(label="Accompaniment"),
        gr.outputs.Audio(label="Vocals"),
        gr.outputs.JSON(label="Transcription")
    ]
)

# Launch the interface
iface.launch()
