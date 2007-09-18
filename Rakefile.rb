
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
    `googlecode_upload.py --config-dir none -s '#{desc}' -p rutot -P #{pw} -u mictro #{file}.#{e} -l Featured` if e == 'gz'
  end
  puts "synced to googlecode"
end

desc "creates rdoc"
task :rdoc do
  sh "rm -rf doc"
  system('rdoc -a -I gif -S -m Rutot -o doc -x "(bin|plugins)"')
end

desc "create bzip2 and tarball"
task :distribute => [:rdoc] do
  sh "rm -rf pkg/#{VERS}"
  sh "mkdir -p pkg/#{VERS}"
  sh "cp ~/bin/hgcommit bin/scripts"
  sh "cp -r {bin,doc,lib,Rakefile.rb,plugins,rutot.rb} pkg/#{VERS}/"
  sh "mkdir pkg/#{VERS}/data"
  sh "cp ~/.howm/2007/08/2007-08-17-205206.howm pkg/#{VERS}/TODO.howm"
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
  Dir['{lib,plugins/bina}/**/*.rb'].each do |file|
    next if file =~ /\.hg/
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

desc "remove those annoying spaces at the end of lines"
task 'make-id-header' do
  cf = `hg head`.split("\n").first.
    scan(/changeset:\s+(\d+):/).flatten.first.to_i

  Dir['{lib,plugins,bin}/**/*.rb'].each do |file|
    next if file =~ /\.hg/
    fid = (hgl = `hg log #{file}`.split("\n")).first.
      scan(/changeset:\s+(\d+):/).flatten.first.to_i
    usr = hgl.grep(/user:\s+".+"/).first.to_s[14..-2]
    
    lines = File.readlines(file)
    new = lines.dup

    lines.each_with_index do |line, i|
      next if i != 1
      if line == "#\n" or line =~ /# \$Id:.*[^\$]/
          new[i] = "# $Id: #{fid} #{usr}: %s" % `hg log #{file}`.split("\n")[0..5].
          grep(/summary/).flatten.first[13..-1]
        puts ">   %s\n   '#{new[i]}'" % file
      else
        puts "not for\t #{file}"
      end
    end

    # unless new == lines
    #   File.open(file, 'w+') do |f|
    #     new.each do |line|
    #       f.puts(line)
    #     end
    #   end
    # end
  end
end
