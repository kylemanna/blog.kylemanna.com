task :default => :preview
 
desc 'Build site with Jekyll'
task :build do
  jekyll 'build'
end
 
desc 'Build and deploy'
task :deploy => :build do
  sh 'rsync -azh --progress --stats --delete _site/ kylemanna@blog.kylemanna.com:blog.kylemanna.com'
  sh 'git push origin master'
end

def jekyll(opts = '')
  sh 'rm -rf _site'
  sh 'jekyll ' + opts
end
