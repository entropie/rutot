
#
# $Id$
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>

require 'rutot.rb'

VERS = Rutot.version

desc "sync tarballs to googlecode"
task :google_sync => [:rdoc, :distribute]do
  file = "pkg/#{VERS}.tar"
  ext = ['bz2', 'gz']
  ext.each do |e|
    desc = `hg head`.split("\n").grep(/summary/).to_s[/\w+:\s(.*)/, 1].strip
    pw = File.open(File.expand_path('~/Data/Secured/googlecode.pw')).readlines.join.strip
    p `googlecode_upload.py --config-dir none -s '#{desc}' -p rutot -P #{pw} -u mictro #{file}.#{e}`
  end
end

desc "creates rdoc"
task :rdoc do
  system('rdoc -a -I gif -S -m Rutot -o doc -x "(bin|plugins)"')
end

desc "create bzip2 and tarball"
task :distribute => [:rdoc] do
  sh "rm -rf pkg/#{VERS}"
  sh "mkdir -p pkg/#{VERS}"
  sh "cp ~/bin/hgcommit bin/scripts"
  sh "cp -r {bin,doc,lib,Rakefile.rb} pkg/#{VERS}/"

  Dir.chdir('pkg') do |pwd|
    sh "tar -zcvf #{VERS}.tar.gz #{VERS}"
    sh "tar -jcvf #{VERS}.tar.bz2 #{VERS}"
  end
  sh "rm -rf pkg/#{VERS}"
end

desc "list all still undocumented methods"
task :undocumented do
  files = Dir[File.join('lib', '**', '*.rb')]

  files.each do |file|
    puts file
    lines_till_here = []
    lines = File.readlines(file).map{|line| line.chomp}

    lines.each do |line|
      if line =~ /def /
        indent = line =~ /[^\s]/
        e = lines_till_here.reverse.find{|l| l =~ /end/}
        i = lines_till_here.reverse.index(e)
        lines_till_here = lines_till_here[-(i + 1)..-1] if i
        unless lines_till_here.any?{|l| l =~ /^\s*#/} or lines_till_here.empty?
          puts lines_till_here
          puts line
          puts "#{' ' * indent}..."
          puts e
        end
        lines_till_here.clear
      end
      lines_till_here << line
    end
  end
end


desc "remove those annoying spaces at the end of lines"
task 'fix-end-spaces' do
  Dir['{lib,test}/**/*.rb'].each do |file|
    next if file =~ /_darcs/
    lines = File.readlines(file)
    new = lines.dup
    lines.each_with_index do |line, i|
      if line =~ /\s+\n/
        puts "fixing #{file}:#{i + 1}"
        p line
        new[i] = line.rstrip
      end
    end

    unless new == lines
      File.open(file, 'w+') do |f|
        new.each do |line|
          f.puts(line)
        end
      end
    end
  end
end
