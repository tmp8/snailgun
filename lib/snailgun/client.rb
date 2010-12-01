require 'socket'
module Snailgun
  class Client
    def initialize(sockname)
      server = UNIXSocket.open(sockname)
      server.send_io(STDIN)
      server.send_io(STDOUT)
      server.send_io(STDERR)
      args = Marshal.dump([ARGV, ENV.to_hash, Dir.pwd, Process.getpgrp])
      server.write [args.size].pack("N")
      server.write args
      begin
        rc = (server.read(1) || "\000").unpack("C").first
        exit rc
      rescue Interrupt
        server.write('X')
        exit 1
      end
    end
  end
end