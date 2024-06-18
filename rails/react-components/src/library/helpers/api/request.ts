export const getAuthToken = () => {
  const authToken = document.querySelector("meta[name=\"csrf-token\"]")?.getAttribute("content");
  if (!authToken) {
    throw new Error("CSRF token not found.");
  }
  return authToken;
};

export const request = async ({ url, method, body }: { url: string, method: string, body?: string }) => {
  try {
    const response = await fetch(url, {
      method,
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": getAuthToken()
      },
      body
    });
    const data = await response.json();
    if (!response.ok) {
      throw new Error(`HTTP error: ${response.status}`);
    }
    return data;
  } catch (e) {
    console.error(`${method} ${url} failed.`, e);
  }
  return null;
};
