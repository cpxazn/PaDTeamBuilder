namespace :export do
  task :seeds_format => :environment do
    Monster.order(:id).all.each do |m|
      puts "Monster.create(#{m.serializable_hash.delete_if {|key, value| ['created_at','updated_at'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
  end
end