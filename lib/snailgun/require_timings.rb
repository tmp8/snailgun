require 'benchmark'

$require_level = 0
$required = []

class SnailgunPreloader
  @@preload_file = "#{File.expand_path(Dir.pwd)}/.snailgun.preload"
  
  class << self
    def load_file(path)
      File.exist?(path) ? IO.read(path).split : []
    end
    
    def add_to_preload(path)
      ignore = load_file(".snailgun.ignore")
      already_marked_for_preloading = load_file(@@preload_file)
      unless ignore.include?(path) || already_marked_for_preloading.include?(path)
        puts "adding #{path}"
        File.open(@@preload_file, "a+") { |f| f.puts path }
      end
    end
  end
end

module Kernel
  alias require_without_timing require
  def require(path)
    result = seconds = nil
    
    begin
      $require_level += 1 
      seconds = Benchmark.realtime { result = require_without_timing(path) }
    ensure
      $require_level -= 1 
    end

   if result == true && $require_level == 0
     SnailgunPreloader.add_to_preload(path)
   end

#    if result
#      puts "R:#{'%.5f' % seconds} #{' '*$require_level}#{path} "  
#    end

    result
  end
end

