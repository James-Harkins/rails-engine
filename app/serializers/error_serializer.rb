class ErrorSerializer
  def self.serialize(errors)
    json = {}
    errors_hash = errors.to_hash(true).map do |key, value|
      value.map do |message|
        {id: key, title: message}
      end
    end.flatten
    json[:errors] = errors_hash
    json
  end
end
