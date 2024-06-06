import { useState, useEffect, useCallback } from "react";

export const useFetch = <T>(url: string, initialData: T) => {
  const [data, setData] = useState<T>(initialData);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  // We store fetchData function once with useCallback
  // so it is not recreated on every render of enclosing component
  const fetchData = useCallback(async () => {
    setIsLoading(true);
    try {
      const response = await fetch(url);
      if (!response.ok) throw new Error(`HTTP error: ${response.status}`);
      const responseData = await response.json();
      setData(responseData);
    } catch (e: any) {
      setError(e);
    } finally {
      setIsLoading(false);
    }
  }, [url]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  // we return fetchData as `refetch` so that the component can refetch the data if needed
  return { data, isLoading, error, refetch: fetchData };
};

