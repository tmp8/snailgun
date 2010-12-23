# Copyright (C) Brian Candler 2009. Released under the Ruby licence.

# Our at_exit handler must be called *last*, so register it first
at_exit do
  $SNAILGUN_EXIT.call if $SNAILGUN_EXIT
  $LOG.puts "done"
end

# Fix truncation of $0. See http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/336743
$progname = $0
alias $PROGRAM_NAME $0
alias $0 $progname
trace_var(:$0) {|val| $PROGRAM_NAME = val} # update for ps

require 'socket'
require 'optparse'
require 'shellwords'
require 'benchmark'

module Snailgun
  class Server
    attr_accessor :sockname

    def initialize(sockname = nil)
      @sockname = sockname || "/tmp/snailgun#{$$}"
      File.delete(@sockname) rescue nil
      @socket = UNIXServer.open(@sockname)
      yield self if block_given?
    end

    def run
      while client = @socket.accept
        pid = fork do
          
          ActiveRecord::Base.establish_connection
          
          rubylib = nil
          begin
            $LOG.puts "forked"
            STDIN.reopen(client.recv_io)
            STDOUT.reopen(client.recv_io)
            STDERR.reopen(client.recv_io)
            nbytes = client.read(4).unpack("N").first
            args, env, cwd, pgid = Marshal.load(client.read(nbytes))
            $LOG.puts "chdir(#{cwd})"
            Dir.chdir(cwd)
            if rubylib = env['RUBYLIB']
              $LOG.puts "RUBYLIB=#{rubylib}"
              rubylib.split(/:/).each do |path| 
                $LOAD_PATH.unshift path
              end
            end
            begin
              Process.setpgid(0, pgid)
            rescue Errno::EPERM
            end
            exit_status = 0
            $SNAILGUN_EXIT = lambda {
              begin
                client.write [exit_status].pack("C")
              rescue Errno::EPIPE
              end
            }
            #This doesn't work in 1.8.6:
            #Thread.new { client.read(1); Thread.main.raise Interrupt }
            Thread.new { client.read(1); exit 1 }
            start_ruby(args)
          rescue SystemExit => e
            exit_status = e.status
            raise  # for the benefit of Test::Unit
          rescue Exception => e
            STDERR.puts "#{e}\n\t#{e.backtrace.join("\n\t")}"
            exit 1
          ensure
            $LOAD_PATH.shift if rubylib
          end
        end
        Process.detach(pid) if pid && pid > 0
        client.close
      end
    ensure
      File.delete(@sockname) rescue nil
    end

    # Process the received ruby command line. (TODO: implement more options)
    def start_ruby(args)
      $LOG.puts "start_ruby=#{args.inspect}"
      
      e = []
      OptionParser.new do |opts|
        opts.on("-e EXPR") do |v|
          e << v
        end
        opts.on("-I DIR") do |v|
          v.split(/:/).each do |path|
            $:.unshift path
          end
        end
        opts.on("-r LIB") do |v|
          require v
        end
        opts.on("--dump_requires") do |v|
          require File.dirname(__FILE__) + "/require_timings.rb"
        end
        opts.on("-KU") do |v|
          $KCODE = 'u' if RUBY_VERSION < "1.9"
        end
      end.order!(args)

      ARGV.replace(args)
      if !e.empty?
        $0 = '-e'
        e.each { |expr| eval(expr, TOPLEVEL_BINDING) }
      elsif ARGV.empty?
        $0 = '-'
        eval(STDIN.read, TOPLEVEL_BINDING)
      else
        cmd = ARGV.shift
        $0 = cmd
        load(cmd)
      end
    end
  end
end
