task :default => :server
 
desc 'Build site with Jekyll'
task :build do
  jekyll '--no-auto'
end
 
desc 'Build and start server with --auto'
task :server do
  jekyll '--server --auto'
end

desc 'Build and deploy'
task :deploy => :build do
  sh 'rsync -azh --progress --stats --delete _site/ kylemanna@yangon.dreamhost.com:blog.kylemanna.com'
  sh 'git push git@github.com:kylemanna/kylemanna.github.com.git master'
end

def jekyll(opts = '')
  sh 'rm -rf _site'
  sh 'jekyll ' + opts
end
