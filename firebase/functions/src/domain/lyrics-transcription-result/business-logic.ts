import { transcribeLyrics as _transcribeLyrics } from "../../infrastructure/huggingface";
import {
  LyricsTranscriptionResult,
  isLyricsTranscriptionResult,
} from "./entity";

export const transcribeLyrics = async (
  audio: Blob,
): Promise<LyricsTranscriptionResult | null> => {
  const res = await _transcribeLyrics(audio, { whisperModelName: "large-v2" });
  if (!isLyricsTranscriptionResult(res)) {
    return null;
  }
  return res;
};
