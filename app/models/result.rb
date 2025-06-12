Result = Struct.new(:success, :error, :value, keyword_init: true) do
  # Using keyword_init: true allows us to initialize with named parameters

  def self.success(value = nil)
    new(success: true, value: value)
  end

  def self.failure(error)
    new(success: false, error: error)
  end

  def success?
    success
  end

  def failure?
    !success
  end

  def on_success
    yield(value) if success?
    self
  end

  def on_failure
    yield(error) if failure?
    self
  end
end
