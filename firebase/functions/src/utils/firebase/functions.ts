import {
  MemoryOption,
  database,
  firestore,
  https,
  pubsub,
  setGlobalOptions,
  storage,
} from "firebase-functions/v2";

process.env.TZ = "Asia/Tokyo";

type FunctionSecrets = "HUGGINGFACE_API_KEY";

export const functions = ({
  secrets,
  memory,
  timeoutSeconds,
}: {
  secrets: FunctionSecrets[];
  memory: MemoryOption;
  timeoutSeconds?: number;
}): {
  database: typeof database;
  https: typeof https;
  pubsub: typeof pubsub;
  firestore: typeof firestore;
  storage: typeof storage;
} => {
  setGlobalOptions({
    memory,
    region: "asia-northeast1",
    secrets,
    maxInstances: 10,
    timeoutSeconds: timeoutSeconds ?? 540,
  });
  return {
    database,
    https,
    pubsub,
    firestore,
    storage,
  };
};
