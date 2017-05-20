namespace :es do
  desc "Build elastic index"
  task :build_index => :environment do
    Bug.__elasticsearch__.create_index!
    Bug.__elasticsearch__.refresh_index!
  end
end
