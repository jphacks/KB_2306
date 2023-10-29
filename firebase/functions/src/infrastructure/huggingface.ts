/* eslint-disable @typescript-eslint/no-unsafe-assignment */
import { HUGGINGFACE_API_KEY } from "../utils/env";
import { importClient } from "../utils/gradio-client";

const appRef = "sanbasan/lyrics-transcription-api-private";

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

type HuggingFaceResponse = {
  data: unknown[];
  endpoint: string;
  fn_index: 0;
  type: "data";
};

export const transcribeLyrics = async (
  url: string,
  {
    whisperModelName,
  }: {
    whisperModelName: "base" | "small" | "medium" | "large" | "large-v2";
  },
): Promise<HuggingFaceResponse> => {
  const app = await gradioClient(appRef);
  // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call
  const result = await app.predict("/predict", [
    whisperModelName,
    {
      data: null,
      name: url,
      is_file: true,
    },
  ]);

  return result as HuggingFaceResponse;
};
