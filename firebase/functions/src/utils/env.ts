// Secret
export const HUGGINGFACE_API_KEY = process.env.HUGGINGFACE_API_KEY;

const ALIAS = process.env.ALIAS ?? "dev";

const DEV_STORAGE_PUBLIC_URL =
  "https://firebasestorage.googleapis.com/v0/b/lyrics-transcriber-dev.appspot.com/o";

const PROD_STORAGE_PUBLIC_URL =
  "https://firebasestorage.googleapis.com/v0/b/lyrics-transcriber.appspot.com/o";

export const STORAGE_PUBLIC_URL =
  ALIAS === "dev" ? DEV_STORAGE_PUBLIC_URL : PROD_STORAGE_PUBLIC_URL;

const DEV_PUBLIC_SORAGE_FILE_URL =
  "https://storage-file-dqtrrd6l5a-an.a.run.app";

const PROD_PUBLIC_SORAGE_FILE_URL =
  "https://storage-file-rd2awp4sya-an.a.run.app";

export const PUBLIC_SORAGE_FILE_URL =
  ALIAS === "dev" ? DEV_PUBLIC_SORAGE_FILE_URL : PROD_PUBLIC_SORAGE_FILE_URL;
