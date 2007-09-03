
#
# $Id$
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>

task :spec do
  sh 'spec spec -r pitch'
end

task :specdoc do
  sh 'spec spec -f s -r pitch'
end

task :spechtml do
  sh 'spec spec -f h -r pitch -o ~/public_html/pitch.html'
end

task :rdoc do
  system('rdoc -a -I gif -S -m Rutot -o ~/public_html/doc/rutotdoc/ -x "(_darcs|bin|spec|plugins|contrib)"')
end

task :all => [:spec, :spechtml, :rdoc] do
end

task :profile do
  sh 'spec spec -r pitch -r profile'
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

task "create HISTORY from hg"


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
