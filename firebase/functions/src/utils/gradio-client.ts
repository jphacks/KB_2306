/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-implied-eval */

// Workaround to use Gradio client in commonjs environment
// See: https://github.com/gradio-app/gradio/issues/4260#issuecomment-1715949207

export const importClient = new Function(
  "return import('@gradio/client').then(module => module.client)",
) as () => Promise<
  (
    app_reference: string,
    options: {
      hf_token?: `hf_${string}`;
    },
  ) => Promise<any>
>;
