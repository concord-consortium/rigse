import apiPost from "./post";

const api = (endPoints: any) => {
  return (action: any, options: any) => {
    const endPoint = endPoints[action];
    if (endPoint) {
      const { url } = endPoint;
      if (url) {
        let { type } = endPoint;
        type = type || "POST";
        apiPost(url, { type, ...options });
      } else {
        window.alert(`No url found for '${action}' API endpoint`);
      }
    } else {
      window.alert(`No API endpoint found for '${action}'`);
    }
  };
};

export default api;
