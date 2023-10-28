import { transcribeLyrics as _transcribeLyrics } from "../domain/lyrics-transcription-result/business-logic";

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
  audio: Blob,
): Promise<ShrinkedLyricsTranscriptionResult> => {
  const result = await _transcribeLyrics(audio);

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
