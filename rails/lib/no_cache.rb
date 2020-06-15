class NoCache
  def self.add_headers(headers)
    headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    headers['Pragma'] = 'no-cache'
    headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end
end
