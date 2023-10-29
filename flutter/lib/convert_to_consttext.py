def convert_to_correct_timestamped_text(file_path):
    # Read the JSON data from the provided file path
    with open(file_path, "r", encoding="utf-8") as file:
        transcription_data = json.loads(file.read())

    # Extract the segments
    segments = transcription_data["segments"]

    # Extract and format the timestamps and text for each segment
    timestamped_text = []
    for segment in segments:
        start_time_minutes = int(segment["start"] // 60)
        start_time_seconds = segment["start"] % 60
        text = segment["text"].strip()
        timestamped_text.append(f"[{start_time_minutes:02d}:{start_time_seconds:05.2f}]{text}")

    # Join the extracted lines and return
    return "\n".join(timestamped_text)

# Test the function with the provided file and display the result
correct_result = convert_to_correct_timestamped_text("/mnt/data/transcription.json")
correct_result