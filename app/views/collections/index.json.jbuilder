json.array!(@collections) do |collection|
  json.extract! collection, :id, :name, :key, :description, :approved, :configuration
  begin
    json.sample_record JSON.parse(collection.records.order("RANDOM()").first.parsed['thumbnail'])[0]
  rescue
    json.sample_record nil
  end
  json.url collection_url(collection, format: :json)
end
