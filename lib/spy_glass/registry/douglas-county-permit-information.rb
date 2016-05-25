require 'spy_glass/registry'

time_zone = ActiveSupport::TimeZone["Pacific Time (US & Canada)"]

opts = {
  path: '/douglas-county-permit-information',
  cache: SpyGlass::Cache::Memory.new(expires_in: 300),
  source: 'https://data.douglas.co.us/resource/bedb-m69t.json?'+Rack::Utils.build_query({
    '$limit' => 1500
  })
}

SpyGlass::Registry << SpyGlass::Client::Socrata.new(opts) do |collection|
  features = collection.map do |item|

    case item['location']
    when nil
    else
      longitude = item['location']['coordinates'][0].to_f
      latitude = item['location']['coordinates'][1].to_f
    end

    title = <<-TITLE
      A(n) $#{item['permit_job_type'].to_s} was filed for $#{item['original_address_1'].to_s} on $#{item['applied_date'].to_s} for $#{item['description'].to_s}
      Status: $#{item['status_current'].to_s}
      Proposed Value: $#{item['job_valuation'].to_s}
    TITLE

    {
      'id' => item['permit_number'],
      'type' => 'Feature',
      'geometry' => {
        'type' => 'Point',
        'coordinates' => [
          longitude,
          latitude
        ]
      },
      'properties' => item.merge('title' => title)
    }
  end

  {'type' => 'FeatureCollection', 'features' => features}
end

