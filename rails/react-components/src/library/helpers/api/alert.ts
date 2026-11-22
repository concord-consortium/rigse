import { withMessage, serverMessage } from "../request-error-message";

const apiAlert = (err: any, message: any) => {
  window.alert(withMessage(message || "Unable to call API!", serverMessage(err)));
};

export default apiAlert;
