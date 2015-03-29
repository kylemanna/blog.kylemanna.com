task :default => :preview
 
desc 'Build site with Jekyll'
task :build do
  sh 'rm -rf _site'
  sh 'bundle exec jekyll build'
end
 
desc 'Build and deploy'
task :deploy => :build do
  sh 'rsync -azh --progress --stats --delete _site/ kylemanna@ssh.kylemanna.com:blog.kylemanna.com'
  sh 'git push origin master'
end
