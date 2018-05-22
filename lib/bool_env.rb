module BoolENV
  BOOL_TRUE = ["yes", "true", "1"]

  def self.[](env_variable)
    ENV[env_variable].present? && BOOL_TRUE.include?(ENV[env_variable].downcase)
  end
end
