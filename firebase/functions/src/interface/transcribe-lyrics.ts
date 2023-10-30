import { CallableRequest, HttpsError } from "firebase-functions/v2/https";
import { transcribeLyrics } from "../usecase/transcribe-lyrics";
import { functions } from "../utils/firebase/functions";

export default functions({
  secrets: ["HUGGINGFACE_API_KEY"],
  memory: "1GiB",
  timeoutSeconds: 60 * 15,
}).https.onCall(
  async (req: CallableRequest<{ audio: Buffer; fileName: string }>) => {
    if (req.auth === undefined) {
      throw new HttpsError("unauthenticated", "unauthenticated");
    }
    const userId = req.auth.uid;

    const { audio, fileName } = req.data;
    const res = await transcribeLyrics({ userId, audio, fileName });

    return res;
  },
);
