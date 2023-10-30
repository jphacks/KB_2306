import axios, { AxiosResponse, isAxiosError } from "axios";
import * as express from "express";
import { STORAGE_PUBLIC_URL } from "../utils/env";
import { functions } from "../utils/firebase/functions";
import cors = require("cors");

type FileResponse = {
  data: ArrayBuffer;
};

const extensionToContentType: Record<string, string> = {
  mp3: "audio/mp3",
  wav: "audio/wav",
  ogg: "audio/ogg",
};

const asyncHandler =
  (
    fn: (
      req: express.Request,
      res: express.Response,
      next: express.NextFunction,
    ) => Promise<void>,
  ) =>
  (
    req: express.Request,
    res: express.Response,
    next: express.NextFunction,
  ): void => {
    // Unwaited to make asyncHandler() return void
    fn(req, res, next).catch(next);
  };

const app = express();
app.use(cors());
app.get(
  "/:userId/:fileName",
  asyncHandler(
    async (req: express.Request, res: express.Response): Promise<void> => {
      const { userId, fileName } = req.params;
      const fileUrl = `${STORAGE_PUBLIC_URL}/${userId}%2F${fileName}?alt=media`;

      const fileExtension = fileName.split(".").pop()?.toLowerCase();
      if (fileExtension === undefined) {
        res.status(400).send("Bad Request");
        return;
      }
      const contentType = extensionToContentType[fileExtension] || "audio/mp3";

      try {
        const fileResponse: AxiosResponse<FileResponse> =
          await axios.get<FileResponse>(fileUrl, {
            responseType: "arraybuffer",
          });
        res.set("Content-Type", contentType);
        res.send(fileResponse.data);
      } catch (error: unknown) {
        if (isAxiosError(error)) {
          // Now error is of type AxiosError
          console.error("Error fetching file:", error);
          if (error.response) {
            // The request was made and the server responded with a status code
            // that falls out of the range of 2xx
            res.status(error.response.status).send(error.response.statusText);
          } else {
            // Something happened in setting up the request that triggered an Error
            res.status(500).send("Internal Server Error");
          }
        } else {
          console.error("Unexpected error:", error);
          res.status(500).send("Internal Server Error");
        }
      }
    },
  ),
);

export default functions({
  timeoutSeconds: 60,
  memory: "256MiB",
  secrets: [],
}).https.onRequest(app);
