function formatDate (dateString: any) {
  const d = new Date(dateString);
  const month = ("0" + (d.getMonth() + 1)).slice(-2);
  const day = ("0" + d.getDate()).slice(-2);
  const year = d.getFullYear();
  return month + "-" + day + "-" + year;
}

export default formatDate;

// Date provided by the <input type="date"> element is in the format 'YYYY-MM-DD'.
// This function converts it to 'MM/DD/YYYY'.
export const formatInputDateToMMDDYYYY = (inputDateString: any) => {
  if (!inputDateString) {
    return "";
  }
  const [year, month, day] = inputDateString.split("-");
  return `${month}/${day}/${year}`;
};
