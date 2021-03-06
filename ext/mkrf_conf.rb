#(c) Copyright 2011 Raoul Bonnal. All Rights Reserved.

# create Rakefile for shared library compilation



path = File.expand_path(File.dirname(__FILE__))

path_external = File.join(path, "../lib/bio/db/sam/external")

Version = '0.1.19'

SamToolsFile = "samtools-#{Version}.tar.bz2"

File.open(File.join(path,"Rakefile"),"w") do |rakefile|
rakefile.write <<-RAKE
require 'rbconfig'
require 'open-uri'
require 'fileutils'
include FileUtils::Verbose
require 'rake/clean'

task :compile do
  sh "tar xvfj #{SamToolsFile}"
  cd("samtools-#{Version}") do
    sh "patch < ../Makefile-bioruby.patch"
    # This patch replace CURSES lib with NCURSES which it is the only one available in OpenSUSE
    sh "patch < ../Makefile-suse.patch"
    case Config::CONFIG['host_os']
      when /linux/
        #sh "CFLAGS='-g -Wall -O2 -fPIC' make -e"
        sh "make"
        cp("libbam.a","#{path_external}")
        #sh "CFLAGS='-g -Wall -O2 -fPIC' make -e libbam.so.1-local"
        sh "make libbam.so.1-local"
        cp("samtools", "#{path_external}")
        cp("libbam.so.1","#{path_external}")
      when /darwin/
        sh "make"
        cp("libbam.a","#{path_external}")
        sh "make libbam.1.dylib-local"
        cp("libbam.1.dylib","#{path_external}")
        sh "make"
        cp('samtools', "#{path_external}")
      when /mswin|mingw/ then raise NotImplementedError, "BWA library is not available for Windows platform"
    end #case
  end #cd
  cd("samtools-#{Version}/bcftools") do
    sh "make"
    cp('bcftools', "#{path_external}")
  end
end

task :clean do
  cd("samtools-#{Version}") do
    sh "make clean"
  end
  rm_rf("samtools-#{Version}")
end

task :default => [:compile, :clean]

RAKE

end
