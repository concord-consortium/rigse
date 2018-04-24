
def write_data(name,records)
  CSV.open("/#{name}.csv", "wb", force_quotes: true, headers: records.first.keys) do |csv|
    records.each do |r|
      csv << r.values
    end
  end
end