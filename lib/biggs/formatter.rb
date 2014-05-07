module Biggs
  class Formatter

    FIELDS = [:recipient, :street, :city, :state, :zip, :country]

    def initialize(options={})
      @blank_country_on = [options[:blank_country_on]].compact.flatten.map{|s| s.to_s.downcase}
      @localize_country_name_to = options[:localize_country_name_to].to_s.downcase
    end

    def format(iso_code, values={})
      values.symbolize_keys! if values.respond_to?(:symbolize_keys!)

      format = Biggs::Format.find(iso_code)
      format_string = (format.format_string || default_format_string(values[:state])).dup.to_s
      if blank_country_on.include?(format.iso_code)
        country_name = ""
      else
        country_name = localize_country_name_to.blank? ? format.country_name || format.iso_code : I18nData.countries(localize_country_name_to)[format.iso_code]
      end

      (FIELDS - [:country]).each do |key|
        format_string.gsub!(/\{\{#{key}\}\}/, (values[key] || "").to_s)
      end
      format_string.gsub!(/\{\{country\}\}/, country_name)
      format_string.gsub(/\n$/, "")
    end

    attr_accessor :blank_country_on, :default_country_without_state, :default_country_with_state, :localize_country_name_to

    private

    def default_format_string(state)
      state && state != "" ?
        Biggs.formats[default_country_with_state || "us"] :
        Biggs.formats[default_country_without_state || "fr"]
    end
  end

end