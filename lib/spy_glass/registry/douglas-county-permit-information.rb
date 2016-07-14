require 'spy_glass/registry'
# require 'indefinite_article'

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
       #{item['permit_job_type'].to_s} Permit was filed for #{item['original_address_1'].to_s} on #{DateTime.iso8601(item['applied_date'].to_s).strftime("%m-%d-%Y")} for #{item['description'].to_s}
      Status: #{item['status_current'].to_s}
      Proposed Value: #{Money.us_dollar(item['job_valuation'].to_f * 100).format(:no_cents_if_whole => true)}
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

