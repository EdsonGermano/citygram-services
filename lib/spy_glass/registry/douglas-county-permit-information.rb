require 'spy_glass/registry'
require 'indefinite_article'
require 'pry'

time_zone = ActiveSupport::TimeZone["Pacific Time (US & Canada)"]

opts = {
  path: '/douglas-county-permit-information',
  cache: SpyGlass::Cache::Memory.new(expires_in: 300),
  source: 'https://data.douglas.co.us/resource/28v6-p9wg.json?'+Rack::Utils.build_query({
    '$limit' => 1500,
    '$where' => 'issued_date>"' + 1.month.ago.utc.iso8601 + '"'
  })
}

SpyGlass::Registry << SpyGlass::Client::Socrata.new(opts) do |collection|
  features = collection.map do |item|
    if item['status_current'] == "ISSUED" && item['location']
      case item['location']
      when nil
      else
        longitude = item['location']['longitude'].to_f
        latitude = item['location']['latitude'].to_f
      end

      title = <<-TITLE
        #{item['permit_job_type'].to_s.indefinite_article.capitalize} #{item['permit_job_type'].to_s} Permit was filed for #{item['original_address_1'].to_s} on #{Time.at(item['applied_date']).strftime("%m-%d-%Y")} for #{item['description'].to_s}
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
  end

  {'type' => 'FeatureCollection', 'features' => features.compact}
end

