import { useState, useEffect, useCallback } from "react";
import { request } from "../helpers/api/request";

export const useFetch = <T>(url: string, initialData: T) => {
  const [data, setData] = useState<T>(initialData);
  const [isLoading, setIsLoading] = useState(false);

  // We store fetchData function once with useCallback
  // so it is not recreated on every render of enclosing component
  const fetchData = useCallback(async () => {
    setIsLoading(true);
    const responseData = await request({ url, method: "GET" });
    if (responseData) {
      setData(responseData);
    }
    setIsLoading(false);
  }, [url]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  // we return fetchData as `refetch` so that the component can refetch the data if needed
  return { data, isLoading, refetch: fetchData };
};

