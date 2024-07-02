export const getAuthToken = () => {
  const authToken = document.querySelector("meta[name=\"csrf-token\"]")?.getAttribute("content");
  if (!authToken) {
    throw new Error("CSRF token not found.");
  }
  return authToken;
};

interface IOptions {
  url: string;
  method: string;
  body?: string;
  onError?: (error: Error) => void;
}

export const request = async ({ url, method, body, onError }: IOptions) => {
  try {
    const response = await fetch(url, {
      method,
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": getAuthToken()
      },
      body
    });
    if (!response.ok) {
      const info = `${method} ${url}`;
      switch (response.status) {
        case 404:
          throw new Error(`${info}: Resource not found.`);
        case 403:
          throw new Error(`${info}: You are not authorized to perform this action.`);
        default:
          throw new Error(`${info}: Request failed with HTTP error ${response.status} ${response.statusText}`);
      }
    }
    return await response.json();
  } catch (e: any) {
    if (onError) {
      onError(e);
    } else {
      window.alert(e.message);
    }
  }
  return null;
};
