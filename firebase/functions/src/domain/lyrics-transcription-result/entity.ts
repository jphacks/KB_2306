/* eslint-disable camelcase */

type LyricsTranscriptionWord = {
  word: string;
  start: number;
  end: number;
  probability: number;
  tokens: number[];
  segment_id: number;
  id: number;
};

const isLyricsTranscriptionWord = (
  data: unknown,
): data is LyricsTranscriptionWord => {
  if (typeof data !== "object" || data === null) {
    return false;
  }
  const { word, start, end, probability, tokens, segment_id, id } =
    data as LyricsTranscriptionWord;
  if (
    typeof word !== "string" ||
    typeof start !== "number" ||
    typeof end !== "number" ||
    typeof probability !== "number" ||
    !Array.isArray(tokens) ||
    typeof segment_id !== "number" ||
    typeof id !== "number"
  ) {
    return false;
  }
  if (tokens.some((token) => typeof token !== "number")) {
    return false;
  }
  return true;
};

type LyricsTranscriptionSegment = {
  start: number;
  end: number;
  text: string;
  seek: number;
  tokens: number[];
  temperature: number;
  avg_logprob: number;
  compression_ratio: number;
  no_speech_prob: number;
  words: LyricsTranscriptionWord[];
  id: number;
};

const isLyricsTranscriptionSegment = (
  data: unknown,
): data is LyricsTranscriptionSegment => {
  if (typeof data !== "object" || data === null) {
    return false;
  }
  const {
    start,
    end,
    text,
    seek,
    tokens,
    temperature,
    avg_logprob,
    compression_ratio,
    no_speech_prob,
    words,
    id,
  } = data as LyricsTranscriptionSegment;
  if (
    typeof start !== "number" ||
    typeof end !== "number" ||
    typeof text !== "string" ||
    typeof seek !== "number" ||
    !Array.isArray(tokens) ||
    typeof temperature !== "number" ||
    typeof avg_logprob !== "number" ||
    typeof compression_ratio !== "number" ||
    typeof no_speech_prob !== "number" ||
    !Array.isArray(words) ||
    typeof id !== "number"
  ) {
    return false;
  }
  if (
    !words.every((word) => isLyricsTranscriptionWord(word)) ||
    tokens.some((token) => typeof token !== "number")
  ) {
    return false;
  }

  return true;
};

type LyricsTranscriptionOriginalDictionary = {
  text: string;
  segments: LyricsTranscriptionSegment[];
  language: string;
  time_scale: null;
};

const isLyricsTranscriptionOriginalDictionary = (
  data: unknown,
): data is LyricsTranscriptionOriginalDictionary => {
  if (typeof data !== "object" || data === null) {
    return false;
  }
  const { text, segments, language, time_scale } =
    data as LyricsTranscriptionOriginalDictionary;
  if (
    typeof text !== "string" ||
    !Array.isArray(segments) ||
    typeof language !== "string" ||
    time_scale !== null
  ) {
    return false;
  }
  if (!segments.every((segment) => isLyricsTranscriptionSegment(segment))) {
    return false;
  }
  return true;
};

export type LyricsTranscriptionResult = {
  text: string;
  segments: LyricsTranscriptionSegment[];
  language: string;
  ori_dict: LyricsTranscriptionOriginalDictionary;
};

export const isLyricsTranscriptionResult = (
  data: unknown,
): data is LyricsTranscriptionResult => {
  if (typeof data !== "object" || data === null) {
    return false;
  }
  const { text, segments, language, ori_dict } =
    data as LyricsTranscriptionResult;
  if (
    typeof text !== "string" ||
    !Array.isArray(segments) ||
    typeof language !== "string" ||
    !isLyricsTranscriptionOriginalDictionary(ori_dict)
  ) {
    return false;
  }
  if (!segments.every((segment) => isLyricsTranscriptionSegment(segment))) {
    return false;
  }
  return true;
};
