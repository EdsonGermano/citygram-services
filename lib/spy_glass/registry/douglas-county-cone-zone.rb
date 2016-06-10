require 'spy_glass/registry'

time_zone = ActiveSupport::TimeZone["Pacific Time (US & Canada)"]

opts = {
  path: '/douglas-county-cone-zone',
  cache: SpyGlass::Cache::Memory.new(expires_in: 300),
  source: 'https://data.douglas.co.us/resource/8kwh-cx7b.json?'+Rack::Utils.build_query({
    '$limit' => 1500
  })
}

SpyGlass::Registry << SpyGlass::Client::Socrata.new(opts) do |collection|
  features = collection.map do |item|
    case item['shape']
    when nil
    else
      # latlng = item['shape'].gsub(/[()]/, '').split(/\s*,\s*/)
      # longitude = latlng[1].to_f
      # latitude = latlng[0].to_f
      line = item['shape']['geometry']['paths'][0]
    end

    title = <<-TITLE
      #{item['project_name']}
    TITLE

    {
      'id' => item['roadway_impacts_eid'],
      'type' => 'Feature',
      'geometry' => {
        'type' => 'LineString',
        'coordinates' => line
      },
      'properties' => item.merge('title' => title)
    }
  end

  {'type' => 'FeatureCollection', 'features' => features}
end

