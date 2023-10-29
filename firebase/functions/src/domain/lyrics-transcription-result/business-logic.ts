import { logger } from "firebase-functions/v2";
import { transcribeLyrics as _transcribeLyrics } from "../../infrastructure/huggingface";
import { LyricsTranscriptionResult } from "./entity";

export const transcribeLyrics = async (
  url: string,
): Promise<LyricsTranscriptionResult> => {
  const res = await _transcribeLyrics(url, {
    whisperModelName: "large-v2",
  });

  logger.info(res.data);

  // TODO: Validate res
  return res.data[0] as LyricsTranscriptionResult;
};
