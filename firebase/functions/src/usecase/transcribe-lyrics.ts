import { transcribeLyrics as _transcribeLyrics } from "../domain/lyrics-transcription-result/business-logic";
import { PUBLIC_SORAGE_FILE_URL, STORAGE_PUBLIC_URL } from "../utils/env";
import admin from "../utils/firebase/admin";
import { randomString } from "../utils/random-string";
import { retry } from "../utils/retry";

export type ShrinkedLyricsTranscriptionResult = {
  success: boolean;
  text: string;
  url: string;
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

export const transcribeLyrics = async ({
  userId,
  audio,
  fileName,
}: {
  userId: string;
  audio: ArrayBuffer;
  fileName: string;
}): Promise<ShrinkedLyricsTranscriptionResult> => {
  const fileExtension = fileName.split(".").pop() ?? "mp3";
  const uploadedFileName = `${randomString(20)}.${fileExtension}`;

  // TODO: Create interface for storage
  const storage = admin.storage();
  const bucket = storage.bucket();
  const file = bucket.file(`${userId}/${uploadedFileName}`);
  await file.save(Buffer.from(audio), {
    contentType: `audio/${fileExtension}`,
  });

  // For example: https://firebasestorage.googleapis.com/v0/b/lyrics-transcriber-dev.appspot.com/o/gm9edRjTHUcCc4BMXzvH3VPhNcY2%2FHcDHjmxa3YHDqn6FEBcM.wav?alt=media
  const url = `${STORAGE_PUBLIC_URL}/${userId}%2F${uploadedFileName}?alt=media`;

  // TODO: Use signed url for Hugging Face API and update rules for security
  const retryResult = await retry({
    operationKey: "transcribeLyrics",
    operation: () => _transcribeLyrics(url),
    maxRetries: 3,
    onRetry: () => {
      // Wait for 10 seconds
      return new Promise((resolve) => setTimeout(resolve, 10000));
    },
  });

  const result = retryResult.data;

  if (!retryResult.success || result === null) {
    return {
      success: false,
      text: "",
      url: "",
      segments: [],
      language: "",
    };
  }

  return {
    success: true,
    text: result.text,
    url: `${PUBLIC_SORAGE_FILE_URL}/${userId}/${uploadedFileName}`,
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
