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
      line = item['shape']['geometry']['paths']
    end

    case item['impacts']
    when nil
    else
      impact = item['impacts']
    end

    title = <<-TITLE
      #{item['project_name']}#{item['project_type_category']}
      #{item['project_type']}
      Starts on #{DateTime.strptime(item['start_date'].to_s, '%s').strftime("%m-%d-%Y")}, end on #{DateTime.strptime(item['end_date'].to_s, '%s').strftime("%m-%d-%Y")}
      For more information, contact #{item['project_contact']} #{item['project_contact_email']} #{item['project_contact_phone']}
      #{impact}
    TITLE

    {
      'id' => item['roadway_impacts_eid'],
      'type' => 'Feature',
      'geometry' => {
        'type' => 'MultiLineString',
        'coordinates' => line
      },
      'properties' => item.merge('title' => title)
    }
  end

  {'type' => 'FeatureCollection', 'features' => features}
end

