def convert_to_spaced_timestamped_text(file_path):
    # Read the JSON data from the provided file path
    with open(file_path, "r", encoding="utf-8") as file:
        transcription_data = json.loads(file.read())

    # Extract the segments
    segments = transcription_data["segments"]

    # Extract and format the timestamps and text for each segment
    timestamped_text = []
    prev_end_time = 0
    for segment in segments:
        start_time = segment["start"]
        end_time = segment["end"]
        text = segment["text"].strip()
        
        # Calculate time difference between the end of the previous segment and the start of the current one
        time_difference = start_time - prev_end_time
        
        # If there is a significant time gap, add a timestamp with empty text
        if time_difference > 0.5:
            timestamped_text.append(f"[{int(prev_end_time // 60):02d}:{(prev_end_time % 60):05.2f}]")
        
        timestamped_text.append(f"[{int(start_time // 60):02d}:{(start_time % 60):05.2f}]{text}")
        
        prev_end_time = end_time

    # Join the extracted lines and return
    return "\n".join(timestamped_text)

# Test the function with the provided file and display the result
spaced_result = convert_to_spaced_timestamped_text("/mnt/data/transcription.json")
spaced_result
