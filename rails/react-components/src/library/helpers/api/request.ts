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
      switch (response.status) {
        case 404:
          throw new Error('Resource not found.');
        case 403:
          throw new Error('You are not authorized to perform this action.');
        default:
          throw new Error(`Request failed: ${response.status} ${response.statusText}`);
      }
    }
    return data;
  } catch (e: any) {
    window.alert(e.message);
  }
  return null;
};
