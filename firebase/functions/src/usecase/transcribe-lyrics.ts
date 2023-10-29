import { transcribeLyrics as _transcribeLyrics } from "../domain/lyrics-transcription-result/business-logic";
import { STORAGE_PUBLIC_URL } from "../utils/env";
import admin from "../utils/firebase/admin";

export type ShrinkedLyricsTranscriptionResult = {
  success: boolean;
  text: string;
  segments: {
    start: number;
    end: number;
    text: string;
    words: {
      word: string;
      start: number;
      end: number;
    }[];
  }[];
  language: string;
};

export const transcribeLyrics = async (
  audio: ArrayBuffer,
  fileName: string,
): Promise<ShrinkedLyricsTranscriptionResult> => {
  // TODO: Create interface for storage
  const storage = admin.storage();
  const bucket = storage.bucket();
  const file = bucket.file(fileName);
  await file.save(Buffer.from(audio), {
    contentType: `audio/${fileName.split(".").pop() ?? "mp3"}`,
  });
  const url = `${STORAGE_PUBLIC_URL}${fileName}?alt=media`;

  const result = await _transcribeLyrics(url);

  if (result === null) {
    return {
      success: false,
      text: "",
      segments: [],
      language: "",
    };
  }

  return {
    success: true,
    text: result.text,
    segments: result.segments.map((segment) => ({
      start: segment.start,
      end: segment.end,
      text: segment.text,
      words: segment.words.map((word) => ({
        word: word.word,
        start: word.start,
        end: word.end,
      })),
    })),
    language: result.language,
  };
};
