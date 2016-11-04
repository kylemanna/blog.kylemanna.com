#
# Simple tasks to make my life easier.
#
task :default => :preview

desc "Launch preview environment"
task :preview do
  sh "bundle exec jekyll serve --watch --incremental --config _config.yml,_config.dev.yml"
end # task :preview
 
desc 'Build site with Jekyll'
task :build do
  sh 'rm -rf _site'
  sh 'bundle exec jekyll build'
end # task :build
 
desc 'Build and deploy'
task :deploy => :build do
  sh 'rsync -azhc --progress --stats --delete _site/ kylemanna@dh.kylemanna.com:blog.kylemanna.com'
  sh 'git push origin master'
end # task :deploy

desc 'Notify Google of the new sitemap'
task :sitemap do
  require 'net/http'
  require 'uri'
  print Net::HTTP.get(
    'www.google.com',
    '/webmasters/tools/ping?sitemap=' +
    URI.escape('https://blog.kylemanna.com/sitemap.xml')
  )
end
