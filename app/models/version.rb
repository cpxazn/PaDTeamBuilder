class Version < ActiveRecord::Base
	require 'open-uri'
	require 'open_uri_redirections'
	def self.latest_na
		Version.where("na_date is not null").order(na_date: :desc).first
	end
	def self.latest_jp
		Version.where("jp_date is not null").order(jp_date: :desc).first
	end
	def self.recent
		Version.order(number: :desc).limit(5)
	end
	def self.update
		jp = Nokogiri::HTML(open(Rails.application.config.play_store_jp, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})).at_xpath("//div[@itemprop='softwareVersion']").content.strip
		en = Nokogiri::HTML(open(Rails.application.config.play_store_en, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})).at_xpath("//div[@itemprop='softwareVersion']").content.strip
		
		if Version.where(number: jp).count == 0 then Version.create(number: jp) end
		if Version.where(number: jp).first.jp_date == nil then Version.where(number: jp).first.update(jp_date: Date.today) end
		
		if Version.where(number: en).count == 0 then Version.create(number: en) end
		if Version.where(number: en).first.na_date == nil then Version.where(number: en).first.update(na_date: Date.today) end
	end
end
