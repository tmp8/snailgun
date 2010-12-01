ignore = File.exist?(".snailgun.ignore") ? IO.read(".snailgun.ignore").split : []
(IO.read(".snailgun.preload") rescue '').split.each do |path|
  next if ignore.include?(path)
  next if path =~ /^#/
  puts "snailgun.preload: #{path}"
  begin
    require path
  rescue Exception => e
    puts "cannot preload:'#{path}' 'cause of:#{e.message}"
  end
end