module HasOrBelongsToManyExtensions
  def exists?(model)
    begin
      find(model)
    rescue ActiveRecord::RecordNotFound
      false
    end
  end
end

