const retryCounts: { [key: string]: number } = {};

type RetryOperationResult<T> = {
  success: boolean;
  data: T | null;
};

export const retry = async <T>({
  operationKey,
  operation,
  maxRetries,
  onRetry,
}: {
  operationKey: string;
  operation: () => T | Promise<T>;
  maxRetries: number;
  onRetry?: (retryCount: number) => void | Promise<void>;
}): Promise<RetryOperationResult<T>> => {
  try {
    const result = operation();
    if (result instanceof Promise) {
      return {
        success: true,
        data: await result,
      };
    }
    return {
      success: true,
      data: result,
    };
  } catch (error) {
    retryCounts[operationKey] = (retryCounts[operationKey] || 0) + 1;
    if (retryCounts[operationKey] <= maxRetries) {
      if (onRetry) {
        await onRetry(retryCounts[operationKey]);
      }
      return retry({ operationKey, operation, maxRetries });
    } else {
      return {
        success: false,
        data: null,
      };
    }
  }
};
