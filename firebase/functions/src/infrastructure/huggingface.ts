/* eslint-disable @typescript-eslint/no-unsafe-assignment */
import { HUGGINGFACE_API_KEY } from "../utils/env";
import { importClient } from "../utils/gradio-client";

const appRef =
  "https://sanbasan-lyrics-transcription-api-private.hf.space/--replicas/6drjg/";

const isHuggingfaceApiKey = (token: string): token is `hf_${string}` =>
  /^hf_.*$/.test(token);

// Allow any type due to the workaround
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const gradioClient = async (appReference: string): Promise<any> => {
  const token = HUGGINGFACE_API_KEY;
  if (!token) {
    throw new Error("HUGGINGFACE_API_KEY is not defined.");
  }
  if (!isHuggingfaceApiKey(token)) {
    throw new Error("HUGGINGFACE_API_KEY is not a valid API key.");
  }
  const client = await importClient();
  return client(appReference, { hf_token: token });
};

export const transcribeLyrics = async (
  audio: Blob,
  {
    whisperModelName,
  }: {
    whisperModelName: "base" | "small" | "medium" | "large" | "large-v2";
  },
): Promise<unknown> => {
  const app = await gradioClient(appRef);
  // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
  const predict = app?.predict.call;

  // Check if predict is a function
  if (typeof predict !== "function") {
    throw new Error("Failed to get predict function.");
  }

  const result = await (predict as CallableFunction)("/predict", [
    `${whisperModelName},${whisperModelName}`,
    audio,
  ]);

  return result as unknown;
};
