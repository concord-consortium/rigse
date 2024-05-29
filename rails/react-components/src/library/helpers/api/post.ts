import apiAlert from "./alert";

const apiPost = (url: any, options: any) => {
  const { onSuccess, errorMessage } = options;
  let { type, data, onError } = options;

  type = type || "POST";
  data = data || {};

  onError = onError || ((err: any) => apiAlert(err, errorMessage));

  jQuery.ajax({
    url,
    data: JSON.stringify(data),
    type,
    dataType: "json",
    contentType: "application/json",
    success: json => {
      if (!json.success) {
        onError(json);
      } else if (onSuccess) {
        onSuccess(json.data);
      }
    },
    error: (jqXHR, textStatus, error) => {
      try {
        error = JSON.parse(jqXHR.responseText);
      } catch (e) {
        // noop
      }
      onError(error);
    }
  });
};

export default apiPost;
